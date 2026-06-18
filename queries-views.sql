-- vw_agenda_dia
-- consultar agenda de hoje
SELECT * FROM vw_agenda_dia
WHERE data_hora::DATE = CURRENT_DATE
ORDER BY data_hora;
-- consultar agenda de uma unidade em uma data específica
SELECT * FROM vw_agenda_dia
WHERE unidade = 'VetCare Copacabana'
  AND data_hora::DATE = '2024-04-10'
ORDER BY data_hora;

-- vw_prontuario_animal
-- histórico de um animal específico
SELECT * FROM vw_prontuario_animal
WHERE animal_id = 1
ORDER BY data_consulta DESC;
-- animais atendidos em abril de 2024
SELECT DISTINCT animal, especie, tutor
FROM vw_prontuario_animal
WHERE data_consulta BETWEEN '2024-04-01' AND '2024-04-30';

-- vw_estoque_critico
-- ver itens críticos
SELECT * FROM vw_estoque_critico;
-- filtrar vencidos
SELECT * FROM vw_estoque_critico WHERE situacao = 'VENCIDO';
-- filtrar por unidade
SELECT * FROM vw_estoque_critico WHERE unidade = 'VetCare Copacabana';

-- vw_faturamento_mensal
-- faturamento de todos os meses
SELECT * FROM vw_faturamento_mensal;
-- faturamento de mes específico
SELECT * FROM vw_faturamento_mensal
WHERE mes = '2024-04-01';

-- vw_vacinacao_pendente
-- ver vacinas pendentes ou atrasadas
SELECT * FROM vw_vacinacao_pendente;
-- ver vacinas atrasadas
SELECT * FROM vw_vacinacao_pendente WHERE situacao = 'ATRASADA';
-- ver por animal
SELECT * FROM vw_vacinacao_pendente WHERE animal_id = 1;