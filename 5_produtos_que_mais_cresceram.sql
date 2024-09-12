#---------Indique os 5 produtos que mais cresceram venda por Filial
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
    ) AS Crescimento_Medio
FROM DADOS
WHERE loja = '50 - ST MESTRE DARMAS'
ORDER BY Crescimento_Medio DESC
LIMIT 5;
