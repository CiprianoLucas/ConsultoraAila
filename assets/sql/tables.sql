CREATE TABLE public.agencia (
	id int4 GENERATED BY DEFAULT AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL,
	cep varchar NOT NULL,
	senha varchar NULL,
	CONSTRAINT agencia_pk PRIMARY KEY (id)
);

CREATE TABLE public.colaborador (
	id int4 GENERATED BY DEFAULT AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL,
	nome varchar NOT NULL,
	CONSTRAINT colaborador_pk PRIMARY KEY (id)
);

CREATE TABLE public.cooperado (
	id int4 GENERATED BY DEFAULT AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL,
	nome varchar NOT NULL,
	cpf varchar NOT NULL,
	nascimento date NOT NULL,
	CONSTRAINT cooperado_pk PRIMARY KEY (id),
	CONSTRAINT newtable_unique UNIQUE (cpf)
);

CREATE TABLE public.agencia_colaborador (
	agencia int4 NOT NULL,
	colaborador int4 NOT NULL,
	CONSTRAINT agencia_colaborador_pk PRIMARY KEY (colaborador, agencia),
	CONSTRAINT agencia_colaborador_agencia_fk FOREIGN KEY (agencia) REFERENCES public.agencia(id),
	CONSTRAINT agencia_colaborador_colaborador_fk FOREIGN KEY (colaborador) REFERENCES public.colaborador(id)
);

CREATE TABLE public.personalidade (
	id int4 NOT NULL,
	descricao varchar NOT NULL,
	CONSTRAINT personalidade_pk PRIMARY KEY (id)
);

CREATE TABLE public.personalidade_colaborador (
	colaborador int4 NOT NULL,
	personalidade int4 NOT NULL,
	CONSTRAINT personalidade_colaborador_unique UNIQUE (colaborador, personalidade),
	CONSTRAINT personalidade_colaborador_colaborador_fk FOREIGN KEY (colaborador) REFERENCES public.colaborador(id),
	CONSTRAINT personalidade_colaborador_personalidade_fk FOREIGN KEY (personalidade) REFERENCES public.personalidade(id)
);

CREATE TABLE public.personalidade_cooperado (
	cooperado int4 NOT NULL,
	personalidade int4 NOT NULL,
	CONSTRAINT personalidade_cooperado_unique UNIQUE (cooperado, personalidade),
	CONSTRAINT personalidade_cooperado_cooperado_fk FOREIGN KEY (cooperado) REFERENCES public.cooperado(id),
	CONSTRAINT personalidade_cooperado_personalidade_fk FOREIGN KEY (personalidade) REFERENCES public.personalidade(id)
);

CREATE TABLE public.segmento (
	id int4 NOT NULL,
	descricao varchar NOT NULL,
	CONSTRAINT segmento_pk PRIMARY KEY (id),
	CONSTRAINT segmento_unique UNIQUE (descricao)
);

CREATE TABLE public.compras (
	id int4 NOT NULL,
	cooperado int4 NOT NULL,
	segmento int4 NOT NULL,
	valor float8 NOT NULL,
	CONSTRAINT compras_pk PRIMARY KEY (id),
	CONSTRAINT compras_cooperado_fk FOREIGN KEY (cooperado) REFERENCES public.cooperado(id),
	CONSTRAINT compras_segmento_fk FOREIGN KEY (segmento) REFERENCES public.segmento(id)
);

CREATE TABLE public.feedback (
	id int4 NOT NULL,
	colaborador int4 NOT NULL,
	cooperado int4 NOT NULL,
	descricao text NOT NULL,
	CONSTRAINT feedback_pk PRIMARY KEY (id),
	CONSTRAINT feedback_colaborador_fk FOREIGN KEY (colaborador) REFERENCES public.colaborador(id),
	CONSTRAINT feedback_cooperado_fk FOREIGN KEY (cooperado) REFERENCES public.cooperado(id)
);

CREATE TABLE public.creditos (
	id int4 GENERATED BY DEFAULT AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL,
	cooperado int4 NOT NULL,
	colaborador int4 NOT NULL,
	valor float8 NOT NULL,
	motivo varchar NULL,
	CONSTRAINT creditos_pk PRIMARY KEY (id),
	CONSTRAINT creditos_colaborador_fk FOREIGN KEY (colaborador) REFERENCES public.colaborador(id),
	CONSTRAINT creditos_cooperado_fk FOREIGN KEY (cooperado) REFERENCES public.cooperado(id)
);

CREATE TABLE public.consulta (
	id int4 GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE) NOT NULL,
	resultado json NOT NULL,
	agencia int4 NOT NULL,
	CONSTRAINT consulta_pk PRIMARY KEY (id),
	CONSTRAINT consulta_agencia_fk FOREIGN KEY (agencia) REFERENCES public.agencia(id)
);
