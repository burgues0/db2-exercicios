-- view: agenda completa de consultas com dados
CREATE OR REPLACE VIEW vw_agenda_dia AS
SELECT c.id AS consulta_id, c.data_hora, u.nome AS unidade, s.nome AS sala, a.nome AS animal, a.especie, cl.nome AS cliente, cl.telefone AS telefone_cliente, f.nome AS veterinario, v.crmv, c.status
FROM consulta c
JOIN unidade u       ON u.id = c.unidade_id
JOIN sala s          ON s.id = c.sala_id
JOIN animal a        ON a.id = c.animal_id
JOIN cliente cl      ON cl.id = a.cliente_id
JOIN funcionario f   ON f.id = c.veterinario_id
JOIN veterinario v   ON v.funcionario_id = c.veterinario_id;

-- view: histórico clínico completo de cada animal
CREATE OR REPLACE VIEW vw_prontuario_animal AS
SELECT a.id AS animal_id, a.nome AS animal, a.especie, a.raca, a.sexo, a.data_nascimento, a.peso_kg, cl.nome AS cliente, cl.telefone AS telefone_cliente, c.id AS consulta_id, c.data_hora AS data_consulta, f.nome AS veterinario, c.diagnostico, c.recomendacoes, c.status AS status_consulta
FROM animal a
JOIN cliente cl         ON cl.id = a.cliente_id
LEFT JOIN consulta c    ON c.animal_id = a.id
LEFT JOIN funcionario f ON f.id = c.veterinario_id
WHERE a.status = 'ativo';

-- view: medicamentos abaixo do estoque mínimo por unidade
CREATE OR REPLACE VIEW vw_estoque_critico AS
SELECT u.nome AS unidade, m.nome_comercial AS medicamento, m.principio_ativo, m.apresentacao, e.quantidade AS qtd_atual, e.qtd_minima, e.lote, e.validade,
    CASE
        WHEN e.validade < CURRENT_DATE THEN 'VENCIDO'
        WHEN e.quantidade <= e.qtd_minima THEN 'CRÍTICO'
        ELSE 'OK'
    END AS situacao
FROM estoque e
JOIN unidade u      ON u.id = e.unidade_id
JOIN medicamento m  ON m.id = e.medicamento_id
WHERE e.quantidade <= e.qtd_minima
   OR e.validade < CURRENT_DATE
ORDER BY u.nome, situacao DESC, m.nome_comercial;

-- view: resumo financeiro por unidade e mes
CREATE OR REPLACE VIEW vw_faturamento_mensal AS
SELECT u.nome AS unidade, DATE_TRUNC('month', f.emitida_em) AS mes, COUNT(DISTINCT f.id) AS total_faturas, SUM(f.valor_total) AS receita_bruta, SUM(f.desconto) AS total_descontos, SUM(f.valor_plano) AS coberto_plano, SUM(f.valor_cliente) AS a_receber_clientes, SUM(CASE WHEN f.status = 'pago' THEN f.valor_cliente ELSE 0 END) AS recebido, SUM(CASE WHEN f.status = 'pendente' THEN f.valor_cliente ELSE 0 END) AS pendente
FROM fatura f
JOIN animal a   ON a.id = f.animal_id
JOIN consulta c ON c.animal_id = a.id
JOIN unidade u  ON u.id = c.unidade_id
GROUP BY u.nome, DATE_TRUNC('month', f.emitida_em)
ORDER BY mes DESC, u.nome;

-- view: animais com dose de vacina vencida ou perto de vencer
CREATE OR REPLACE VIEW vw_vacinacao_pendente AS
SELECT a.id AS animal_id, a.nome AS animal, a.especie, cl.nome AS cliente, cl.telefone AS telefone_cliente, cl.email AS email_cliente, vac.nome AS vacina, v.data_aplicacao AS ultima_aplicacao, v.proxima_dose_prevista,
    CASE
        WHEN v.proxima_dose_prevista < CURRENT_DATE THEN 'ATRASADA'
        WHEN v.proxima_dose_prevista <= CURRENT_DATE + INTERVAL '30 days' THEN 'PRÓXIMA (30 dias)'
        ELSE 'NO PRAZO'
    END AS situacao
FROM vacinacao v
JOIN animal a   ON a.id = v.animal_id
JOIN cliente cl ON cl.id = a.cliente_id
JOIN vacina vac ON vac.id = v.vacina_id
WHERE a.status = 'ativo'
  AND v.proxima_dose_prevista IS NOT NULL
  AND v.proxima_dose_prevista <= CURRENT_DATE + INTERVAL '30 days'
ORDER BY v.proxima_dose_prevista;