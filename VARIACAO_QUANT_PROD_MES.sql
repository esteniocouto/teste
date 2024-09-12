/*Calculando a variação para cada produto entre os meses de outubro e novembro */

SELECT
    DESCRICAO,
    QTD_Venda_OUT,
    QTD_Venda_NOV,
    (QTD_Venda_NOV - QTD_Venda_OUT) AS variacao
FROM
    dados;