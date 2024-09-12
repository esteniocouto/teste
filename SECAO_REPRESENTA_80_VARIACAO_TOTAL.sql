WITH VariacaoPorSecao AS (
    SELECT
        loja,
        DEPARTAMENTO, 
        SECAO,
        SUM(QTD_Venda_NOV - QTD_Venda_OUT) AS variacao_total
    FROM
        dados
    WHERE
        loja = '50 - ST MESTRE DARMAS'  -- Substitua pelo código da loja desejada
        AND DEPARTAMENTO = ('SAUDAVEIS')  -- Substitua pelo nome do departamento desejado
    GROUP BY
        loja, DEPARTAMENTO, SECAO
),

-- Calcula a variação total do departamento
VariacaoTotalPorDepartamento AS (
    SELECT
        loja,
        DEPARTAMENTO,
        SUM(variacao_total) AS variacao_total_departamento
    FROM
        VariacaoPorSecao
    GROUP BY
        loja, DEPARTAMENTO
),

-- Ordena as seções por variação total em ordem decrescente dentro do departamento e calcula a soma acumulada das variações totais
SecoesOrdenadas AS (
    SELECT
        v.loja,
        v.DEPARTAMENTO,
        v.SECAO,
        v.variacao_total,
        SUM(v.variacao_total) OVER (PARTITION BY v.loja, v.DEPARTAMENTO ORDER BY v.variacao_total DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS soma_acumulada
    FROM
        VariacaoPorSecao v
),

-- Seleciona as seções cuja soma acumulada das variações atinge ou ultrapassa 80% da variação total do departamento
Secoes80PorCento AS (
    SELECT
        s.loja,
        s.DEPARTAMENTO,
        s.SECAO,
        s.variacao_total,
        s.soma_acumulada,
        d.variacao_total_departamento
    FROM
        SecoesOrdenadas s
    JOIN
        VariacaoTotalPorDepartamento d ON s.loja = d.loja AND s.DEPARTAMENTO = d.DEPARTAMENTO
    WHERE
        s.soma_acumulada <= (d.variacao_total_departamento * 0.8)
        OR s.soma_acumulada = d.variacao_total_departamento
)

-- Mostra as seções que, combinadas, representam pelo menos 80% da variação total do departamento, com a variação percentual
SELECT
    s.loja,
    s.DEPARTAMENTO,
    s.SECAO,
    s.variacao_total,
    -- Aqui usamos NULLIF para evitar divisão por zero
    (s.variacao_total / NULLIF(d.variacao_total_departamento, 0)) * 100 AS variacao_percentual
FROM
    Secoes80PorCento s
JOIN
    VariacaoTotalPorDepartamento d ON s.loja = d.loja AND s.DEPARTAMENTO = d.DEPARTAMENTO
ORDER BY
    s.loja, s.DEPARTAMENTO, s.variacao_total DESC;
