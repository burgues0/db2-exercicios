-- function: retorna a idade do animal em anos e meses
CREATE OR REPLACE FUNCTION fn_calcular_idade_animal(p_animal_id INT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_nasc DATE;
    v_anos INT;
    v_meses INT;
BEGIN
    SELECT data_nascimento INTO v_nasc FROM animal WHERE id = p_animal_id;
    IF v_nasc IS NULL THEN
        RETURN 'Idade não informada';
    END IF;
    v_anos  := EXTRACT(YEAR FROM AGE(CURRENT_DATE, v_nasc));
    v_meses := EXTRACT(MONTH FROM AGE(CURRENT_DATE, v_nasc));
    IF v_anos = 0 THEN
        RETURN v_meses || ' mês(es)';
    ELSIF v_meses = 0 THEN
        RETURN v_anos || ' ano(s)';
    ELSE
        RETURN v_anos || ' ano(s) e ' || v_meses || ' mês(es)';
    END IF;
END;
$$;

-- fucntion: verifica disponibilidade do veterinário
CREATE OR REPLACE FUNCTION fn_disponibilidade_veterinario(p_vet_id INT, p_data_hora TIMESTAMP, p_duracao_min INT DEFAULT 60)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_fim TIMESTAMP;
    v_conflito INT;
BEGIN
    v_fim := p_data_hora + (p_duracao_min || ' minutes')::INTERVAL;
    SELECT COUNT(*) INTO v_conflito
    FROM consulta
    WHERE veterinario_id = p_vet_id
      AND status NOT IN ('cancelada', 'concluida')
      AND data_hora < v_fim
      AND (data_hora + INTERVAL '60 minutes') > p_data_hora;
    RETURN v_conflito = 0;
END;
$$;

-- function: resumo de atendimentos do animal retornando em json
CREATE OR REPLACE FUNCTION fn_total_atendimentos_animal(p_animal_id INT)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_resultado JSONB;
BEGIN
    SELECT jsonb_build_object('animal_id', p_animal_id, 'animal_nome', a.nome, 'consultas', COUNT(DISTINCT c.id), 'exames', COUNT(DISTINCT e.id), 'vacinacoes', COUNT(DISTINCT vac.id), 'internacoes', COUNT(DISTINCT i.id))
    INTO v_resultado
    FROM animal a
    LEFT JOIN consulta c    ON c.animal_id   = a.id
    LEFT JOIN exame e       ON e.animal_id   = a.id
    LEFT JOIN vacinacao vac ON vac.animal_id = a.id
    LEFT JOIN internacao i  ON i.animal_id   = a.id
    WHERE a.id = p_animal_id
    GROUP BY a.nome;
    RETURN v_resultado;
END;
$$;

-- function : cria fatura vazia para um animal/cliente e retorna o id da fatura
CREATE OR REPLACE FUNCTION fn_gerar_fatura(p_animal_id INT, p_cliente_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_fatura_id INT;
    v_plano_pct NUMERIC(5,2) := 0;
BEGIN
    SELECT ps.pct_cobertura INTO v_plano_pct
    FROM animal_plano ap
    JOIN plano_saude ps ON ps.id = ap.plano_id
    WHERE ap.animal_id = p_animal_id
      AND ap.ativo = TRUE
      AND (ap.vigencia_fim IS NULL OR ap.vigencia_fim >= CURRENT_DATE)
    LIMIT 1;
    IF v_plano_pct IS NULL THEN
        v_plano_pct := 0;
    END IF;
    INSERT INTO fatura (cliente_id, animal_id, valor_total, valor_plano, valor_cliente)
    VALUES (p_cliente_id, p_animal_id, 0, 0, 0)
    RETURNING id INTO v_fatura_id;
    RETURN v_fatura_id;
END;
$$;

-- fucntion: tabela com internações ativas e dias internado
CREATE OR REPLACE FUNCTION fn_relatorio_internacoes_ativas()
RETURNS TABLE (internacao_id INT, animal VARCHAR, especie VARCHAR, cliente VARCHAR, telefone_cliente VARCHAR, unidade VARCHAR, sala VARCHAR, veterinario VARCHAR, entrada TIMESTAMP, dias_internado INT, ultima_evolucao TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT i.id, a.nome, a.especie, cl.nome, cl.telefone, u.nome, s.nome, f.nome, i.entrada, EXTRACT(DAY FROM NOW() - i.entrada)::INT,  MAX(ec.data_hora)
    FROM internacao i
    JOIN animal a                 ON a.id = i.animal_id
    JOIN cliente cl               ON cl.id = a.cliente_id
    JOIN unidade u                ON u.id = i.unidade_id
    JOIN sala s                   ON s.id = i.sala_id
    JOIN funcionario f            ON f.id = i.veterinario_id
    LEFT JOIN evolucao_clinica ec ON ec.internacao_id = i.id
    WHERE i.ativo = TRUE
    GROUP BY i.id, a.nome, a.especie, cl.nome, cl.telefone, u.nome, s.nome, f.nome, i.entrada;
END;
$$;