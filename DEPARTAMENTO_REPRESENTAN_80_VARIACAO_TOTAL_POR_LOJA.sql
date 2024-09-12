#Calcula a variação total (variacao_total) para cada departamento dentro de cada loja ate atingir 80%.

WITH VariacaoPorDepartamento AS (
    SELECT
        loja,
        DEPARTAMENTO, 
        SUM(QTD_Venda_NOV - QTD_Venda_OUT) AS variacao_total
    FROM
        dados
    GROUP BY
        loja, DEPARTAMENTO
),

-- Calcula a variação total (variacao_total_loja) para cada loja
VariacaoTotalPorLoja AS (
    SELECT
        loja,
        SUM(variacao_total) AS variacao_total_loja
    FROM
        VariacaoPorDepartamento
    GROUP BY
        loja
),

-- Ordena os departamentos por variação total em ordem decrescente dentro de cada loja e calcula a soma acumulada das variações totais
DepartamentosOrdenados AS (
    SELECT
        v.loja,
        v.DEPARTAMENTO,
        v.variacao_total,
        SUM(v.variacao_total) OVER (PARTITION BY v.loja ORDER BY v.variacao_total DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS soma_acumulada
    FROM
        VariacaoPorDepartamento v
),

-- Seleciona os departamentos cuja soma acumulada das variações atinge ou ultrapassa 80% da variação total da loja
Departamentos80PorCento AS (
    SELECT
        d.loja,
        d.DEPARTAMENTO,
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

-- Mostra os departamentos que, combinados, representam pelo menos 80% da variação total em cada loja, com a variação percentual
SELECT
    d.loja,
    d.DEPARTAMENTO,
    d.variacao_total,
    (d.variacao_total / l.variacao_total_loja) * 100 AS variacao_percentual
FROM
    Departamentos80PorCento d
JOIN
    VariacaoTotalPorLoja l ON d.loja = l.loja
WHERE
    d.loja IN ('30 - LEM - BA', '50 - ST MESTRE DARMAS')  -- Adiciona o filtro para múltiplas lojas
ORDER BY
    d.loja, d.variacao_total DESC;
