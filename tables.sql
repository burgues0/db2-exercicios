CREATE DATABASE database_clinica;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE tipo_sala          AS ENUM ('consultorio', 'cirurgia', 'internacao', 'exames', 'recepcao');
CREATE TYPE tipo_funcionario   AS ENUM ('veterinario', 'recepcionista', 'auxiliar', 'tecnico_lab');
CREATE TYPE tipo_tutor         AS ENUM ('pf', 'pj');
CREATE TYPE sexo_animal        AS ENUM ('macho', 'femea', 'indefinido');
CREATE TYPE status_animal      AS ENUM ('ativo', 'falecido', 'transferido');
CREATE TYPE status_consulta    AS ENUM ('agendada', 'em_atendimento', 'concluida', 'cancelada');
CREATE TYPE tipo_exame         AS ENUM ('hemograma', 'bioquimico', 'urinalise', 'raio_x', 'ultrassom', 'outro');
CREATE TYPE tipo_movimentacao  AS ENUM ('entrada', 'saida');
CREATE TYPE dose_vacina        AS ENUM ('primeira', 'reforco', 'anual');
CREATE TYPE meio_pagamento     AS ENUM ('dinheiro', 'cartao_credito', 'cartao_debito', 'pix', 'convenio');
CREATE TYPE status_pagamento   AS ENUM ('pendente', 'pago', 'cancelado');
CREATE TYPE tipo_fatura_item   AS ENUM ('consulta', 'exame', 'vacinacao', 'internacao', 'produto');