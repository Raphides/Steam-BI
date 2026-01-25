CREATE TABLE public.tb_games_silver (
    id_jogo int8 NULL,
    nome_jogo text NULL,
    idade_minima int8 NULL,
    preco float8 NULL,
    nota_metacritic int8 NULL,
    nota_usuario int8 NULL,
    desenvolvedores text NULL,
    publicadoras text NULL,
    categorias text NULL,
    generos text NULL,
    tags text NULL,
    ano_lancamento int4 NULL,
    tier_preco text NULL,
    tem_ptbr_interface bool NULL,
    tem_ptbr_audio bool NULL
);