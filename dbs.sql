CREATE TABLE livro (
    codigo      SERIAL          PRIMARY KEY,
    titulo      VARCHAR(255)    NOT NULL,
    ano         INTEGER         NOT NULL,
    genero      VARCHAR(100)    NOT NULL,
    total_copias    INTEGER     NOT NULL CHECK (total_copias >= 0),
    disponiveis     INTEGER     NOT NULL CHECK (disponiveis >= 0),
    CONSTRAINT chk_disponiveis_max CHECK (disponiveis <= total_copias)
);

CREATE TABLE autor (
    autor_id        SERIAL          PRIMARY KEY,
    nome            VARCHAR(150)    NOT NULL,
    nacionalidade   VARCHAR(100)    NOT NULL
);

CREATE TABLE livro_autor (
    codigo      INTEGER NOT NULL REFERENCES livro(codigo)   ON DELETE CASCADE,
    autor_id    INTEGER NOT NULL REFERENCES autor(autor_id) ON DELETE CASCADE,
    PRIMARY KEY (codigo, autor_id)
);

CREATE TABLE emprestimo (
    id                  SERIAL          PRIMARY KEY,
    codigo_livro        INTEGER         NOT NULL REFERENCES livro(codigo),
    cliente             VARCHAR(150)    NOT NULL,
    data_emprestimo     DATE            NOT NULL DEFAULT CURRENT_DATE,
    data_devolucao      DATE            NULL,
    CONSTRAINT chk_datas CHECK (
        data_devolucao IS NULL OR data_devolucao >= data_emprestimo
    )
);

-- populando tabelas com exemplos

INSERT INTO autor (nome, nacionalidade) VALUES
    ('Machado de Assis',  'Brasileira'),
    ('Clarice Lispector', 'Brasileira'),
    ('Gabriel García Márquez', 'Colombiana'),
    ('George Orwell',     'Britânica');

INSERT INTO livro (titulo, ano, genero, total_copias, disponiveis) VALUES
    ('Dom Casmurro',                    1899, 'Romance',          4, 4),
    ('A Hora da Estrela',               1977, 'Romance',          3, 3),
    ('Cem Anos de Solidão',             1967, 'Realismo Mágico',  5, 5),
    ('1984',                            1949, 'Distopia',         6, 6),
    ('Memórias Póstumas de Brás Cubas', 1881, 'Romance',          2, 2);

INSERT INTO livro_autor (codigo, autor_id) VALUES
    (1, 1),  -- dom casmurro > machado
    (2, 2),  -- hora da estrela -> clarice
    (3, 3),  -- cem anos -> garcia
    (4, 4),  -- 1984 -> george
    (5, 1);  -- memorias postumas -> machado

INSERT INTO emprestimo (codigo_livro, cliente, data_emprestimo, data_devolucao) VALUES
    (1, 'Ana Paula Souza',   '2025-01-10', '2025-01-24'),
    (3, 'Carlos Mendes',     '2025-02-01', NULL),
    (4, 'Fernanda Lima',     '2025-02-15', NULL);
 
-- ajuste manual pros valores adicionados na mão
UPDATE livro SET disponiveis = disponiveis - 1 WHERE codigo = 3;
UPDATE livro SET disponiveis = disponiveis - 1 WHERE codigo = 4;
