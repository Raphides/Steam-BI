-- ============================================================================
-- CAMADA GOLD: DDL VIA ESQUEMA ESTRELA
-- ============================================================================

DROP SCHEMA IF EXISTS DW CASCADE;
CREATE SCHEMA DW;

COMMENT ON SCHEMA DW IS 'Data Warehouse (DW), banco de dados atuante na camada gold - Dados estruturados, agregados e otimizados para análise histórica';


-- ============================================================================
-- DIMENSÃO 1: OFERTA
-- ============================================================================

CREATE TABLE DW.DIM_OFR(
    SRK_OFR BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    VLR_PRC NUMERIC(8, 2) NOT NULL,
    TIR_PRC VARCHAR(50) NOT NULL,
);


COMMENT ON TABLE DW.DIM_OFR IS 'Dimensão Oferta - Informações econômicas sobre os jogos';
COMMENT ON COLUMN DW.DIM_OFR.SRK_OFR IS 'Surrogate Key - Chave primária da oferta';
COMMENT ON COLUMN DW.DIM_OFR.VLR_PRC IS 'Preço do jogo - Valor';
COMMENT ON COLUMN DW.DIM_OFR.TIR_PRC IS 'Tier do Preço - Gratuito, Budget (<$10), Indie / Padrão ($10-$29), Double-A / Premium ($30-$58), AAA / Lançamento (+$59)';

-- ============================================================================
-- DIMENSÃO 2: DESENVOLVEDOR
-- ============================================================================

CREATE TABLE DW.DIM_DEV(
    SRK_DEV BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    NME_DEV VARCHAR(1000) NOT NULL
);

COMMENT ON TABLE DW.DIM_DEV IS 'Dimensão Desenvolvedor - Informações sobre desenvolvedores dos jogos';
COMMENT ON COLUMN DW.DIM_DEV.SRK_DEV IS 'Surrogate Key - Chave primária da lista de desenvolvedores';
COMMENT ON COLUMN DW.DIM_DEV.NME_DEV IS 'Lista de nomes dos desenvolvedores de cada jogo';

-- ============================================================================
-- DIMENSÃO 3: PUBLICADOR
-- ============================================================================

CREATE TABLE DW.DIM_PBS(
    SRK_PBS BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    NME_PBS VARCHAR(300) NOT NULL
);

COMMENT ON TABLE DW.DIM_PBS IS 'Dimensão Publicador - Informações sobre publicadoras dos jogos';
COMMENT ON COLUMN DW.DIM_PBS.SRK_PBS IS 'Surrogate Key - Chave primária da lista de publicadoras';
COMMENT ON COLUMN DW.DIM_PBS.NME_PBS IS 'Lista de nomes das publicadoras de cada jogo';

-- ============================================================================
-- DIMENSÃO 4: CATEGORIA
-- ============================================================================

CREATE TABLE DW.DIM_CAT(
    SRK_CAT BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    NME_CAT VARCHAR(1000) NOT NULL
);

COMMENT ON TABLE DW.DIM_CAT IS 'Dimensão Categoria - Informações sobre categorias dos jogos';
COMMENT ON COLUMN DW.DIM_CAT.SRK_CAT IS 'Surrogate Key - Chave primária da lista de categorias de cada jogo';
COMMENT ON COLUMN DW.DIM_CAT.NME_CAT IS 'Lista de nomes das categorias de cada jogo';

-- ============================================================================
-- DIMENSÃO 5: GÊNERO
-- ============================================================================

CREATE TABLE DW.DIM_GEN(
    SRK_GEN BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    NME_GEN VARCHAR(500) NOT NULL
);

COMMENT ON TABLE DW.DIM_GEN IS 'Dimensão Gênero - Informações sobre gêneros dos jogos';
COMMENT ON COLUMN DW.DIM_GEN.SRK_GEN IS 'Surrogate Key - Chave primária da lista de gêneros de cada jogo';
COMMENT ON COLUMN DW.DIM_GEN.NME_GEN IS 'Lista de nomes dos gêneros de cada jogo';

-- ============================================================================
-- DIMENSÃO 6: PUBLICADOR
-- ============================================================================

CREATE TABLE DW.DIM_TAG(
    SRK_TAG BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    NME_TAG VARCHAR(500) NOT NULL
);

COMMENT ON TABLE DW.DIM_TAG IS 'Dimensão Tag - Informações sobre tags dos jogos';
COMMENT ON COLUMN DW.DIM_TAG.SRK_TAG IS 'Surrogate Key - Chave primária da lista de tags de cada jogo';
COMMENT ON COLUMN DW.DIM_TAG.NME_TAG IS 'Lista de nomes de tags de cada jogo';

-- ============================================================================
-- FATO 1: JOGO 
-- ============================================================================

CREATE TABLE DW.FAT_JGO(
    SRK_JGO BIGINT PRIMARY KEY,
    NME_JGO VARCHAR(100) NOT NULL,
    VLR_IDD SMALLINT NOT NULL,
    TEM_PTB_ITF BOOLEAN NOT NULL,
    TEM_PTB_AUD BOOLEAN NOT NULL,
    NTA_USR SMALLINT NOT NULL,
    NTA_MTC SMALLINT NOT NULL,
    ANO_LNC SMALLINT NOT NULL,
    SRK_OFR BIGINT NOT NULL REFERENCES DW.DIM_OFR(SRK_OFR),
    SRK_DEV BIGINT NOT NULL REFERENCES DW.DIM_DEV(SRK_DEV),
    SRK_PBS BIGINT NOT NULL REFERENCES DW.DIM_PBS(SRK_PBS),
    SRK_CAT BIGINT NOT NULL REFERENCES DW.DIM_CAT(SRK_CAT),
    SRK_GEN BIGINT NOT NULL REFERENCES DW.DIM_GEN(SRK_GEN),
    SRK_TAG BIGINT NOT NULL REFERENCES DW.DIM_TAG(SRK_TAG)
);

COMMENT ON TABLE DW.FAT_JGO IS 'Fato Jogo - Informações de jogos';
COMMENT ON COLUMN DW.FAT_JGO.SRK_JGO IS 'Surrogate Key -  Chave primária de cada jogo, referente ao ID do jogo na Steam';
COMMENT ON COLUMN DW.FAT_JGO.NME_JGO IS 'Nome do jogo';
COMMENT ON COLUMN DW.FAT_JGO.VLR_IDD IS 'Idade indicada para jogar';
COMMENT ON COLUMN DW.FAT_JGO.TEM_PTB_ITF IS 'Tem Interface em Português?';
COMMENT ON COLUMN DW.FAT_JGO.TEM_PTB_AUD IS 'Tem Áudio em Português?';
COMMENT ON COLUMN DW.FAT_JGO.NTA_USR IS 'Nota do jogo pelos usuários da Steam';
COMMENT ON COLUMN DW.FAT_JGO.NTA_MTC IS 'Nota do jogo pelo Metacritic';
COMMENT ON COLUMN DW.FAT_JGO.ANO_LNC IS 'Ano de Lançamento';
COMMENT ON COLUMN DW.FAT_JGO.SRK_OFR IS 'Chave estrangeira sorrogate para DIM_OFR - Referente a Dimensão Oferta';
COMMENT ON COLUMN DW.FAT_JGO.SRK_DEV IS 'Chave estrangeira sorrogate para DIM_DEV - Referente a Dimensão Desenvolvedor';
COMMENT ON COLUMN DW.FAT_JGO.SRK_PBS IS 'Chave estrangeira sorrogate para DIM_PBS - Referente a Dimensão Publicadora';
COMMENT ON COLUMN DW.FAT_JGO.SRK_CAT IS 'Chave estrangeira sorrogate para DIM_CAT - Referente a Dimensão Categoria';
COMMENT ON COLUMN DW.FAT_JGO.SRK_GEN IS 'Chave estrangeira sorrogate para DIM_GEN - Referente a Dimensão Gênero';
COMMENT ON COLUMN DW.FAT_JGO.SRK_TAG IS 'Chave estrangeira sorrogate para DIM_TAG - Referente a Dimensão Tag';


-- ============================================================================
-- FIM DO DDL PARA A CAMADA GOLD
-- ============================================================================

