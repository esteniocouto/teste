WITH VariacaoPorCategoria AS (
    SELECT
        loja,
        DEPARTAMENTO, 
        CATEGORIA,
        SUM(QTD_Venda_NOV - QTD_Venda_OUT) AS variacao_total
    FROM
        dados
    WHERE
        loja = '30 - LEM - BA'  -- Substitua pelo código da filial desejada
        AND DEPARTAMENTO = 'SECA SALGADA'  -- Substitua pelo nome do departamento desejado
    GROUP BY
        loja, DEPARTAMENTO, CATEGORIA
),

-- Calcula a variação total do departamento dentro da filial
VariacaoTotalPorDepartamento AS (
    SELECT
        loja,
        DEPARTAMENTO,
        SUM(variacao_total) AS variacao_total_departamento
    FROM
        VariacaoPorCategoria
    GROUP BY
        loja, DEPARTAMENTO
),

-- Ordena as categorias por variação total em ordem decrescente dentro do departamento e calcula a soma acumulada das variações totais
CategoriasOrdenadas AS (
    SELECT
        v.loja,
        v.DEPARTAMENTO,
        v.CATEGORIA,
        v.variacao_total,
        SUM(v.variacao_total) OVER (PARTITION BY v.loja, v.DEPARTAMENTO ORDER BY v.variacao_total DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS soma_acumulada
    FROM
        VariacaoPorCategoria v
),

-- Seleciona as categorias cuja soma acumulada das variações atinge ou ultrapassa 80% da variação total do departamento
Categorias80PorCento AS (
    SELECT
        c.loja,
        c.DEPARTAMENTO,
        c.CATEGORIA,
        c.variacao_total,
        c.soma_acumulada,
        d.variacao_total_departamento
    FROM
        CategoriasOrdenadas c
    JOIN
        VariacaoTotalPorDepartamento d ON c.loja = d.loja AND c.DEPARTAMENTO = d.DEPARTAMENTO
    WHERE
        c.soma_acumulada <= (d.variacao_total_departamento * 0.8)
        OR c.soma_acumulada = d.variacao_total_departamento
)

-- Mostra as categorias que, combinadas, representam pelo menos 80% da variação total do departamento, com a variação percentual
SELECT
    c.loja,
    c.DEPARTAMENTO,
    c.CATEGORIA,
    c.variacao_total,
    (c.variacao_total / d.variacao_total_departamento) * 100 AS variacao_percentual
FROM
    Categorias80PorCento c
JOIN
    VariacaoTotalPorDepartamento d ON c.loja = d.loja AND c.DEPARTAMENTO = d.DEPARTAMENTO
ORDER BY
    c.loja, c.DEPARTAMENTO, c.variacao_total DESC;
