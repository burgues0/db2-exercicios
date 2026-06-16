# Minimundo | Sistema de Gestão de Clínicas Veterinárias

## Cenário

Uma rede de clinicas veterinárias quer modernizar sua operação por meio de um sistema de banco de dados centralizado. A rede tem diversas unidades espalhadas por diferentes cidades e precisa gerenciar de forma integrada todos os aspectos do negócio: cadastro de animais e clientes, agenda de consultas, internações, exames, prescrições, estoque de medicamentos, vacinações, funcionários e faturamento.

1. Unidades e Estrutura Física
Essa rede opera com diversas unidades clínicas. Cada unidade possui um endereço completo (logradouro, número, complemento, bairro, cidade, estado e CEP), telefone de contato, e-mail institucional e um gerente responsável. Cada unidade conta com um conjunto de salas (consultórios, sala de cirurgia, sala de internação e sala de exames), sendo que cada sala possui um identificador, um tipo e uma capacidade máxima de ocupação.

2. Funcionários
As clinicas empregam diferentes perfis de profissionais: veterinários, recepcionistas, auxiliares veterinários e técnicos de laboratório. Todo funcionário possui CPF, nome completo, data de nascimento, telefone, e-mail, data de admissão, salário e a unidade à qual está vinculado. Veterinários possuem adicionalmente o número do CRMV e podem ter uma ou mais especialidades (clínica geral, ortopedia, dermatologia, oftalmologia, oncologia.

3. Clientes
Os clientes são as pessoas responsaveis pelos animais atendidos. Podem ser pessoa física (CPF, nome, data de nascimento) ou PJ (CNPJ, razão social). Todo cliente possui endereço, telefone principal, e-mail e data de cadastro no sistema. Um cliente pode ter múltiplos animais registrados.

4. Animais (Pacientes)
Cada animal é identificado por um código interno único. Os dados cadastrais incluem: nome, espécie (cão, gato, ave, réptil, etc.), raça, sexo, data de nascimento (ou idade estimada), peso, cor/pelagem e status (ativo, falecido, transferido). O animal está sempre associado a um cliente responsável. Animais podem ter histórico de alergias e condições crônicas registradas como observações clínicas.

5. Consultas
As consultas são o principal serviço da clínica. Cada consulta é agendada com data e hora, associada a um animal, a um veterinário responsável, a uma sala e a uma unidade. O status da consulta pode ser: agendada, em atendimento, concluída ou cancelada. Ao final do atendimento, o veterinário registra a anamnese (relato do cliente), o exame físico realizado, o diagnóstico e as recomendações. Uma consulta pode gerar prescrições e/ou solicitação de exames.

6. Exames
A clínica realiza exames laboratoriais e de imagem (raio-x, ultrassom. Cada exame possui um tipo (hemograma, bioquímico, urinalise, raio-x, ultrassonografia), data de solicitação, data de realização, resultado, o profissional que realizou e o profissional que solicitou. O resultado pode ter um laudo textual descritivo. Exames são sempre vinculados a uma consulta e a um animal.

7. Prescrições e Medicamentos
Uma prescrição e emitida por um veterinario ao final de uma consulta. Ela contem um ou mais itens, cada item referenciando um medicamento, com posologia (dose, frequência e duração do tratamento) e observações adicionais. O sistema mantém um catalogo de medicamentos com nome comercial, principio ativo, fabricante, apresentação (comprimido, solução) e unidade de medida.

8. Estoque de Medicamentos
Cada unidade possui seu próprio estoque. O estoque registra o medicamento, a unidade, a quantidade disponível, o lote, a data de validade e o ponto de reposição mínimo. Quando a quantidade cai abaixo do mínimo o sistema deve sinalizar a necessidade de reposição. Movimentações de estoque (entrada por compra, saída por uso em internação/cirurgia) são registradas com data, tipo de movimentação, quantidade e responsável.

9. Vacinação
A clínica oferece serviço de vacinação. Cada vacinação registra o animal, a vacina aplicada (nome, fabricante, lote, validade), a data de aplicação, a dose (primeira, reforço, anual), o veterinário ou auxiliar responsável e a data prevista para a próxima dose. O sistema deve alertar quando a proxima dose estiver próxima.

10. Internação
Animais podem ser internados na clínica. Cada internação possui data e hora de entrada, data e hora de saída (quando houver), o animal, a sala de internação, o veterinário responsável pelo acompanhamento e o motivo da internação. Durante a internação são registradas evoluções clínicas diarias com data, hora, descrição e profissional responsavel pelo registro.

11. Planos de Saúde
As clinicas possuem convênios com operadoras de planos de saúde animal. Cada plano possui nome, operadora, cobertura (lista de procedimentos cobertos) e percentual de cobertura. Um animal pode estar associado a um plano, com número de carteirinha e data de vigência. Na geração do faturamento, o sistema deve calcular o valor de responsabilidade do plano e o valor do cliente.

12. Faturamento e Pagamentos
Cada atendimento (consulta, exame, vacinação, internação) gera um item de fatura. A fatura é consolidada por animal/cliente e pode ser paga de uma vez ou parcelada. Os meios de pagamento aceitos são: dinheiro, cartão de crédito, cartão de débito, PIX e convênio. Cada pagamento registra data, valor, meio de pagamento e status (pendente, pago, cancelado). Descontos podem ser aplicados manualmente com justificativa.

---

## Regras de Negócio

1. Um animal só pode ser cadastrado se possuir um cliente ativo vinculado.
2. Uma consulta só pode ser agendada se o veterinário estiver disponível no horário (sem sobreposição de agenda).
3. Uma sala não pode ser utilizada por duas consultas ou internações ao mesmo tempo.
4. Somente veterinários com CRMV ativo podem emitir prescrições e laudos.
5. O estoque não pode ter quantidade negativa; a saída só é registrada se houver saldo disponível.
6. Animais com internação ativa não podem ter alta sem registro de evolução clínica no mesmo dia.
7. Vacinas com lote vencido não podem ser aplicadas.
8. O cancelamento de uma consulta deve registrar o motivo e o usuário responsável pelo cancelamento.
9. Pagamentos só podem ser marcados como "pago" após confirmação do valor recebido.
10. Funcionários desligados não podem realizar novos atendimentos, mas seu histórico deve ser preservado.
11. Um cliente PJ deve obrigatoriamente ter um responsável (pessoa física) associado para contato.
12. O sistema deve manter log de todas as alterações em prontuários de animais (auditoria).

---

## Entidades Principais

Unidade: Filial da clínica
Sala: Espaço físico dentro da unidade
Funcionario: Colaboradores da clínica
Veterinario: Subtipo de Funcionario com CRMV e especialidades
Cliente: Cliente responsável pelo animal (PF ou PJ)
Animal: Paciente da clínica
Consulta: Atendimento clínico agendado
Exame: Exame solicitado e realizado
Prescricao: Receita emitida em uma consulta
Medicamento: Catálogo de medicamentos
Estoque: Controle de medicamentos por unidade
Vacinacao: Registro de vacinas aplicadas
Internacao: Hospitalização do animal
EvolucaoClinica: Evolução diária de animais internados
PlanoSaude: Planos conveniados
Fatura: Documento financeiro por atendimento
Pagamento: Registro de pagamentos
LogProntuario: Auditoria de alterações em prontuários
