-- fn_calcular_idade_animal
SELECT nome, especie, fn_calcular_idade_animal(id) AS idade FROM animal;
SELECT fn_calcular_idade_animal(1);

-- fn_disponibilidade_veterinario
-- validar disponibilidade dia 02/05/2024, 09:30 por 60 min
SELECT fn_disponibilidade_veterinario(1, '2024-03-05 09:00', 60);
-- listar horários livres por veterinário
SELECT f.nome AS veterinario,
    fn_disponibilidade_veterinario(v.funcionario_id, '2024-03-05 09:00', 60) AS livre_09h,
    fn_disponibilidade_veterinario(v.funcionario_id, '2024-03-05 10:00', 60) AS livre_10h,
    fn_disponibilidade_veterinario(v.funcionario_id, '2024-03-05 11:00', 60) AS livre_11h
FROM veterinario v
JOIN funcionario f ON f.id = v.funcionario_id
WHERE f.ativo = TRUE;

-- fn_total_atendimentos_animal
SELECT fn_total_atendimentos_animal(1);
SELECT fn_total_atendimentos_animal(3);

-- fn_gerar_fatura
-- fatura p/ animal 2, cliente 1
SELECT fn_gerar_fatura(2, 1) AS nova_fatura_id;
-- verificar fatura:
SELECT fn_gerar_fatura(2, 1) AS nova_fatura_id;
SELECT * FROM fatura ORDER BY id DESC LIMIT 1;

-- fn_relatorio_internacoes_ativas
SELECT * FROM fn_relatorio_internacoes_ativas();
-- filtrar internação com mais de 3 dias
SELECT * FROM fn_relatorio_internacoes_ativas()
WHERE dias_internado > 3;