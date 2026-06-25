-- total de atendimentos por unidade e mes
SELECT u.nome AS unidade, t.ano, t.nome_mes, COUNT(*) AS total_atendimentos
FROM fato_atendimento fa
JOIN dim_tempo t   ON t.sk_tempo = fa.sk_tempo
JOIN dim_unidade u ON u.sk_unidade = fa.sk_unidade
GROUP BY u.nome, t.ano, t.nome_mes, t.mes
ORDER BY t.ano, t.mes;

-- receita por unidade e trimestre
SELECT u.nome AS unidade, t.ano, t.trimestre, SUM(ff.valor_bruto) AS receita_bruta, SUM(ff.valor_cliente) AS recebido_cliente
FROM fato_financeiro ff
JOIN dim_tempo t   ON t.sk_tempo = ff.sk_tempo
JOIN dim_unidade u ON u.sk_unidade = ff.sk_unidade
GROUP BY u.nome, t.ano, t.trimestre
ORDER BY t.ano, t.trimestre;

-- espécies mais atendidas por ano
SELECT t.ano, a.especie, COUNT(*) AS total_atendimentos
FROM fato_atendimento fa
JOIN dim_tempo t  ON t.sk_tempo = fa.sk_tempo
JOIN dim_animal a ON a.sk_animal = fa.sk_animal
GROUP BY t.ano, a.especie
ORDER BY t.ano, total_atendimentos DESC;

-- saida de medicamentos por unidade e mes
SELECT u.nome AS unidade, dm.nome_comercial, t.ano, t.nome_mes, SUM(fe.quantidade_saida) AS saida_total
FROM fato_estoque fe
JOIN dim_tempo t        ON t.sk_tempo = fe.sk_tempo
JOIN dim_unidade u      ON u.sk_unidade = fe.sk_unidade
JOIN dim_medicamento dm ON dm.sk_medicamento = fe.sk_medicamento
GROUP BY u.nome, dm.nome_comercial, t.ano, t.nome_mes, t.mes
ORDER BY t.ano, t.mes;

-- atendimentos e receita por veterinario
WITH total_atendimentos_cte AS (
    SELECT fa.sk_veterinario, COUNT(fa.sk_atendimento) AS total_atendimentos
    FROM fato_atendimento fa GROUP BY fa.sk_veterinario
),
receita_veterinario_cte AS (
    SELECT c.veterinario_id, SUM(f.valor_total) AS receita_gerada
    FROM consulta c JOIN fatura f ON f.animal_id = c.animal_id 
    WHERE c.status = 'concluida' GROUP BY c.veterinario_id
)
SELECT v.nome AS veterinario, COALESCE(ta.total_atendimentos, 0) AS total_atendimentos, COALESCE(rv.receita_gerada, 0.00) AS receita_gerada
FROM dim_veterinario v
LEFT JOIN total_atendimentos_cte ta ON v.id_funcionario_orig = ta.sk_veterinario
LEFT JOIN receita_veterinario_cte rv ON v.id_funcionario_orig = rv.veterinario_id
ORDER BY receita_gerada DESC;