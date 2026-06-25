CREATE ROLE clinica_readonly;
GRANT CONNECT ON DATABASE postgres TO clinica_readonly;
GRANT USAGE ON SCHEMA public TO clinica_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO clinica_readonly;

CREATE ROLE clinica_recepcao;
GRANT clinica_readonly TO clinica_recepcao;
GRANT INSERT, UPDATE ON consulta, fatura, pagamento, fatura_item TO clinica_recepcao;
GRANT INSERT ON cliente, animal TO clinica_recepcao;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO clinica_recepcao;

CREATE ROLE clinica_veterinario;
GRANT clinica_readonly TO clinica_veterinario;
GRANT INSERT, UPDATE ON consulta, exame, prescricao, prescricao_item,
      vacinacao, internacao, evolucao_clinica TO clinica_veterinario;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO clinica_veterinario;

CREATE ROLE clinica_admin;
GRANT ALL PRIVILEGES ON DATABASE postgres TO clinica_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO clinica_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO clinica_admin;

CREATE USER recepcionista_01 LOGIN PASSWORD 'Senha#2024!' IN ROLE clinica_recepcao;
CREATE USER dr_carlos LOGIN PASSWORD 'Senha#2024!' IN ROLE clinica_veterinario;

ALTER TABLE consulta ENABLE ROW LEVEL SECURITY;

CREATE POLICY consulta_por_unidade ON consulta
    USING (unidade_id = current_setting('app.unidade_id')::INT);