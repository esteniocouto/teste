CREATE DATABASE TESTE;
USE TESTE;

SELECT * FROM DADOS;

/*Calculando a variação para cada produto entre os meses de outubro e novembro */

SELECT
    DESCRICAO,
    QTD_Venda_OUT,
    QTD_Venda_NOV,
    (QTD_Venda_NOV - QTD_Venda_OUT) AS variacao
FROM
    dados;
    
    
    
    
  # --------------------------------------------------------------------------------------------------------------------------------------------------------------- 



#Calcular a variação e variação percentual das vendas dos ultimos dois meses

SELECT
    DESCRICAO,
    QTD_Venda_OUT,
    QTD_Venda_NOV,
    ROUND(QTD_Venda_NOV - QTD_Venda_OUT, 2) AS variacao,
    ROUND(
        ((QTD_Venda_NOV - QTD_Venda_OUT) / 
        CASE WHEN QTD_Venda_OUT = 0 THEN 1 ELSE QTD_Venda_OUT END) * 100, 2 # PARA EVITAR PROBLEMAS DE CALCULO QUANDO TIVER DIVISÃO POR 0 SERA SUBSTITUIDO POR 1
    ) AS variacao_percentual
FROM
    DADOS;


    
    
  # --------------------------------------------------------------------------------------------------------------------------------------------------------------- 

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

  # --------------------------------------------------------------------------------------------------------------------------------------------------------------- 

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
    
    
  # --------------------------------------------------------------------------------------------------------------------------------------------------------------- 
  
  
    /* IDENTIFICAR quais filiais concentram 80% da Variação total: Aumento de Venda e Diminuição de venda
    Para fazer isso, você pode seguir estes passos:

1. Calcular a variação total para cada loja.
2. Calcular a variação total global.
3. Ordenar as lojas pela variação total em ordem decrescente.
4. Acumular as variações totais até que a soma atinja ou ultrapasse 80% da variação total global.*/

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

WITH VariacaoPorDepartamento AS (
    SELECT
        loja,
        departamento,
        SUM(QTD_Venda_NOV - QTD_Venda_OUT) AS variacao_total
    FROM
        dados
    GROUP BY
        loja, departamento
),
VariacaoTotalPorLoja AS (
    SELECT
        loja,
        SUM(variacao_total) AS variacao_total_loja
    FROM
        VariacaoPorDepartamento
    GROUP BY
        loja
),
DepartamentosOrdenados AS (
    SELECT
        v.loja,
        v.departamento,
        v.variacao_total,
        SUM(v.variacao_total) OVER (PARTITION BY v.loja ORDER BY v.variacao_total DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS soma_acumulada
    FROM
        VariacaoPorDepartamento v
),
Departamentos80PorCento AS (
    SELECT
        d.loja,
        d.departamento,
        d.variacao_total,
        d.soma_acumulada,
        l.variacao_total_loja
    FROM
        DepartamentosOrdenados d
    JOIN
        VariacaoTotalPorLoja l ON d.loja = l.loja
    WHERE
        d.soma_acumulada <= (l.variacao_total_loja * 0.8)
        OR d.soma_acumulada = l.variacao_total_loja
)
SELECT
    loja,
    departamento,
    variacao_total
FROM
    Departamentos80PorCento
ORDER BY
    loja, variacao_total DESC;


    