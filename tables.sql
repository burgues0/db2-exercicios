CREATE DATABASE database_clinica;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE tipo_sala          AS ENUM ('consultorio', 'cirurgia', 'internacao', 'exames', 'recepcao');
CREATE TYPE tipo_funcionario   AS ENUM ('veterinario', 'recepcionista', 'auxiliar', 'tecnico_lab');
CREATE TYPE tipo_cliente       AS ENUM ('pf', 'pj');
CREATE TYPE sexo_animal        AS ENUM ('macho', 'femea', 'indefinido');
CREATE TYPE status_animal      AS ENUM ('ativo', 'falecido', 'transferido');
CREATE TYPE status_consulta    AS ENUM ('agendada', 'em_atendimento', 'concluida', 'cancelada');
CREATE TYPE tipo_exame         AS ENUM ('hemograma', 'bioquimico', 'urinalise', 'raio_x', 'ultrassom', 'outro');
CREATE TYPE tipo_movimentacao  AS ENUM ('entrada', 'saida');
CREATE TYPE dose_vacina        AS ENUM ('primeira', 'reforco', 'anual');
CREATE TYPE meio_pagamento     AS ENUM ('dinheiro', 'cartao_credito', 'cartao_debito', 'pix', 'convenio');
CREATE TYPE status_pagamento   AS ENUM ('pendente', 'pago', 'cancelado');
CREATE TYPE tipo_fatura_item   AS ENUM ('consulta', 'exame', 'vacinacao', 'internacao', 'produto');

CREATE TABLE unidade (
    id            SERIAL PRIMARY KEY,
    nome          VARCHAR(100) NOT NULL,
    logradouro    VARCHAR(150) NOT NULL,
    numero        VARCHAR(10)  NOT NULL,
    complemento   VARCHAR(80),
    bairro        VARCHAR(80)  NOT NULL,
    cidade        VARCHAR(80)  NOT NULL,
    estado        CHAR(2)      NOT NULL,
    cep           CHAR(9)      NOT NULL,
    telefone      VARCHAR(20)  NOT NULL,
    email         VARCHAR(120) NOT NULL UNIQUE,
    ativo         BOOLEAN      NOT NULL DEFAULT TRUE,
    criado_em     TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE sala (
    id           SERIAL PRIMARY KEY,
    unidade_id   INT          NOT NULL REFERENCES unidade(id),
    nome         VARCHAR(60)  NOT NULL,
    tipo         tipo_sala    NOT NULL,
    capacidade   SMALLINT     NOT NULL DEFAULT 1,
    ativo        BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE funcionario (
    id              SERIAL PRIMARY KEY,
    unidade_id      INT               NOT NULL REFERENCES unidade(id),
    tipo            tipo_funcionario  NOT NULL,
    nome            VARCHAR(120)      NOT NULL,
    cpf             CHAR(11)          NOT NULL UNIQUE,
    data_nascimento DATE              NOT NULL,
    telefone        VARCHAR(20)       NOT NULL,
    email           VARCHAR(120)      NOT NULL UNIQUE,
    data_admissao   DATE              NOT NULL,
    data_demissao   DATE,
    salario         NUMERIC(10,2)     NOT NULL,
    ativo           BOOLEAN           NOT NULL DEFAULT TRUE,
    criado_em       TIMESTAMP         NOT NULL DEFAULT NOW()
);

CREATE TABLE veterinario (
    funcionario_id  INT          PRIMARY KEY REFERENCES funcionario(id),
    crmv            VARCHAR(20)  NOT NULL UNIQUE,
    crmv_uf         CHAR(2)      NOT NULL,
    crmv_ativo      BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE especialidade (
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE veterinario_especialidade (
    veterinario_id  INT NOT NULL REFERENCES veterinario(funcionario_id),
    especialidade_id INT NOT NULL REFERENCES especialidade(id),
    PRIMARY KEY (veterinario_id, especialidade_id)
);

CREATE TABLE cliente (
    id                  SERIAL PRIMARY KEY,
    tipo                tipo_cliente    NOT NULL,
    cpf                 CHAR(11)        UNIQUE,
    nome                VARCHAR(120),
    data_nascimento     DATE,
    cnpj                CHAR(14)        UNIQUE,
    razao_social        VARCHAR(150),
    responsavel_nome    VARCHAR(120),
    responsavel_cpf     CHAR(11),
    logradouro          VARCHAR(150)    NOT NULL,
    numero              VARCHAR(10)     NOT NULL,
    complemento         VARCHAR(80),
    bairro              VARCHAR(80)     NOT NULL,
    cidade              VARCHAR(80)     NOT NULL,
    estado              CHAR(2)         NOT NULL,
    cep                 CHAR(9)         NOT NULL,
    telefone            VARCHAR(20)     NOT NULL,
    email               VARCHAR(120)    NOT NULL,
    ativo               BOOLEAN         NOT NULL DEFAULT TRUE,
    criado_em           TIMESTAMP       NOT NULL DEFAULT NOW(),
    CONSTRAINT cliente_pf_check CHECK (tipo <> 'pf' OR (cpf IS NOT NULL AND nome IS NOT NULL)),
    CONSTRAINT cliente_pj_check CHECK (tipo <> 'pj' OR (cnpj IS NOT NULL AND razao_social IS NOT NULL AND responsavel_nome IS NOT NULL))
);

CREATE TABLE animal (
    id              SERIAL PRIMARY KEY,
    cliente_id      INT           NOT NULL REFERENCES cliente(id),
    nome            VARCHAR(80)   NOT NULL,
    especie         VARCHAR(40)   NOT NULL,
    raca            VARCHAR(80),
    sexo            sexo_animal   NOT NULL DEFAULT 'indefinido',
    data_nascimento DATE,
    idade_estimada  SMALLINT,
    peso_kg         NUMERIC(5,2),
    cor_pelagem     VARCHAR(80),
    status          status_animal NOT NULL DEFAULT 'ativo',
    observacoes     TEXT,
    criado_em       TIMESTAMP     NOT NULL DEFAULT NOW()
);

CREATE TABLE plano_saude (
    id              SERIAL PRIMARY KEY,
    nome            VARCHAR(100)  NOT NULL,
    operadora       VARCHAR(100)  NOT NULL,
    cobertura_desc  TEXT,
    pct_cobertura   NUMERIC(5,2)  NOT NULL CHECK (pct_cobertura BETWEEN 0 AND 100),
    ativo           BOOLEAN       NOT NULL DEFAULT TRUE
);

CREATE TABLE animal_plano (
    id              SERIAL PRIMARY KEY,
    animal_id       INT          NOT NULL REFERENCES animal(id),
    plano_id        INT          NOT NULL REFERENCES plano_saude(id),
    num_carteirinha VARCHAR(40)  NOT NULL,
    vigencia_inicio DATE         NOT NULL,
    vigencia_fim    DATE,
    ativo           BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE consulta (
    id              SERIAL PRIMARY KEY,
    unidade_id      INT             NOT NULL REFERENCES unidade(id),
    sala_id         INT             NOT NULL REFERENCES sala(id),
    animal_id       INT             NOT NULL REFERENCES animal(id),
    veterinario_id  INT             NOT NULL REFERENCES veterinario(funcionario_id),
    data_hora       TIMESTAMP       NOT NULL,
    status          status_consulta NOT NULL DEFAULT 'agendada',
    anamnese        TEXT,
    exame_fisico    TEXT,
    diagnostico     TEXT,
    recomendacoes   TEXT,
    motivo_cancelamento TEXT,
    cancelado_por   INT             REFERENCES funcionario(id),
    criado_em       TIMESTAMP       NOT NULL DEFAULT NOW()
);

CREATE TABLE medicamento (
    id              SERIAL PRIMARY KEY,
    nome_comercial  VARCHAR(100)  NOT NULL,
    principio_ativo VARCHAR(100)  NOT NULL,
    fabricante      VARCHAR(100),
    apresentacao    VARCHAR(80),
    unidade_medida  VARCHAR(20)   NOT NULL,
    ativo           BOOLEAN       NOT NULL DEFAULT TRUE
);

CREATE TABLE prescricao (
    id              SERIAL PRIMARY KEY,
    consulta_id     INT          NOT NULL REFERENCES consulta(id),
    veterinario_id  INT          NOT NULL REFERENCES veterinario(funcionario_id),
    emitida_em      TIMESTAMP    NOT NULL DEFAULT NOW(),
    observacoes     TEXT
);

CREATE TABLE prescricao_item (
    id              SERIAL PRIMARY KEY,
    prescricao_id   INT           NOT NULL REFERENCES prescricao(id),
    medicamento_id  INT           NOT NULL REFERENCES medicamento(id),
    dose            VARCHAR(40)   NOT NULL,
    frequencia      VARCHAR(60)   NOT NULL,
    duracao_dias    SMALLINT      NOT NULL,
    observacoes     TEXT
);

CREATE TABLE exame (
    id                  SERIAL PRIMARY KEY,
    consulta_id         INT          NOT NULL REFERENCES consulta(id),
    animal_id           INT          NOT NULL REFERENCES animal(id),
    tipo                tipo_exame   NOT NULL,
    solicitado_por      INT          NOT NULL REFERENCES veterinario(funcionario_id),
    realizado_por       INT          REFERENCES funcionario(id),
    data_solicitacao    DATE         NOT NULL DEFAULT CURRENT_DATE,
    data_realizacao     DATE,
    resultado           TEXT,
    laudo               TEXT,
    criado_em           TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE estoque (
    id              SERIAL PRIMARY KEY,
    unidade_id      INT           NOT NULL REFERENCES unidade(id),
    medicamento_id  INT           NOT NULL REFERENCES medicamento(id),
    quantidade      NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (quantidade >= 0),
    lote            VARCHAR(40),
    validade        DATE,
    qtd_minima      NUMERIC(10,2) NOT NULL DEFAULT 5,
    UNIQUE (unidade_id, medicamento_id, lote)
);

CREATE TABLE movimentacao_estoque (
    id              SERIAL PRIMARY KEY,
    estoque_id      INT               NOT NULL REFERENCES estoque(id),
    tipo            tipo_movimentacao NOT NULL,
    quantidade      NUMERIC(10,2)     NOT NULL CHECK (quantidade > 0),
    responsavel_id  INT               NOT NULL REFERENCES funcionario(id),
    observacao      TEXT,
    criado_em       TIMESTAMP         NOT NULL DEFAULT NOW()
);

CREATE TABLE vacina (
    id          SERIAL PRIMARY KEY,
    nome        VARCHAR(100) NOT NULL,
    fabricante  VARCHAR(100),
    doenca_alvo VARCHAR(100)
);

CREATE TABLE vacinacao (
    id                  SERIAL PRIMARY KEY,
    animal_id           INT         NOT NULL REFERENCES animal(id),
    vacina_id           INT         NOT NULL REFERENCES vacina(id),
    aplicado_por        INT         NOT NULL REFERENCES funcionario(id),
    lote                VARCHAR(40) NOT NULL,
    validade_lote       DATE        NOT NULL,
    data_aplicacao      DATE        NOT NULL DEFAULT CURRENT_DATE,
    dose                dose_vacina NOT NULL,
    proxima_dose_prevista DATE,
    observacoes         TEXT
);

CREATE TABLE internacao (
    id              SERIAL PRIMARY KEY,
    animal_id       INT       NOT NULL REFERENCES animal(id),
    unidade_id      INT       NOT NULL REFERENCES unidade(id),
    sala_id         INT       NOT NULL REFERENCES sala(id),
    veterinario_id  INT       NOT NULL REFERENCES veterinario(funcionario_id),
    entrada         TIMESTAMP NOT NULL DEFAULT NOW(),
    saida           TIMESTAMP,
    motivo          TEXT      NOT NULL,
    ativo           BOOLEAN   NOT NULL DEFAULT TRUE
);

CREATE TABLE evolucao_clinica (
    id              SERIAL PRIMARY KEY,
    internacao_id   INT       NOT NULL REFERENCES internacao(id),
    registrado_por  INT       NOT NULL REFERENCES funcionario(id),
    data_hora       TIMESTAMP NOT NULL DEFAULT NOW(),
    descricao       TEXT      NOT NULL
);

CREATE TABLE fatura (
    id              SERIAL PRIMARY KEY,
    cliente_id        INT            NOT NULL REFERENCES cliente(id),
    animal_id       INT            NOT NULL REFERENCES animal(id),
    emitida_em      TIMESTAMP      NOT NULL DEFAULT NOW(),
    valor_total     NUMERIC(10,2)  NOT NULL DEFAULT 0,
    valor_plano     NUMERIC(10,2)  NOT NULL DEFAULT 0,
    valor_cliente     NUMERIC(10,2)  NOT NULL DEFAULT 0,
    desconto        NUMERIC(10,2)  NOT NULL DEFAULT 0,
    desconto_motivo TEXT,
    status          status_pagamento NOT NULL DEFAULT 'pendente'
);

CREATE TABLE fatura_item (
    id              SERIAL PRIMARY KEY,
    fatura_id       INT               NOT NULL REFERENCES fatura(id),
    tipo            tipo_fatura_item  NOT NULL,
    referencia_id   INT               NOT NULL,
    descricao       VARCHAR(200)      NOT NULL,
    valor           NUMERIC(10,2)     NOT NULL
);

CREATE TABLE pagamento (
    id              SERIAL PRIMARY KEY,
    fatura_id       INT              NOT NULL REFERENCES fatura(id),
    meio            meio_pagamento   NOT NULL,
    valor           NUMERIC(10,2)    NOT NULL,
    data_pagamento  TIMESTAMP        NOT NULL DEFAULT NOW(),
    status          status_pagamento NOT NULL DEFAULT 'pendente',
    observacoes     TEXT
);

CREATE TABLE log_prontuario (
    id              SERIAL PRIMARY KEY,
    tabela          VARCHAR(60)  NOT NULL,
    registro_id     INT          NOT NULL,
    operacao        CHAR(6)      NOT NULL CHECK (operacao IN ('INSERT','UPDATE','DELETE')),
    dados_anteriores JSONB,
    dados_novos     JSONB,
    realizado_por   VARCHAR(120),
    realizado_em    TIMESTAMP    NOT NULL DEFAULT NOW()
);