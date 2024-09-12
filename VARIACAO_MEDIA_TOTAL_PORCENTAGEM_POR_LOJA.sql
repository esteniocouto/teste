# calcullo da variação media, variação total , e porcentagem da variação total por loja

WITH VariacaoPorLoja AS (
    SELECT
        loja,
        SUM(QTD_Venda_NOV - QTD_Venda_OUT) AS variacao_total,
        COUNT(*) AS num_periodos
    FROM
        dados
    GROUP BY
        loja
),
VariacaoGlobal AS (
    SELECT
        SUM(variacao_total) AS variacao_total_global
    FROM
        VariacaoPorLoja
),
VariacaoMediaPorLoja AS (
    SELECT
        loja,
        variacao_total,
        num_periodos,
        ROUND(variacao_total / num_periodos, 2) AS media_variacao
    FROM
        VariacaoPorLoja
)
SELECT
    v.loja,
    v.variacao_total,
    vm.media_variacao,
    ROUND((v.variacao_total / g.variacao_total_global) * 100, 2) AS porcentagem_variacao
FROM
    VariacaoPorLoja v
CROSS JOIN
    VariacaoGlobal g
JOIN
    VariacaoMediaPorLoja vm ON v.loja = vm.loja;