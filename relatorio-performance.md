# Relatório de Performance

## Agenda por data e unidade

```sql
SELECT c.id, c.data_hora, a.nome AS animal, f.nome AS vet
FROM consulta c
JOIN animal a ON a.id = c.animal_id
JOIN funcionario f ON f.id = c.veterinario_id
WHERE c.data_hora::DATE = '2024-03-05' AND c.unidade_id = 1;
```

**Antes**
```
Nested Loop (cost=0.14..10.78) (actual time=0.024..0.058 rows=2 loops=1)
  ->  Seq Scan on consulta c
        Filter: (unidade_id = 1) AND (data_hora::date = '2024-03-05')
        Rows Removed by Filter: 15
Execution Time: 0.080 ms
```

**Depois** (`idx_consulta_data_unidade`)
```
Nested Loop (cost=0.41..30.76) (actual time=0.029..0.058 rows=2 loops=1)
  ->  Index Scan using idx_consulta_vet on consulta c
        Filter: (unidade_id = 1) AND (data_hora::date = '2024-03-05')
  ->  Index Scan using animal_pkey on animal a
  ->  Index Scan using funcionario_pkey on funcionario f
Execution Time: 0.079 ms
```

---

## Internações ativas por animal

```sql
SELECT animal_id, entrada FROM internacao
WHERE ativo = TRUE AND animal_id = 2;
```

**Antes**
```
Seq Scan on internacao (cost=0.00..1.04) (actual time=0.007..0.009 rows=1 loops=1)
  Filter: (ativo AND (animal_id = 2))
  Rows Removed by Filter: 2
Execution Time: 0.020 ms
```

**Depois** (`idx_internacao_ativa`)
```
Index Only Scan using idx_internacao_ativa on internacao
  (cost=0.12..8.14) (actual time=0.012..0.015 rows=1 loops=1)
  Index Cond: (animal_id = 2)
  Heap Fetches: 1
Execution Time: 0.029 ms
```

---

## Estoque crítico por unidade

```sql
SELECT e.quantidade, e.qtd_minima FROM estoque e
WHERE e.quantidade <= e.qtd_minima AND e.unidade_id = 1;
```

**Antes**
```
Seq Scan on estoque e (cost=0.00..1.14) (actual time=0.008..0.009 rows=0 loops=1)
  Filter: (quantidade <= qtd_minima) AND (unidade_id = 1)
  Rows Removed by Filter: 9
Execution Time: 0.017 ms
```

**Depois** (`idx_estoque_qtd`)
```
Index Only Scan using idx_estoque_qtd on estoque e
  (cost=0.14..8.15) (actual time=0.016..0.017 rows=0 loops=1)
  Index Cond: (unidade_id = 1)
  Filter: (quantidade <= qtd_minima)
  Rows Removed by Filter: 5
  Heap Fetches: 5
Execution Time: 0.032 ms
```

---

## Próximas doses de vacina

```sql
SELECT animal_id, proxima_dose_prevista FROM vacinacao
WHERE proxima_dose_prevista <= CURRENT_DATE + INTERVAL '30 days'
AND proxima_dose_prevista IS NOT NULL;
```

**Antes**
```
Seq Scan on vacinacao (cost=0.00..1.12) (actual time=0.007..0.013 rows=4 loops=1)
  Filter: (proxima_dose_prevista IS NOT NULL)
    AND (proxima_dose_prevista <= CURRENT_DATE + '30 days')
  Rows Removed by Filter: 3
Execution Time: 0.029 ms
```

**Depois** (`idx_vacinacao_proxima`)
```
Index Only Scan using idx_vacinacao_proxima on vacinacao
  (cost=0.14..8.17) (actual time=0.026..0.035 rows=4 loops=1)
  Index Cond: (proxima_dose_prevista <= CURRENT_DATE + '30 days')
  Heap Fetches: 4
Execution Time: 0.063 ms
```

---

## Conclusão

| Exemplo | Antes | Depois | Plano mudou | Mais rápido |
|---------|-------|--------|-------------|-------------|
| Agenda | 0.080ms Seq Scan | 0.079ms Index Scan | Sim | Index Scan |
| Internações ativas | 0.020ms Seq Scan | 0.029ms Index Only Scan | Sim | Seq Scan |
| Estoque crítico | 0.017ms Seq Scan | 0.032ms Index Only Scan | Sim | Seq Scan |
| Vacinas pendentes | 0.029ms Seq Scan | 0.063ms Index Only Scan | Sim | Seq Scan |

Ao análisar os dados finais, podemos concluir que a criação de indexes em DBs com pouca massa de dados não provê tanta melhora quanto aparenta. O scan sequencial, assim como em qualquer problema básico de programação, vai ser tão rapido quanto uma busca direta usando algum algorítimo. Essa estratégia de performance irá vingar quando esse sistema escalar para tabelas com centenas de milhares de registros, pois o overhead do index não vai pesar tanto quanto iterar por 100.000 registros, por exemplo.
