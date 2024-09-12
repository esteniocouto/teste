    /* IDENTIFICAR quais filiais concentram 80% da Variação total: Aumento de Venda e Diminuição de venda
    Para fazer isso, você pode seguir estes passos:

1. Calcular a variação total para cada loja.
2. Calcular a variação total global.
3. Ordenar as lojas pela variação total em ordem decrescente.
4. Acumular as variações totais até que a soma atinja ou ultrapasse 80% da variação total global.*/

#-Calcular a variação total para cada loja.
#-Calcular a variação total para cada loja.
WITH VariacaoPorLoja AS ( 
    SELECT
        loja,
        SUM(QTD_Venda_NOV - QTD_Venda_OUT) AS variacao_total
    FROM
        dados
    GROUP BY
        loja
),
#Calcular a variação total global
VariacaoGlobal AS (
    SELECT
        SUM(variacao_total) AS variacao_total_global
    FROM
        VariacaoPorLoja
),
#-Calcula a porcentagem da variação total de cada loja em relação à variação total global.
PercentualVariacaoPorLoja AS (
    SELECT
        loja,
        variacao_total,
        ROUND((variacao_total / g.variacao_total_global) * 100, 2) AS porcentagem_variacao
    FROM
        VariacaoPorLoja v
    CROSS JOIN
        VariacaoGlobal g
),
#Ordena as lojas pela variação total em ordem decrescente e calcula a soma acumulada das variações totais.
LojasOrdenadas AS (
    SELECT
        loja,
        variacao_total,
        porcentagem_variacao,
        SUM(variacao_total) OVER (ORDER BY variacao_total DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS soma_acumulada
    FROM
        PercentualVariacaoPorLoja
# ---Seleciona as lojas cuja soma acumulada das variações atinge ou ultrapassa 80% da variação total global.        
),
Lojas80PorCento AS (
    SELECT
        loja,
        variacao_total,
        porcentagem_variacao,
        soma_acumulada
    FROM
        LojasOrdenadas
    WHERE
        soma_acumulada <= (SELECT variacao_total_global * 0.8 FROM VariacaoGlobal)
        OR soma_acumulada = (SELECT SUM(variacao_total) FROM VariacaoPorLoja)
)

# ---Mostra as lojas que juntas representam pelo menos 80% da variação total global, ordenadas pela variação total.
SELECT
    loja,
    variacao_total,
    porcentagem_variacao
FROM
    Lojas80PorCento
ORDER BY
    variacao_total DESC;
