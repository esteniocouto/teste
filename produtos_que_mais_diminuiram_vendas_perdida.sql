SELECT 
    loja,
    Descricao,
    ROUND(
        (
            COALESCE((QTD_Venda_JUL - QTD_Venda_JUN) / NULLIF(QTD_Venda_JUN, 0) * 100, 0) +
            COALESCE((QTD_Venda_AGO - QTD_Venda_JUL) / NULLIF(QTD_Venda_JUL, 0) * 100, 0) +
            COALESCE((QTD_Venda_SET - QTD_Venda_AGO) / NULLIF(QTD_Venda_AGO, 0) * 100, 0) +
            COALESCE((QTD_Venda_OUT - QTD_Venda_SET) / NULLIF(QTD_Venda_SET, 0) * 100, 0) +
            COALESCE((QTD_Venda_NOV - QTD_Venda_OUT) / NULLIF(QTD_Venda_OUT, 0) * 100, 0)
        ) / 5, 2
    ) AS VENDAS_PERDIDAS
FROM DADOS
WHERE loja = '50 - ST MESTRE DARMAS'
ORDER BY VENDAS_PERDIDAS ASC  -- Ordena pelo menor crescimento, ou seja, pela maior perda
LIMIT 5;