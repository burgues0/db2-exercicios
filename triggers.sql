CREATE OR REPLACE FUNCTION trg_fn_ajustar_disponiveis()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF (TG_OP = 'INSERT') AND (NEW.data_devolucao IS NULL) THEN
        IF (SELECT disponiveis FROM livro WHERE codigo = NEW.codigo_livro) <= 0 THEN
            RAISE EXCEPTION
                'erro: nenhuma copia disponível do livro %.', NEW.codigo_livro;
        END IF;
        UPDATE livro SET disponiveis = disponiveis - 1 WHERE codigo = NEW.codigo_livro;
    ELSIF (TG_OP = 'UPDATE')
          AND (OLD.data_devolucao IS NULL)
          AND (NEW.data_devolucao IS NOT NULL) THEN
        UPDATE livro SET disponiveis = disponiveis + 1 WHERE codigo = NEW.codigo_livro;
        UPDATE livro
        SET disponiveis = total_copias
        WHERE codigo = NEW.codigo_livro AND disponiveis > total_copias;
    END IF;

    RETURN NEW;
END;
$$;
 
CREATE TRIGGER trg_ajustar_disponiveis
AFTER INSERT OR UPDATE ON emprestimo
FOR EACH ROW EXECUTE FUNCTION trg_fn_ajustar_disponiveis();

CREATE OR REPLACE FUNCTION trg_fn_validar_disponiveis()
RETURNS TRIGGER
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.disponiveis < 0 THEN
        RAISE EXCEPTION
            'erro: disponiveis não pode ser negativo (livro %).', NEW.codigo;
    END IF;
    IF NEW.disponiveis > NEW.total_copias THEN
        RAISE EXCEPTION
            'erro: disponiveis (%) não pode ser maior que total_copias (%) no livro %.',
            NEW.disponiveis, NEW.total_copias, NEW.codigo;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_disponiveis
BEFORE INSERT OR UPDATE ON livro
FOR EACH ROW EXECUTE FUNCTION trg_fn_validar_disponiveis();