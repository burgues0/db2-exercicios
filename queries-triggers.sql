-- trg_log_consulta
-- qualquer alteração na tabela consulta
UPDATE consulta SET diagnostico = 'Dermatite atópica' WHERE id = 1;
SELECT * FROM log_prontuario ORDER BY realizado_em DESC LIMIT 10;

-- trg_conflito_sala
-- agendar na mesma sala/horário deve lançar erro
INSERT INTO consulta (unidade_id, sala_id, animal_id, veterinario_id, data_hora)
VALUES (1, 1, 4, 1, '2024-05-02 09:30');

-- trg_movimentacao_estoque
-- saida valida
INSERT INTO movimentacao_estoque (estoque_id, tipo, quantidade, responsavel_id)
VALUES (1, 'saida', 5, 1);
SELECT quantidade FROM estoque WHERE id = 1;
-- saida inválida
INSERT INTO movimentacao_estoque (estoque_id, tipo, quantidade, responsavel_id)
VALUES (1, 'saida', 9999, 1);

-- trg_vacina_lote_vencido
-- inserir vacinação com lote vencido
INSERT INTO vacinacao (animal_id, vacina_id, aplicado_por, lote, validade_lote, data_aplicacao, dose)
VALUES (1, 1, 1, 'LOTE-OLD', '2020-01-01', CURRENT_DATE, 'anual');
-- vacinação valida:
INSERT INTO vacinacao (animal_id, vacina_id, aplicado_por, lote, validade_lote, data_aplicacao, dose, proxima_dose_prevista)
VALUES (5, 1, 6, 'LOTE-2025', '2026-01-01', CURRENT_DATE, 'anual', CURRENT_DATE + INTERVAL '1 year');

-- trg_recalcular_fatura
-- inserir novo item na fatura = total é recalculado
INSERT INTO fatura_item (fatura_id, tipo, referencia_id, descricao, valor)
VALUES (1, 'exame', 3, 'Ultrassom abdominal - Thor', 220.00);
SELECT valor_total, valor_plano, valor_tutor FROM fatura WHERE id = 1;
