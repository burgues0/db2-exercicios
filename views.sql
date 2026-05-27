CREATE OR REPLACE VIEW vw_catalogo_livros AS
SELECT
    l.codigo,
    l.titulo,
    l.ano,
    l.genero,
    l.total_copias,
    l.disponiveis,
    STRING_AGG(a.nome || ' (' || a.nacionalidade || ')', ', '
               ORDER BY a.nome) AS autores
FROM livro l
LEFT JOIN livro_autor la ON la.codigo    = l.codigo
LEFT JOIN autor        a  ON a.autor_id  = la.autor_id
GROUP BY l.codigo, l.titulo, l.ano, l.genero, l.total_copias, l.disponiveis;

CREATE OR REPLACE VIEW vw_emprestimos_ativos AS
SELECT
    e.id                AS emprestimo_id,
    l.codigo            AS codigo_livro,
    l.titulo,
    e.cliente,
    e.data_emprestimo,
    (CURRENT_DATE - e.data_emprestimo) AS dias_em_aberto
FROM emprestimo e
JOIN livro l ON l.codigo = e.codigo_livro
WHERE e.data_devolucao IS NULL
ORDER BY e.data_emprestimo;