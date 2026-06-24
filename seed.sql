INSERT INTO unidade (nome, logradouro, numero, complemento, bairro, cidade, estado, cep, telefone, email) VALUES
('Unidade Copacabana',  'Rua Barata Ribeiro',   '320', 'Sala 1',  'Copacabana',   'Rio de Janeiro', 'RJ', '22040-000', '(21) 3001-1001', 'copa@exemplo.com'),
('Unidade Barra',       'Av. das Américas',     '4666','Loja 12', 'Barra da Tijuca','Rio de Janeiro','RJ', '22640-102', '(21) 3001-1002', 'barra@exemplo.com'),
('Unidade Niterói',     'Rua Visconde do Rio Branco','80', NULL,  'Centro',       'Niterói',        'RJ', '24020-005', '(21) 3001-1003', 'niteroi@exemplo.com');

INSERT INTO sala (unidade_id, nome, tipo, capacidade) VALUES
(1, 'Consultório 1',     'consultorio', 1),
(1, 'Consultório 2',     'consultorio', 1),
(1, 'Sala de Cirurgia',  'cirurgia',    1),
(1, 'Internação A',      'internacao',  8),
(1, 'Laboratório',       'exames',      1),
(2, 'Consultório 1',     'consultorio', 1),
(2, 'Consultório 2',     'consultorio', 1),
(2, 'Sala de Cirurgia',  'cirurgia',    1),
(2, 'Internação B',      'internacao',  6),
(3, 'Consultório 1',     'consultorio', 1),
(3, 'Internação C',      'internacao',  4);

INSERT INTO funcionario (unidade_id, tipo, nome, cpf, data_nascimento, telefone, email, data_admissao, salario) VALUES
(1,'veterinario',   'Dra. Ana Lima',        '11122233344','1985-03-12','(21)99001-1111','ana.lima@exemplo.com',       '2018-01-10', 8500.00),
(1,'veterinario',   'Dr. Carlos Mota',      '22233344455','1979-07-25','(21)99001-2222','carlos.mota@exemplo.com',    '2019-05-15', 9000.00),
(1,'auxiliar',      'Julia Ferreira',       '33344455566','1995-11-02','(21)99001-3333','julia.ferreira@exemplo.com', '2021-03-01', 3200.00),
(1,'recepcionista', 'Marcos Souza',         '44455566677','1993-06-18','(21)99001-4444','marcos.souza@exemplo.com',   '2020-08-20', 2800.00),
(1,'tecnico_lab',   'Fernanda Costa',       '55566677788','1990-09-30','(21)99001-5555','fernanda.costa@exemplo.com', '2022-02-14', 3600.00),
(2,'veterinario',   'Dr. Rafael Andrade',   '66677788899','1988-01-08','(21)99002-1111','rafael.andrade@exemplo.com', '2017-11-01', 9200.00),
(2,'veterinario',   'Dra. Patricia Nunes',  '77788899900','1991-04-22','(21)99002-2222','patricia.nunes@exemplo.com', '2021-07-10', 8700.00),
(2,'recepcionista', 'Lucas Pereira',        '88899900011','1997-12-05','(21)99002-3333','lucas.pereira@exemplo.com',  '2022-09-01', 2800.00),
(3,'veterinario',   'Dra. Camila Rocha',    '99900011122','1983-08-17','(21)99003-1111','camila.rocha@exemplo.com',   '2016-04-20', 9500.00),
(3,'auxiliar',      'Thiago Alves',         '10011122233','1998-02-28','(21)99003-2222','thiago.alves@exemplo.com',   '2023-01-15', 3100.00);

INSERT INTO veterinario (funcionario_id, crmv, crmv_uf, crmv_ativo) VALUES
(1,  'CRMV-RJ 12345', 'RJ', TRUE),
(2,  'CRMV-RJ 23456', 'RJ', TRUE),
(6,  'CRMV-RJ 34567', 'RJ', TRUE),
(7,  'CRMV-RJ 45678', 'RJ', TRUE),
(9,  'CRMV-RJ 56789', 'RJ', TRUE);

INSERT INTO especialidade (nome) VALUES
('Clínica Geral'),
('Ortopedia'),
('Dermatologia'),
('Oftalmologia'),
('Oncologia'),
('Cardiologia');

INSERT INTO veterinario_especialidade (veterinario_id, especialidade_id) VALUES
(1, 1),(1, 3),
(2, 1),(2, 2),
(6, 1),(6, 4),
(7, 1),(7, 5),
(9, 1),(9, 6);

INSERT INTO cliente (tipo, cpf, nome, data_nascimento, logradouro, numero, bairro, cidade, estado, cep, telefone, email) VALUES
('pf','12312312300','Maria Aparecida Santos','1980-05-14','Rua das Flores','10','Copacabana','Rio de Janeiro','RJ','22020-010','(21)98001-1001','maria.santos@cliente.com'),
('pf','23423423411','João Paulo Oliveira',   '1975-09-03','Av. Atlântica','500','Copacabana','Rio de Janeiro','RJ','22010-000','(21)98001-1002','joao.oliveira@cliente.com'),
('pf','34534534522','Beatriz Carvalho',      '1992-12-21','Rua Garcia D Ávila','90','Ipanema','Rio de Janeiro','RJ','22421-010','(21)98001-1003','beatriz.carvalho@cliente.com'),
('pf','45645645633','Roberto Mendes',        '1965-04-30','Rua Almirante Cochrane','201','Tijuca','Rio de Janeiro','RJ','20550-010','(21)98001-1004','roberto.mendes@cliente.com'),
('pf','56756756744','Sandra Lima',           '1988-07-19','Av. das Américas','3000','Barra da Tijuca','Rio de Janeiro','RJ','22640-100','(21)98001-1005','sandra.lima@cliente.com');

INSERT INTO cliente (tipo, cnpj, razao_social, responsavel_nome, responsavel_cpf, logradouro, numero, bairro, cidade, estado, cep, telefone, email) VALUES
('pj','12345678000100','ONG Exemplo','Ana Beatriz Torres','67867867855','Rua do Catete','180','Catete','Rio de Janeiro','RJ','22220-000','(21)98002-2001','ong@cliente.com');

INSERT INTO animal (cliente_id, nome, especie, raca, sexo, data_nascimento, peso_kg, cor_pelagem, status) VALUES
(1,'Bolinha',  'Cão',  'Labrador Retriever','macho', '2018-03-10', 28.5, 'Amarelo',        'ativo'),
(1,'Mimi',     'Gato', 'Persa',             'femea', '2020-06-15', 4.2,  'Branco e cinza', 'ativo'),
(2,'Thor',     'Cão',  'Rottweiler',        'macho', '2017-11-22', 42.0, 'Preto e marrom', 'ativo'),
(3,'Tinker',   'Gato', 'Siamês',            'femea', '2021-01-05', 3.8,  'Seal point',     'ativo'),
(4,'Max',      'Cão',  'Pastor Alemão',     'macho', '2016-08-14', 35.0, 'Preto e marrom', 'ativo'),
(5,'Luna',     'Cão',  'Golden Retriever',  'femea', '2022-02-28', 22.0, 'Dourado',        'ativo'),
(6,'Bigode',   'Gato', 'SRD',               'macho', '2019-09-01', 5.1,  'Rajado laranja', 'ativo'),
(6,'Princesa', 'Cão',  'Shih-tzu',          'femea', '2020-04-12', 5.8,  'Branco',         'ativo');

INSERT INTO plano_saude (nome, operadora, cobertura_desc, pct_cobertura) VALUES
('PetPlan Básico',   'PetPlan',  'Consultas e vacinas',                       50.00),
('PetPlan Premium',  'PetPlan',  'Consultas, vacinas, exames e cirurgias',    80.00),
('VidaPet Completo', 'VidaPet',  'Cobertura total incluindo internação',      90.00);

INSERT INTO animal_plano (animal_id, plano_id, num_carteirinha, vigencia_inicio, vigencia_fim) VALUES
(1, 2, 'PP-2024-0001', '2024-01-01', '2026-12-31'),
(3, 1, 'PP-2024-0002', '2024-03-01', '2026-12-31'),
(6, 3, 'VP-2024-0001', '2024-01-01', '2026-12-31');

INSERT INTO consulta (unidade_id, sala_id, animal_id, veterinario_id, data_hora, status, anamnese, exame_fisico, diagnostico, recomendacoes) VALUES
(1,1,1,1,'2024-03-05 09:00','concluida','Cliente relata coceira excessiva e queda de pelo.','Pele ressecada, pelos opacos. Sem lesões abertas.','Dermatite alérgica','Ração hipoalergênica e shampoo medicamentoso. Retorno em 30 dias.'),
(1,2,3,2,'2024-06-12 10:30','concluida','Animal mancando da pata traseira direita há 3 dias.','Dor à palpação do joelho direito. Sem fratura aparente.','Lesão de ligamento cruzado cranial suspeita','Repouso absoluto. Solicitar raio-x.'),
(1,1,2,1,'2024-08-20 14:00','concluida','Consulta de rotina. Animal saudável.','Peso 4,2 kg. Mucosas rosadas. Ausculta normal.','Sem alterações','Manter vacinação em dia. Próxima consulta em 6 meses.'),
(2,6,5,6,'2024-11-07 08:30','concluida','Cliente relata olho direito lacrimejando excessivamente.','Epífora unilateral. Sem sinais de uveíte.','Conjuntivite bacteriana','Colírio antibiótico 3x ao dia por 7 dias.'),
(2,7,6,7,'2024-12-03 11:00','concluida','Consulta de vacinação anual.','Animal saudável. Peso 22 kg.','Sem alterações','Aplicar V10 e antirrábica.'),
(1,1,4,1,'2025-02-14 09:00','concluida','Animal com vômitos frequentes há 2 dias.','Abdômen levemente sensível. Mucosas normocoradas.','Gastroenterite aguda','Dieta hipossódica por 5 dias. Retorno se piorar.'),
(2,6,8,6,'2025-04-22 10:00','concluida','Consulta de rotina pós-castração.','Cicatriz em boa evolução. Sem sinais de infecção.','Sem alterações','Alta. Retorno em 30 dias para retirada de pontos.'),
(1,2,5,2,'2025-07-09 14:30','concluida','Animal apresentando nódulo em membro anterior.','Nódulo de aproximadamente 2cm, móvel, sem dor.','Lipoma suspeito','Solicitar citologia. Monitorar crescimento.'),
(3,10,7,9,'2025-09-18 08:00','concluida','Queda de pelo e prurido intenso.','Alopecia bilateral simétrica. Pele hiperpigmentada.','Hipotireoidismo suspeito','Solicitar T4 e hemograma. Retorno em 15 dias.'),
(2,7,1,7,'2025-11-25 11:00','concluida','Retorno dermatológico. Melhora parcial.','Pele menos ressecada. Redução da queda de pelo.','Dermatite alérgica em controle','Manter medicação. Reavaliar em 60 dias.'),
(1,1,3,1,'2026-01-13 09:30','concluida','Dor ao caminhar, piora no frio.','Crepitação no joelho direito. Dor à extensão.','Artrose em progressão','Anti-inflamatório contínuo. Fisioterapia recomendada.'),
(1,2,2,2,'2026-03-04 10:00','concluida','Animal sem apetite há 4 dias.','Mucosas levemente pálidas. Perda de 0,3 kg.','Anemia leve','Suplemento de ferro. Hemograma de controle em 30 dias.'),
(2,6,6,6,'2026-05-19 08:30','concluida','Vacinação anual e checkup.','Animal saudável. Peso 23 kg.','Sem alterações','Vacinas aplicadas. Próximo checkup em 12 meses.'),
(1,1,4,1,'2026-06-24 09:30','agendada', NULL, NULL, NULL, NULL),
(1,2,7,2,'2026-06-24 10:00','agendada', NULL, NULL, NULL, NULL);

INSERT INTO medicamento (nome_comercial, principio_ativo, fabricante, apresentacao, unidade_medida) VALUES
('Apoquel 16mg',    'Oclacitinibe',    'Zoetis',  'Comprimido',  'comprimido'),
('Amoxicilina 500', 'Amoxicilina',     'Genérico','Cápsula',     'cápsula'),
('Prednisolona 5mg','Prednisolona',    'Vetnil',  'Comprimido',  'comprimido'),
('Tobrex colírio',  'Tobramicina',     'Alcon',   'Solução 5ml', 'gota'),
('Dipirona Vet',    'Dipirona sódica', 'Agener',  'Solução oral','ml');

INSERT INTO prescricao (consulta_id, veterinario_id) VALUES
(1, 1),
(4, 6);

INSERT INTO prescricao_item (prescricao_id, medicamento_id, dose, frequencia, duracao_dias, observacoes) VALUES
(1, 1, '16mg', '1x ao dia', 30, 'Administrar junto com a alimentação'),
(2, 4, '2 gotas', '3x ao dia', 7,  'No olho direito. Lavar antes de aplicar.');

INSERT INTO exame (consulta_id, animal_id, tipo, solicitado_por, realizado_por, data_solicitacao, data_realizacao, resultado, laudo) VALUES
(2, 3, 'raio_x',    2, 5, '2024-06-12', '2024-06-13', 'Imagem sem fratura óssea visível. Espaço articular reduzido.', 'Suspeita de ruptura parcial de ligamento cruzado cranial. Recomenda-se avaliação ortopédica.'),
(3, 2, 'hemograma', 1, 5, '2024-08-20', '2024-08-21', 'Eritrócitos 8.1 M/uL, Hematócrito 42%, Leucócitos 9.5 mil/uL', 'Hemograma dentro dos parâmetros normais para a espécie.');

INSERT INTO estoque (unidade_id, medicamento_id, quantidade, lote, validade, qtd_minima) VALUES
(1, 1, 50,  'L2024A', '2027-06-30', 10),
(1, 2, 100, 'L2024B', '2027-01-31', 20),
(1, 3, 80,  'L2024C', '2024-12-31', 15),
(1, 4, 30,  'L2024D', '2025-03-31', 5),
(1, 5, 60,  'L2024E', '2025-08-31', 10),
(2, 1, 40,  'L2024A', '2025-06-30', 10),
(2, 2, 200, 'L2024B', '2027-01-31', 20),
(2, 3, 80,  'L2024C', '2027-12-31', 15),
(2, 4, 20,  'L2024D', '2025-03-31', 5);

INSERT INTO movimentacao_estoque (estoque_id, tipo, quantidade, responsavel_id, observacao) VALUES
(1, 'entrada', 50, 4, 'Compra inicial de estoque'),
(2, 'entrada', 100, 4, 'Compra inicial de estoque'),
(1, 'saida',   2,  1, 'Dispensado para prescrição consulta #1');

INSERT INTO vacina (nome, fabricante, doenca_alvo) VALUES
('V10 Canina',    'Zoetis',    'Cinomose, Parvovirose, Hepatite, Leptospirose e outras'),
('Antirrábica',   'MSD Animal','Raiva'),
('V4 Felina',     'Merial',    'Panleucopenia, Rinotraqueíte, Calicivirose, Clamidiose'),
('FeLV',          'Zoetis',    'Leucemia Felina');

INSERT INTO vacinacao (animal_id, vacina_id, aplicado_por, lote, validade_lote, data_aplicacao, dose, proxima_dose_prevista) VALUES
(6, 1, 7, 'VAC2024-001', '2027-12-31', '2024-12-03', 'anual',   '2025-12-03'),
(6, 2, 7, 'RAB2024-001', '2028-01-31', '2024-12-03', 'anual',   '2025-12-03'),
(1, 1, 1, 'VAC2025-001', '2027-12-31', '2025-11-25', 'anual',   '2026-11-25'),
(2, 3, 1, 'FEL2025-001', '2027-11-30', '2025-02-14', 'reforco', '2026-02-14'),
(3, 1, 2, 'VAC2026-001', '2028-06-30', '2026-05-19', 'anual',   '2027-05-19'),
(5, 2, 6, 'RAB2025-001', '2028-01-31', '2025-04-22', 'anual',   '2026-07-10');

INSERT INTO internacao (animal_id, unidade_id, sala_id, veterinario_id, entrada, saida, motivo, ativo) VALUES
(3, 1, 4, 2, '2024-06-13 08:00', '2024-06-16 17:00', 'Pós-operatório de ortopedia', FALSE),
(5, 2, 9, 6, '2025-07-10 10:00', '2025-07-14 09:00', 'Tratamento de pneumonia',     FALSE),
(2, 1, 4, 1, '2026-06-20 08:00', NULL,                'Suporte para anemia aguda',   TRUE);

INSERT INTO evolucao_clinica (internacao_id, registrado_por, data_hora, descricao) VALUES
(1, 2, '2024-06-13 18:00', 'Animal estável pós-cirurgia. Sem febre. Analgesia mantida.'),
(1, 3, '2024-06-14 08:00', 'Boa aceitação de alimento. Membro imobilizado, sem edema.'),
(1, 2, '2024-06-16 08:00', 'Animal em excelente recuperação. Alta médica concedida.'),
(2, 6, '2025-07-10 18:00', 'Temperatura 39.8°C. Iniciado antibioticoterapia IV.'),
(2, 6, '2025-07-11 09:00', 'Melhora discreta. Temperatura 39.2°C. Mantendo protocolo.'),
(2, 6, '2025-07-14 08:00', 'Animal estável. Alta concedida com antibiótico oral.'),
(3, 1, '2026-06-20 18:00', 'Transfusão realizada. Animal respondendo bem. Monitorando.'),
(3, 1, '2026-06-21 09:00', 'Mucosas com melhor coloração. Mantendo suporte nutricional.');

INSERT INTO fatura (cliente_id, animal_id, valor_total, valor_plano, valor_cliente, status) VALUES
(2, 3, 350.00, 175.00, 175.00, 'pago'),
(1, 1, 280.00,   0.00, 280.00, 'pago'),
(5, 6, 180.00, 144.00,  36.00, 'pago'),
(4, 5, 320.00,   0.00, 320.00, 'pago'),
(1, 2, 410.00,   0.00, 410.00, 'pago'),
(3, 4, 150.00,   0.00, 150.00, 'pago'),
(2, 3, 520.00, 260.00, 260.00, 'pago'),
(5, 6, 200.00, 160.00,  40.00, 'pago'),
(1, 1, 310.00,   0.00, 310.00, 'pendente'),
(1, 2, 480.00,   0.00, 480.00, 'pendente');

INSERT INTO fatura_item (fatura_id, tipo, referencia_id, descricao, valor) VALUES
(1, 'consulta', 2, 'Consulta ortopédica - Thor', 200.00),
(1, 'exame',    1, 'Raio-X joelho - Thor',        150.00),
(2, 'consulta', 1, 'Consulta dermatológica - Bolinha', 280.00),
(3, 'vacinacao',1, 'V10 + Antirrábica - Luna',    180.00),
(4, 'consulta', 4, 'Consulta oftalmológica - Max', 220.00),
(4, 'exame',    2, 'Hemograma - Max',              100.00),
(5, 'consulta', 6, 'Consulta gastroenterite - Mimi', 260.00),
(5, 'internacao',1,'Internação 3 dias - Mimi',     150.00),
(6, 'consulta', 9, 'Consulta dermatológica - Tinker', 150.00),
(7, 'consulta',11, 'Consulta artrose - Thor',      280.00),
(7, 'exame',    1, 'Raio-X joelho follow-up - Thor', 240.00),
(8, 'vacinacao',5, 'V10 + checkup - Luna',         200.00),
(9, 'consulta',10, 'Retorno dermatológico - Bolinha', 310.00),
(10,'consulta',12, 'Consulta anemia - Mimi',       280.00),
(10,'internacao',3,'Internação suporte anemia - Mimi', 200.00);

INSERT INTO pagamento (fatura_id, meio, valor, status) VALUES
(1, 'cartao_credito', 175.00, 'pago'),
(1, 'convenio',       175.00, 'pago'),
(2, 'pix',            280.00, 'pago'),
(3, 'cartao_debito',   36.00, 'pago'),
(3, 'convenio',       144.00, 'pago'),
(4, 'pix',            320.00, 'pago'),
(5, 'cartao_credito', 410.00, 'pago'),
(6, 'dinheiro',       150.00, 'pago'),
(7, 'cartao_credito', 260.00, 'pago'),
(7, 'convenio',       260.00, 'pago'),
(8, 'pix',             40.00, 'pago'),
(8, 'convenio',       160.00, 'pago'),
(9, 'pix',            310.00, 'pendente'),
(10,'cartao_debito',  480.00, 'pendente');