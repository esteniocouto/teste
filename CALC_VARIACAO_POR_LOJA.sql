/* calculando a variação para cada loja */

SELECT
    loja,
    SUM(QTD_Venda_NOV - QTD_Venda_OUT) AS variacao_total
FROM
    dados
GROUP BY
    loja;

# Somar a Variação Total de Todas as Lojas

SELECT
    SUM(variacao_total) AS variacao_total_global
FROM (
    SELECT
        loja,
        SUM(QTD_Venda_NOV - QTD_Venda_OUT) AS variacao_total
    FROM
        dados
    GROUP BY
        loja
) AS Subquery;
  # --------------------------------------------------------------------------------------------------------------------------------------------------------------- 


/*calular a porcentagem de cada loja na variação global */

WITH VariacaoPorLoja AS (
    SELECT
        loja,
        SUM(QTD_Venda_NOV - QTD_Venda_OUT) AS variacao_total
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
)
SELECT
    v.loja,
    v.variacao_total,
    ROUND((v.variacao_total / g.variacao_total_global) * 100, 2) AS porcentagem_variacao
FROM
    VariacaoPorLoja v
CROSS JOIN
    VariacaoGlobal g;