CREATE TABLE public.tb_games_silver (
	app_id int8 NULL,
	"name" text NULL,
	release_date timestamp NULL,
	release_year int8 NULL,
	price float8 NULL,
	price_tier text NULL,
	has_ptbr_interface bool NULL,
	has_ptbr_audio bool NULL,
	required_age int8 NULL,
	metacritic_score int8 NULL,
	user_score int8 NULL,
	publishers text NULL,
	categories text NULL,
	genres text NULL,
	tags text NULL,
	supported_languages text NULL,
	full_audio_languages text NULL
);