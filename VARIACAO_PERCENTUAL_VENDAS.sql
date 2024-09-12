#Calcular a variação e variação percentual das vendas dos ultimos dois meses

SELECT
    DESCRICAO,
    QTD_Venda_OUT,
    QTD_Venda_NOV,
    ROUND(QTD_Venda_NOV - QTD_Venda_OUT, 2) AS variacao,
    CASE
        WHEN QTD_Venda_OUT = 0 THEN NULL -- Para evitar divisão por zero
        ELSE ROUND(((QTD_Venda_NOV - QTD_Venda_OUT) / QTD_Venda_OUT) * 100, 2)
    END AS variacao_percentual
FROM
    DADOS; 