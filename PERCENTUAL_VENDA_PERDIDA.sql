/*percentual venda perdida por filial em relação aos meses de Setembro e Novembro*/

WITH VendasPerdidas AS (
    SELECT 
        loja,
        -- Calcula a soma das quedas nas vendas de SET para NOV
        SUM(CASE 
            WHEN QTD_Venda_NOV < QTD_Venda_SET THEN (QTD_Venda_SET - QTD_Venda_NOV) 
            ELSE 0 
        END) AS Total_Venda_Perdida,
        SUM(QTD_Venda_SET) AS Total_Vendas_SET,
        SUM(QTD_Venda_NOV) AS Total_Vendas_NOV
    FROM DADOS
    GROUP BY loja
)

SELECT 
    loja,
    Total_Vendas_SET,
    Total_Vendas_NOV,
    Total_Venda_Perdida,
    -- Calcula a porcentagem de venda perdida em relação às vendas de SET
    ROUND(
        (Total_Venda_Perdida * 100.0) / Total_Vendas_SET, 2
    ) AS Percentual_Venda_Perdida
FROM VendasPerdidas;
