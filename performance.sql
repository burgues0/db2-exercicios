CREATE INDEX idx_consulta_animal      ON consulta(animal_id);
CREATE INDEX idx_consulta_vet         ON consulta(veterinario_id);
CREATE INDEX idx_animal_cliente       ON animal(cliente_id);
CREATE INDEX idx_internacao_animal    ON internacao(animal_id);
CREATE INDEX idx_vacinacao_animal     ON vacinacao(animal_id);
CREATE INDEX idx_exame_animal         ON exame(animal_id);
CREATE INDEX idx_estoque_unidade      ON estoque(unidade_id);
CREATE INDEX idx_movimentacao_est     ON movimentacao_estoque(estoque_id);
CREATE INDEX idx_fatura_cliente       ON fatura(cliente_id);
CREATE INDEX idx_pagamento_fatura     ON pagamento(fatura_id);

CREATE INDEX idx_log_tabela_data ON log_prontuario(tabela, realizado_em DESC);

CREATE INDEX idx_consulta_diagnostico_gin
ON consulta USING GIN (to_tsvector('portuguese', COALESCE(diagnostico, '')));

CREATE MATERIALIZED VIEW mv_faturamento_mensal AS
SELECT u.nome AS unidade, DATE_TRUNC('month', f.emitida_em) AS mes,
    COUNT(DISTINCT f.id) AS total_faturas,
    SUM(f.valor_total) AS receita_bruta,
    SUM(f.valor_plano) AS coberto_plano,
    SUM(f.valor_cliente) AS a_receber_clientes
FROM fatura f
JOIN animal a   ON a.id = f.animal_id
JOIN consulta c ON c.animal_id = a.id
JOIN unidade u  ON u.id = c.unidade_id
GROUP BY u.nome, DATE_TRUNC('month', f.emitida_em);

CREATE UNIQUE INDEX idx_mv_fat_mensal ON mv_faturamento_mensal(unidade, mes);

REFRESH MATERIALIZED VIEW CONCURRENTLY mv_faturamento_mensal;

-- agenda por data e unidade
-- sem index
EXPLAIN ANALYZE
SELECT c.id, c.data_hora, a.nome AS animal, f.nome AS vet
FROM consulta c
JOIN animal a ON a.id = c.animal_id
JOIN funcionario f ON f.id = c.veterinario_id
WHERE c.data_hora::DATE = '2024-03-05' AND c.unidade_id = 1;
-- com index
CREATE INDEX idx_consulta_data_unidade ON consulta(data_hora, unidade_id)
WHERE status NOT IN ('cancelada', 'concluida');
SET enable_seqscan = OFF;
EXPLAIN ANALYZE
SELECT c.id, c.data_hora, a.nome AS animal, f.nome AS vet
FROM consulta c
JOIN animal a ON a.id = c.animal_id
JOIN funcionario f ON f.id = c.veterinario_id
WHERE c.data_hora::DATE = '2024-03-05' AND c.unidade_id = 1;
SET enable_seqscan = ON;

-- internações ativas por animal
-- sem index
EXPLAIN ANALYZE
SELECT animal_id, entrada FROM internacao
WHERE ativo = TRUE AND animal_id = 2;
-- com index
CREATE INDEX idx_internacao_ativa ON internacao(animal_id, entrada)
WHERE ativo = TRUE;
SET enable_seqscan = OFF;
EXPLAIN ANALYZE
SELECT animal_id, entrada FROM internacao
WHERE ativo = TRUE AND animal_id = 2;
SET enable_seqscan = ON;

-- estoque crítico por unidade
-- sem index
EXPLAIN ANALYZE
SELECT e.quantidade, e.qtd_minima FROM estoque e
WHERE e.quantidade <= e.qtd_minima AND e.unidade_id = 1;
-- com index
CREATE INDEX idx_estoque_qtd ON estoque(unidade_id, quantidade, qtd_minima);
SET enable_seqscan = OFF;
EXPLAIN ANALYZE
SELECT e.quantidade, e.qtd_minima FROM estoque e
WHERE e.quantidade <= e.qtd_minima AND e.unidade_id = 1;
SET enable_seqscan = ON;

-- próximas doses de vacina
-- sem index
EXPLAIN ANALYZE
SELECT animal_id, proxima_dose_prevista FROM vacinacao
WHERE proxima_dose_prevista <= CURRENT_DATE + INTERVAL '30 days'
AND proxima_dose_prevista IS NOT NULL;
-- com index
CREATE INDEX idx_vacinacao_proxima ON vacinacao(proxima_dose_prevista, animal_id)
WHERE proxima_dose_prevista IS NOT NULL;
SET enable_seqscan = OFF;
EXPLAIN ANALYZE
SELECT animal_id, proxima_dose_prevista FROM vacinacao
WHERE proxima_dose_prevista <= CURRENT_DATE + INTERVAL '30 days'
AND proxima_dose_prevista IS NOT NULL;
SET enable_seqscan = ON;

-- busca em diagnósticos
-- antes (ilike, sem índice)
EXPLAIN ANALYZE
SELECT id, diagnostico FROM consulta
WHERE diagnostico ILIKE '%dermatite%';
-- depois (gin + tsvector)
EXPLAIN ANALYZE
SELECT id, diagnostico FROM consulta
WHERE to_tsvector('portuguese', COALESCE(diagnostico,'')) @@ to_tsquery('portuguese', 'dermatite');