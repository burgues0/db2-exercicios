CREATE OR REPLACE FUNCTION fn_registrar_emprestimo(
    p_codigo_livro  INTEGER,
    p_cliente       VARCHAR,
    p_data          DATE DEFAULT CURRENT_DATE
)
RETURNS INTEGER
LANGUAGE plpgsql AS $$
DECLARE
    v_id INTEGER;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM livro WHERE codigo = p_codigo_livro) THEN
        RAISE EXCEPTION 'Livro % não encontrado.', p_codigo_livro;
    END IF;
    IF (SELECT disponiveis FROM livro WHERE codigo = p_codigo_livro) <= 0 THEN
        RAISE EXCEPTION 'Nenhuma cópia disponível para o livro %.', p_codigo_livro;
    END IF;

    INSERT INTO emprestimo (codigo_livro, cliente, data_emprestimo)
    VALUES (p_codigo_livro, p_cliente, p_data)
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION fn_registrar_devolucao(
    p_emprestimo_id INTEGER,
    p_data          DATE DEFAULT CURRENT_DATE
)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM emprestimo WHERE id = p_emprestimo_id) THEN
        RAISE EXCEPTION 'Empréstimo % não encontrado.', p_emprestimo_id;
    END IF;
    IF (SELECT data_devolucao FROM emprestimo WHERE id = p_emprestimo_id) IS NOT NULL THEN
        RAISE EXCEPTION 'Empréstimo % já possui devolução registrada.', p_emprestimo_id;
    END IF;
 
    UPDATE emprestimo
    SET data_devolucao = p_data
    WHERE id = p_emprestimo_id;
END;
$$;