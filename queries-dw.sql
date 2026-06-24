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
SELECT v.nome AS veterinario, COUNT(fa.sk_atendimento) AS total_atendimentos, SUM(ff.valor_bruto) AS receita_gerada
FROM fato_atendimento fa
JOIN dim_veterinario v ON v.sk_veterinario = fa.sk_veterinario
LEFT JOIN fato_financeiro ff ON ff.sk_animal = fa.sk_animal AND ff.sk_tempo = fa.sk_tempo
GROUP BY v.nome
ORDER BY receita_gerada DESC;