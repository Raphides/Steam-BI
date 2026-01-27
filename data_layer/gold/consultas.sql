-- ----------------------------------------------------------------------------
-- 1. TOP 10 GÊNEROS MAIS BEM AVALIADOS (CRÍTICA E USUÁRIO)
-- ----------------------------------------------------------------------------
WITH METRICAS_GENERO AS (
    SELECT 
        DG.NME_GEN AS GENERO,
        COUNT(F.SRK_JGO) AS TOTAL_JOGOS,
        ROUND(AVG(F.NTA_MTC), 2) AS MEDIA_METACRITIC,
        ROUND(AVG(F.NTA_USR), 2) AS MEDIA_USUARIO
    FROM DW.FAT_JGO F
    INNER JOIN DW.DIM_GEN DG ON F.SRK_GEN = DG.SRK_GEN
    WHERE F.NTA_MTC > 0
    GROUP BY DG.NME_GEN
)
SELECT 
    GENERO,
    TOTAL_JOGOS,
    MEDIA_METACRITIC,
    MEDIA_USUARIO,
    (MEDIA_METACRITIC + (MEDIA_USUARIO * 10)) / 2 AS MEDIA_COMBINADA 
FROM METRICAS_GENERO
WHERE TOTAL_JOGOS > 50 
ORDER BY MEDIA_METACRITIC DESC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- 2. EVOLUÇÃO DE PREÇO MÉDIO POR ANO (INFLAÇÃO DOS JOGOS)
-- ----------------------------------------------------------------------------
WITH PRECO_ANUAL AS (
    SELECT 
        F.ANO_LNC AS ANO,
        COUNT(F.SRK_JGO) AS QTD_LANCAMENTOS,
        ROUND(AVG(DOFR.VLR_PRC), 2) AS PRECO_MEDIO
    FROM DW.FAT_JGO F
    INNER JOIN DW.DIM_OFR DOFR ON F.SRK_OFR = DOFR.SRK_OFR
    WHERE F.ANO_LNC BETWEEN 2010 AND 2024
    GROUP BY F.ANO_LNC
)
SELECT 
    ANO,
    QTD_LANCAMENTOS,
    PRECO_MEDIO,
    LAG(PRECO_MEDIO) OVER (ORDER BY ANO) AS PRECO_ANO_ANTERIOR,
    ROUND(PRECO_MEDIO - LAG(PRECO_MEDIO) OVER (ORDER BY ANO), 2) AS VARIACAO_ANUAL
FROM PRECO_ANUAL
ORDER BY ANO DESC;


-- ----------------------------------------------------------------------------
-- 3. IMPACTO DA LOCALIZAÇÃO (PT-BR) NA NOTA DOS USUÁRIOS
-- ----------------------------------------------------------------------------
WITH ANALISE_LOCALIZACAO AS (
    SELECT 
        CASE 
            WHEN F.TEM_PTB_AUD = TRUE THEN 'Dublado e Legendado'
            WHEN F.TEM_PTB_ITF = TRUE THEN 'Apenas Legenda/Interface'
            ELSE 'Sem Português'
        END AS NIVEL_TRADUCAO,
        COUNT(F.SRK_JGO) AS QTD_JOGOS,
        ROUND(AVG(F.NTA_USR), 2) AS MEDIA_NOTA_USUARIO
    FROM DW.FAT_JGO F
    GROUP BY 
        CASE 
            WHEN F.TEM_PTB_AUD = TRUE THEN 'Dublado e Legendado'
            WHEN F.TEM_PTB_ITF = TRUE THEN 'Apenas Legenda/Interface'
            ELSE 'Sem Português'
        END
)
SELECT 
    NIVEL_TRADUCAO,
    QTD_JOGOS,
    MEDIA_NOTA_USUARIO
FROM ANALISE_LOCALIZACAO
ORDER BY MEDIA_NOTA_USUARIO DESC;


-- ----------------------------------------------------------------------------
-- 4. O "DOCE PONTO" (SWEET SPOT) DE PREÇO VS QUALIDADE
-- ----------------------------------------------------------------------------
WITH PERFORMANCE_TIER AS (
    SELECT 
        DOFR.TIR_PRC AS TIER,
        COUNT(F.SRK_JGO) AS VOLUME,
        ROUND(AVG(F.NTA_MTC), 1) AS MEDIA_METACRITIC
    FROM DW.FAT_JGO F
    INNER JOIN DW.DIM_OFR DOFR ON F.SRK_OFR = DOFR.SRK_OFR
    WHERE F.NTA_MTC > 0
    GROUP BY DOFR.TIR_PRC
)
SELECT 
    TIER,
    VOLUME,
    MEDIA_METACRITIC,
    CASE 
        WHEN MEDIA_METACRITIC >= 75 THEN 'Excelência'
        WHEN MEDIA_METACRITIC >= 70 THEN 'Bom'
        ELSE 'Regular/Baixo'
    END AS CLASSIFICACAO
FROM PERFORMANCE_TIER
ORDER BY MEDIA_METACRITIC DESC;


-- ----------------------------------------------------------------------------
-- 5. RANKING DE DESENVOLVEDORES "INDIE" (MAIS PRODUTIVOS E BEM AVALIADOS)
-- ----------------------------------------------------------------------------
WITH DEVS_INDIE AS (
    SELECT 
        DD.NME_DEV AS DESENVOLVEDOR,
        COUNT(F.SRK_JGO) AS TOTAL_JOGOS,
        ROUND(AVG(F.NTA_MTC), 1) AS NOTA_MEDIA
    FROM DW.FAT_JGO F
    INNER JOIN DW.DIM_DEV DD ON F.SRK_DEV = DD.SRK_DEV
    INNER JOIN DW.DIM_OFR DOFR ON F.SRK_OFR = DOFR.SRK_OFR
    WHERE DOFR.TIR_PRC LIKE '%Indie%'
      AND F.NTA_MTC > 0
    GROUP BY DD.NME_DEV
)
SELECT 
    DESENVOLVEDOR,
    TOTAL_JOGOS,
    NOTA_MEDIA
FROM DEVS_INDIE
WHERE TOTAL_JOGOS >= 3
ORDER BY NOTA_MEDIA DESC
LIMIT 15;


-- ----------------------------------------------------------------------------
-- 6. "HIDDEN GEMS": JOGOS BARATOS (<$10) COM NOTA DE AAA (>85)
-- ----------------------------------------------------------------------------
WITH JOIAS_ESCONDIDAS AS (
    SELECT 
        F.NME_JGO AS NOME_JOGO,
        DG.NME_GEN AS GENERO,
        DOFR.VLR_PRC AS PRECO,
        F.NTA_MTC AS NOTA_CRITICA
    FROM DW.FAT_JGO F
    INNER JOIN DW.DIM_OFR DOFR ON F.SRK_OFR = DOFR.SRK_OFR
    INNER JOIN DW.DIM_GEN DG ON F.SRK_GEN = DG.SRK_GEN
    WHERE DOFR.VLR_PRC < 10.00
      AND F.NTA_MTC >= 85
)
SELECT 
    NOME_JOGO,
    GENERO,
    PRECO,
    NOTA_CRITICA
FROM JOIAS_ESCONDIDAS
ORDER BY NOTA_CRITICA DESC, PRECO ASC
LIMIT 20;


-- ----------------------------------------------------------------------------
-- 7. ANÁLISE DE SATURAÇÃO: GÊNEROS COM MAIS LANÇAMENTOS RECENTES
-- ----------------------------------------------------------------------------
WITH LANCAMENTOS_RECENTES AS (
    SELECT 
        DG.NME_GEN AS GENERO,
        COUNT(F.SRK_JGO) AS QTD_2023_2024
    FROM DW.FAT_JGO F
    INNER JOIN DW.DIM_GEN DG ON F.SRK_GEN = DG.SRK_GEN
    WHERE F.ANO_LNC >= 2023
    GROUP BY DG.NME_GEN
)
SELECT 
    GENERO,
    QTD_2023_2024,
    ROUND((QTD_2023_2024 * 100.0 / (SELECT SUM(QTD_2023_2024) FROM LANCAMENTOS_RECENTES)), 2) AS PORCENTAGEM_MERCADO
FROM LANCAMENTOS_RECENTES
ORDER BY QTD_2023_2024 DESC;


-- ----------------------------------------------------------------------------
-- 8. CATEGORIAS: SINGLE-PLAYER VS MULTI-PLAYER (PREFERÊNCIA DO PÚBLICO)
-- ----------------------------------------------------------------------------
WITH CLASSIFICACAO_CATEGORIA AS (
    SELECT 
        CASE 
            WHEN DC.NME_CAT ILIKE '%Multi-player%' OR DC.NME_CAT ILIKE '%Co-op%' THEN 'Experiência Online/Coop'
            WHEN DC.NME_CAT ILIKE '%Single-player%' THEN 'Apenas Single-player'
            ELSE 'Outros'
        END AS TIPO_EXPERIENCIA,
        F.NTA_MTC
    FROM DW.FAT_JGO F
    INNER JOIN DW.DIM_CAT DC ON F.SRK_CAT = DC.SRK_CAT
    WHERE F.NTA_MTC > 0
)
SELECT 
    TIPO_EXPERIENCIA,
    COUNT(*) AS TOTAL_JOGOS,
    ROUND(AVG(NTA_MTC), 2) AS MEDIA_NOTA
FROM CLASSIFICACAO_CATEGORIA
GROUP BY TIPO_EXPERIENCIA
ORDER BY MEDIA_NOTA DESC;


-- ----------------------------------------------------------------------------
-- 9. DOMÍNIO DAS PUBLICADORAS (PUBLISHERS) NO TIER AAA
-- ----------------------------------------------------------------------------
WITH PUBLISHERS_AAA AS (
    SELECT 
        DP.NME_PBS AS PUBLICADORA,
        COUNT(F.SRK_JGO) AS QTD_JOGOS_CAROS
    FROM DW.FAT_JGO F
    INNER JOIN DW.DIM_PBS DP ON F.SRK_PBS = DP.SRK_PBS
    INNER JOIN DW.DIM_OFR DOFR ON F.SRK_OFR = DOFR.SRK_OFR
    WHERE DOFR.TIR_PRC LIKE '%AAA%'
    GROUP BY DP.NME_PBS
)
SELECT 
    PUBLICADORA,
    QTD_JOGOS_CAROS
FROM PUBLISHERS_AAA
ORDER BY QTD_JOGOS_CAROS DESC
LIMIT 10;


-- ----------------------------------------------------------------------------
-- 10. A ESTRATÉGIA DO "OCEANO AZUL" (ALTA NOTA, BAIXA CONCORRÊNCIA)
-- ----------------------------------------------------------------------------
WITH NICHO_STATS AS (
    SELECT 
        DG.NME_GEN AS GENERO,
        COUNT(F.SRK_JGO) AS VOLUME,
        AVG(F.NTA_MTC) AS QUALIDADE
    FROM DW.FAT_JGO F
    INNER JOIN DW.DIM_GEN DG ON F.SRK_GEN = DG.SRK_GEN
    WHERE F.ANO_LNC >= 2020
    GROUP BY DG.NME_GEN
)
SELECT 
    GENERO,
    VOLUME AS CONCORRENCIA,
    ROUND(QUALIDADE, 2) AS NOTA_MEDIA,
    CASE 
        WHEN VOLUME < 500 AND QUALIDADE > 75 THEN 'Oceano Azul (Oportunidade)'
        WHEN VOLUME > 1000 AND QUALIDADE < 70 THEN 'Oceano Vermelho (Saturado)'
        ELSE 'Mercado Padrão'
    END AS STATUS_MERCADO
FROM NICHO_STATS
WHERE VOLUME > 50
ORDER BY QUALIDADE DESC, VOLUME ASC;