
-- trigger: registra alterações na tabela de consultas
CREATE OR REPLACE FUNCTION fn_log_prontuario()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO log_prontuario (tabela, registro_id, operacao, dados_anteriores, dados_novos, realizado_por)
    VALUES (TG_TABLE_NAME, COALESCE(NEW.id, OLD.id), TG_OP,
        CASE WHEN TG_OP = 'INSERT' THEN NULL ELSE to_jsonb(OLD) END,
        CASE WHEN TG_OP = 'DELETE' THEN NULL ELSE to_jsonb(NEW) END, current_user);
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_log_consulta
AFTER INSERT OR UPDATE OR DELETE ON consulta
FOR EACH ROW EXECUTE FUNCTION fn_log_prontuario();

-- trigger: impede agendamento de consulta em sala já ocupada no mesmo horário
CREATE OR REPLACE FUNCTION fn_verificar_conflito_sala()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_conflito INT;
    v_duracao INTERVAL := '60 minutes';
BEGIN
    SELECT COUNT(*) INTO v_conflito
    FROM consulta
    WHERE sala_id = NEW.sala_id
      AND id <> COALESCE(NEW.id, -1)
      AND status NOT IN ('cancelada', 'concluida')
      AND data_hora < (NEW.data_hora + v_duracao)
      AND (data_hora + v_duracao) > NEW.data_hora;
    IF v_conflito > 0 THEN
        RAISE EXCEPTION 'Conflito de horário: sala % já está ocupada às %.', NEW.sala_id, NEW.data_hora;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_conflito_sala
BEFORE INSERT OR UPDATE ON consulta
FOR EACH ROW EXECUTE FUNCTION fn_verificar_conflito_sala();

-- trigger: impede saida de estoque se qntd for insuficiente ou se o lote estiver vencido + atualiza o saldo
CREATE OR REPLACE FUNCTION fn_estoque_saida_valida()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_disponivel NUMERIC(10,2);
    v_validade DATE;
BEGIN
    IF NEW.tipo = 'saida' THEN
        SELECT quantidade, validade
        INTO v_disponivel, v_validade
        FROM estoque WHERE id = NEW.estoque_id;
        IF v_disponivel < NEW.quantidade THEN
            RAISE EXCEPTION 'estoque insuficiente. disponivel: %, solicitado: %.', v_disponivel, NEW.quantidade;
        END IF;
        IF v_validade IS NOT NULL AND v_validade < CURRENT_DATE THEN
            RAISE EXCEPTION 'lot vencido em %. saida n permitida', v_validade;
        END IF;
        UPDATE estoque
        SET quantidade = quantidade - NEW.quantidade
        WHERE id = NEW.estoque_id;
    ELSE
        UPDATE estoque
        SET quantidade = quantidade + NEW.quantidade
        WHERE id = NEW.estoque_id;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_movimentacao_estoque
BEFORE INSERT ON movimentacao_estoque
FOR EACH ROW EXECUTE FUNCTION fn_estoque_saida_valida();

-- trigger: impede aplicação de vacina com lote vencido
CREATE OR REPLACE FUNCTION fn_vacina_lote_vencido()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.validade_lote < CURRENT_DATE THEN
        RAISE EXCEPTION 'não e possivel aplicar a vacian: lote % venceu dia %.', NEW.lote, NEW.validade_lote;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_vacina_lote_vencido
BEFORE INSERT ON vacinacao
FOR EACH ROW EXECUTE FUNCTION fn_vacina_lote_vencido();

-- trigger: recalcula valor_total, valor_plano e valor_cliente da fatura smp que um item for inserido atualizado ou excluido
CREATE OR REPLACE FUNCTION fn_recalcular_fatura()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_fatura_id INT;
    v_total NUMERIC(10,2);
    v_plano_pct NUMERIC(5,2) := 0;
    v_animal_id INT;
    v_valor_plano NUMERIC(10,2);
    v_valor_cliente NUMERIC(10,2);
BEGIN
    v_fatura_id := COALESCE(NEW.fatura_id, OLD.fatura_id);
    SELECT COALESCE(SUM(valor), 0), f.animal_id
    INTO v_total, v_animal_id
    FROM fatura_item fi
    JOIN fatura f ON f.id = fi.fatura_id
    WHERE fi.fatura_id = v_fatura_id
    GROUP BY f.animal_id;

    SELECT COALESCE(ps.pct_cobertura, 0) INTO v_plano_pct
    FROM animal_plano ap
    JOIN plano_saude ps ON ps.id = ap.plano_id
    WHERE ap.animal_id = v_animal_id
      AND ap.ativo = TRUE
      AND (ap.vigencia_fim IS NULL OR ap.vigencia_fim >= CURRENT_DATE)
    LIMIT 1;

    v_valor_plano := ROUND(v_total * (v_plano_pct / 100), 2);
    v_valor_cliente := v_total - v_valor_plano;

    UPDATE fatura
    SET valor_total  = v_total,
        valor_plano  = v_valor_plano,
        valor_cliente  = v_valor_cliente
    WHERE id = v_fatura_id;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_recalcular_fatura
AFTER INSERT OR UPDATE OR DELETE ON fatura_item
FOR EACH ROW EXECUTE FUNCTION fn_recalcular_fatura();