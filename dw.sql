-- datawarehouse.sql

CREATE TABLE dim_tempo (
    sk_tempo        SERIAL PRIMARY KEY,
    data_completa   DATE         NOT NULL UNIQUE,
    mes             SMALLINT     NOT NULL,
    nome_mes        VARCHAR(20)  NOT NULL,
    trimestre       SMALLINT     NOT NULL,
    ano             SMALLINT     NOT NULL
);

CREATE TABLE dim_unidade (
    sk_unidade      SERIAL PRIMARY KEY,
    id_unidade_orig INT          NOT NULL,
    nome            VARCHAR(100) NOT NULL,
    cidade          VARCHAR(80)  NOT NULL
);

CREATE TABLE dim_animal (
    sk_animal       SERIAL PRIMARY KEY,
    id_animal_orig  INT          NOT NULL,
    nome            VARCHAR(80)  NOT NULL,
    especie         VARCHAR(40)  NOT NULL,
    cliente_nome    VARCHAR(120)
);

CREATE TABLE dim_veterinario (
    sk_veterinario      SERIAL PRIMARY KEY,
    id_funcionario_orig INT          NOT NULL,
    nome                VARCHAR(120) NOT NULL
);

CREATE TABLE dim_medicamento (
    sk_medicamento      SERIAL PRIMARY KEY,
    id_medicamento_orig INT          NOT NULL,
    nome_comercial      VARCHAR(100) NOT NULL
);

CREATE TABLE fato_atendimento (
    sk_atendimento  SERIAL PRIMARY KEY,
    sk_tempo        INT NOT NULL REFERENCES dim_tempo(sk_tempo),
    sk_unidade      INT NOT NULL REFERENCES dim_unidade(sk_unidade),
    sk_animal       INT NOT NULL REFERENCES dim_animal(sk_animal),
    sk_veterinario  INT NOT NULL REFERENCES dim_veterinario(sk_veterinario),
    qtd_atendimentos SMALLINT NOT NULL DEFAULT 1
);

CREATE TABLE fato_financeiro (
    sk_financeiro   SERIAL PRIMARY KEY,
    sk_tempo        INT NOT NULL REFERENCES dim_tempo(sk_tempo),
    sk_unidade      INT NOT NULL REFERENCES dim_unidade(sk_unidade),
    sk_animal       INT NOT NULL REFERENCES dim_animal(sk_animal),
    valor_bruto     NUMERIC(10,2) NOT NULL DEFAULT 0,
    valor_plano     NUMERIC(10,2) NOT NULL DEFAULT 0,
    valor_cliente   NUMERIC(10,2) NOT NULL DEFAULT 0
);

CREATE TABLE fato_estoque (
    sk_estoque          SERIAL PRIMARY KEY,
    sk_tempo            INT NOT NULL REFERENCES dim_tempo(sk_tempo),
    sk_unidade          INT NOT NULL REFERENCES dim_unidade(sk_unidade),
    sk_medicamento      INT NOT NULL REFERENCES dim_medicamento(sk_medicamento),
    quantidade_saida    NUMERIC(10,2) NOT NULL DEFAULT 0,
    saldo_final         NUMERIC(10,2) NOT NULL DEFAULT 0
);

-- carga das dimensões a partir do banco transacional
INSERT INTO dim_tempo (data_completa, mes, nome_mes, trimestre, ano)
SELECT DISTINCT
    data_hora::DATE,
    EXTRACT(MONTH FROM data_hora)::SMALLINT,
    TO_CHAR(data_hora, 'TMMonth'),
    EXTRACT(QUARTER FROM data_hora)::SMALLINT,
    EXTRACT(YEAR FROM data_hora)::SMALLINT
FROM consulta;

INSERT INTO dim_unidade (id_unidade_orig, nome, cidade)
SELECT id, nome, cidade FROM unidade;

INSERT INTO dim_animal (id_animal_orig, nome, especie, cliente_nome)
SELECT a.id, a.nome, a.especie, cl.nome
FROM animal a
JOIN cliente cl ON cl.id = a.cliente_id;

INSERT INTO dim_veterinario (id_funcionario_orig, nome)
SELECT f.id, f.nome
FROM funcionario f
JOIN veterinario v ON v.funcionario_id = f.id;

INSERT INTO dim_medicamento (id_medicamento_orig, nome_comercial)
SELECT id, nome_comercial FROM medicamento;

-- carga do fato de atendimento
INSERT INTO fato_atendimento (sk_tempo, sk_unidade, sk_animal, sk_veterinario)
SELECT dt.sk_tempo, du.sk_unidade, da.sk_animal, dv.sk_veterinario
FROM consulta c
JOIN dim_tempo dt       ON dt.data_completa = c.data_hora::DATE
JOIN dim_unidade du     ON du.id_unidade_orig = c.unidade_id
JOIN dim_animal da      ON da.id_animal_orig = c.animal_id
JOIN dim_veterinario dv ON dv.id_funcionario_orig = c.veterinario_id;

-- carga do fato financeiro
INSERT INTO fato_financeiro (sk_tempo, sk_unidade, sk_animal, valor_bruto, valor_plano, valor_cliente)
SELECT dt.sk_tempo, du.sk_unidade, da.sk_animal, f.valor_total, f.valor_plano, f.valor_cliente
FROM fatura f
JOIN animal a       ON a.id = f.animal_id
JOIN dim_animal da  ON da.id_animal_orig = a.id
JOIN dim_tempo dt   ON dt.data_completa = f.emitida_em::DATE
JOIN consulta c     ON c.animal_id = a.id
JOIN dim_unidade du ON du.id_unidade_orig = c.unidade_id;

-- carga do fato de estoque
INSERT INTO fato_estoque (sk_tempo, sk_unidade, sk_medicamento, quantidade_saida, saldo_final)
SELECT dt.sk_tempo, du.sk_unidade, dm.sk_medicamento, me.quantidade, e.quantidade
FROM movimentacao_estoque me
JOIN estoque e          ON e.id = me.estoque_id
JOIN dim_unidade du      ON du.id_unidade_orig = e.unidade_id
JOIN dim_medicamento dm  ON dm.id_medicamento_orig = e.medicamento_id
JOIN dim_tempo dt        ON dt.data_completa = me.criado_em::DATE
WHERE me.tipo = 'saida';