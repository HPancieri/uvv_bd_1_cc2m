/*

Implementação do projeto lógico: Sistema Cerimonial.

Autores:
	Hygor Oliveira Pancieri
	Pedro Calezane Lyra
	Hugo Araujo Corona
	Cecilia de Jesus Barros
	Thierry Martins Ribeiro
Professor:
	Abrantes Araújo Silva Filho

*/

---------------------------------------------//---------------------------------------------

-- Limpeza Geral:

DROP DATABASE IF EXISTS uvv_bd1;
DROP ROLE IF EXISTS luffy;

---------------------------------------------//---------------------------------------------

-- Criação do Usuário com permissão de criar bancos de dados e fazer login.
-- A senha do usuário será '123456'.
CREATE USER luffy WITH
	CREATEDB LOGIN
	PASSWORD '123456';

-- Criação do banco de dados com os atributos necessários.
CREATE DATABASE uvv_bd1 WITH
	OWNER = luffy
	TEMPLATE = template0
	ENCODING = UTF8
	LC_COLLATE = "pt_BR.utf8"
	LC_CTYPE = "pt_BR.utf8"
	ALLOW_CONNECTIONS = TRUE;

-- Conexão com o banco de dados "uvv_bd1" com o usuário "luffy".
\c "dbname=uvv_bd1 user=luffy password=123456";

-- Criação do esquema com autorização para ser usado pelo usuário "luffy".
CREATE SCHEMA proj_logico AUTHORIZATION luffy;

-- Alteração temporária para o usuário utilizar o esquema "proj_logico".
SET SEARCH_PATH TO proj_logico, "$user", public;

-- Alteração permanente para o usuário utilizar o esquema "proj_logico".
ALTER USER luffy SET SEARCH_PATH TO proj_logico, "$user", public;

---------------------------------------------//---------------------------------------------

-- Script gerado com o SQL Power Architect

-- Criação das Tabelas:

CREATE TABLE proj_logico.convidados (
                cod_convidado   CHAR(15)    NOT NULL,
                nome            VARCHAR(50) NOT NULL,
                data_nascimento DATE        NOT NULL,
                sexo            CHAR(1)     NOT NULL,

                CONSTRAINT convidados_pk PRIMARY KEY (cod_convidado),

                -- O campo sexo só pode possuir os valores 'M' ou 'F', então:
                CONSTRAINT convidados_sexo_ck CHECK (
                    sexo = 'M' OR
                    sexo = 'F'
                )
);

CREATE TABLE proj_logico.servicos (
                cod_servico CHAR(15)      NOT NULL,
                nome        VARCHAR(1000) NOT NULL,
                valor       NUMERIC(10,2) NOT NULL,

                CONSTRAINT servicos_pk PRIMARY KEY (cod_servico)
);

CREATE TABLE proj_logico.bebidas  (
                cod_servico      CHAR(15)     NOT NULL,
                nome             VARCHAR(25)  NOT NULL,
                indice_alcoolico NUMERIC(5,2) NOT NULL,

                CONSTRAINT bebidas_pk PRIMARY KEY (cod_servico)
);

CREATE TABLE proj_logico.profissionais (
                cod_profissional CHAR(15)    NOT NULL,
                nome             VARCHAR(50) NOT NULL,

                CONSTRAINT profissionais_pk PRIMARY KEY (cod_profissional)
);

CREATE TABLE proj_logico.musicos  (
                cod_profissional      CHAR(15)      NOT NULL,
                formacao              VARCHAR(100)  NOT NULL,
                descricao_habilidades VARCHAR(2000) NOT NULL,

                CONSTRAINT musicos_pk PRIMARY KEY (cod_profissional)
);

CREATE TABLE proj_logico.garcons (
                cod_profissional CHAR(15) NOT NULL,
                tempo_experincia INTEGER  NOT NULL,

                CONSTRAINT garcons_pk PRIMARY KEY (cod_profissional)
);

CREATE TABLE proj_logico.cozinheiros (
                cod_profissional         CHAR(15)      NOT NULL,
                formacao                 VARCHAR(100)  NOT NULL,
                descricao_especialidades VARCHAR(3000) NOT NULL,

                CONSTRAINT cozinheiros_pk PRIMARY KEY (cod_profissional)
);

CREATE TABLE proj_logico.comida (
                cod_servico   CHAR(15)     NOT NULL,
                nome          VARCHAR(150) NOT NULL,
                teor_calorico INTEGER      NOT NULL,

                CONSTRAINT comida_pk PRIMARY KEY (cod_servico)
);

CREATE TABLE proj_logico.clientes (
                cod_cliente CHAR(15)    NOT NULL,
                nome        VARCHAR(50) NOT NULL,
                email       VARCHAR(50) NOT NULL,

                CONSTRAINT clientes_pk PRIMARY KEY (cod_cliente)
);

CREATE TABLE proj_logico.telefones (
                telefone         CHAR(11)    NOT NULL,
                tipo_pessoa      VARCHAR(25) NOT NULL,
                cod_profissional CHAR(15),
                cod_cliente      CHAR(15),
                cod_convidado    CHAR(15),

                CONSTRAINT telefones_pk PRIMARY KEY (telefone),

                -- Nos campos de código, um deles deve ser preenchido e os
                -- demais devem ser nulos, portanto:

                CONSTRAINT telefones_cod_preenchido_ck CHECK (
                    (cod_profissional IS NOT NULL AND cod_cliente IS NULL AND cod_convidado IS NULL) OR
                    (cod_profissional IS NULL AND cod_cliente IS NOT NULL AND cod_convidado IS NULL) OR
                    (cod_profissional IS NULL AND cod_cliente IS NULL AND cod_convidado IS NOT NULL)
                )
);

CREATE TABLE proj_logico.endereco (
                tipo_pessoa      VARCHAR(25)   NOT NULL,
                cod_endereco     CHAR(15)      NOT NULL,
                cod_profissional CHAR(15),
                cod_cliente      CHAR(15),
                logradouro       VARCHAR(50)   NOT NULL,
                cep              CHAR(8)       NOT NULL,
                uf               CHAR(2)       NOT NULL,
                cidade           VARCHAR(50)   NOT NULL,
                bairro           VARCHAR(50)   NOT NULL,
                complemento      VARCHAR(200),
                numero           VARCHAR(10)   NOT NULL,

                CONSTRAINT endereco__pk PRIMARY KEY (tipo_pessoa, cod_endereco),

                -- Nos campos cod_profissional e cod_cliente, apenas um deles pode estar
                -- preenchido simultaneamente, portanto:

                CONSTRAINT endereco_cod_preenchido_ck CHECK (
                    (cod_profissional IS NOT NULL AND cod_cliente IS NULL) OR
                    (cod_profissional IS NULL AND cod_cliente IS NOT NULL)
                )
);

CREATE TABLE proj_logico.convites (
                cod_cliente   CHAR(15) NOT NULL,
                cod_convidado CHAR(15) NOT NULL,

                CONSTRAINT convites_pk PRIMARY KEY (cod_cliente, cod_convidado)
);

CREATE TABLE proj_logico.eventos (
                cod_evento     CHAR(15)    NOT NULL,
                cod_cliente    CHAR(15)    NOT NULL,
                data_do_inicio DATE        NOT NULL,
                nome           VARCHAR(50) NOT NULL,
                motivo         VARCHAR(50) NOT NULL,
                data_do_fim    DATE        NOT NULL,
                hora_do_inicio TIMESTAMP   NOT NULL,
                hora_do_fim    TIMESTAMP   NOT NULL,

                CONSTRAINT eventos_pk PRIMARY KEY (cod_evento)
);

CREATE TABLE proj_logico.consumos (
                cod_evento            CHAR(15) NOT NULL,
                cod_servico           CHAR(15) NOT NULL,
                quantidade_contratada INTEGER  NOT NULL,
                quantidade_consumida  INTEGER,

                CONSTRAINT consumos_pk PRIMARY KEY (cod_evento, cod_servico)
);

CREATE TABLE proj_logico.equipes (
                data_incio       DATE     NOT NULL,
                cod_profissional CHAR(15) NOT NULL,
                cod_evento       CHAR(15) NOT NULL,
                data_fim         DATE     NOT NULL,

                CONSTRAINT equipes_pk PRIMARY KEY (data_incio, cod_profissional, cod_evento)
);

---------------------------------------------//---------------------------------------------

-- Adição dos Comentários das tabelas:

COMMENT ON TABLE proj_logico.convidados IS 'Dados do convidados que participarão dos serviços.';
COMMENT ON TABLE proj_logico.servicos IS 'Tabela que armazena informações acerca dos serviços consumidos.';
COMMENT ON TABLE proj_logico.bebidas  IS 'Tipos de bebidas que foram solicitadas.';
COMMENT ON TABLE proj_logico.profissionais IS 'Dados dos profissionais que trabalham no empresa que organiza os eventos.';
COMMENT ON TABLE proj_logico.musicos  IS 'Profissioais contratados para trocar no evento.';
COMMENT ON TABLE proj_logico.garcons IS 'Dados dos garçons que vão trablahr no evento.';
COMMENT ON TABLE proj_logico.cozinheiros IS 'Dados da equipe contratada para o buffet.';
COMMENT ON TABLE proj_logico.comida IS 'Tipos de comidas que foram solicitadas.';
COMMENT ON TABLE proj_logico.clientes IS 'Dados dos cliente que fizeram o orçamento.';
COMMENT ON TABLE proj_logico.telefones IS 'Telefones.';
COMMENT ON TABLE proj_logico.endereco IS 'Endereço.';
COMMENT ON TABLE proj_logico.convites IS 'Tabela que armazena a relação entre clientes e convidados.';
COMMENT ON TABLE proj_logico.eventos IS 'Quais tipos de eventos vão ser realizados.';
COMMENT ON TABLE proj_logico.consumos IS 'Consuno de comidas e bebidas feita pelos convidados no eventos.';
COMMENT ON TABLE proj_logico.equipes IS 'Dados das equipes que vão trabalhar no evento.';

---------------------------------------------//---------------------------------------------

-- Adição dos Comentários das colunas:

COMMENT ON COLUMN proj_logico.convidados.cod_convidado IS 'Codigo do convidado pk da tabela convidado.';
COMMENT ON COLUMN proj_logico.convidados.nome IS 'Nome dos convidados.';
COMMENT ON COLUMN proj_logico.convidados.data_nascimento IS 'Data de nascimento do cliente.';
COMMENT ON COLUMN proj_logico.convidados.sexo IS 'Sexo do convidado.';

COMMENT ON COLUMN proj_logico.servicos.cod_servico IS 'Cod_servico pk da tabela serviços.';
COMMENT ON COLUMN proj_logico.servicos.nome IS 'Nome do serviço contratado.';
COMMENT ON COLUMN proj_logico.servicos.valor  IS 'Valor do serviço contratado.';

COMMENT ON COLUMN proj_logico.bebidas .cod_servico IS 'Bebidas que vai ser serivda no evento.';
COMMENT ON COLUMN proj_logico.bebidas .nome IS 'Tipo de bebida.';
COMMENT ON COLUMN proj_logico.bebidas .indice_alcoolico IS 'Teor alcoólico da bebida.';

COMMENT ON COLUMN proj_logico.profissionais.cod_profissional IS 'Pk da tabela profissionais.';
COMMENT ON COLUMN proj_logico.profissionais.nome IS 'Nome do profissional que vai trabalhar no evento.';

COMMENT ON COLUMN proj_logico.musicos .cod_profissional IS 'Pk da tabela músicos.';
COMMENT ON COLUMN proj_logico.musicos .formacao IS 'Formação do músico.';
COMMENT ON COLUMN proj_logico.musicos .descricao_habilidades IS 'Habilidades do musico com instrumento.';

COMMENT ON COLUMN proj_logico.garcons.cod_profissional IS 'Pk da tabela garçons.';
COMMENT ON COLUMN proj_logico.garcons.tempo_experincia IS 'Tempo de experincia.';

COMMENT ON COLUMN proj_logico.cozinheiros.cod_profissional IS 'Pk da tabela cozinheiros.';
COMMENT ON COLUMN proj_logico.cozinheiros.formacao IS 'Formação do cozinheiro.';
COMMENT ON COLUMN proj_logico.cozinheiros.descricao_especialidades IS 'Especilidades do cozinheiro.';

COMMENT ON COLUMN proj_logico.comida.cod_servico IS 'Comida que vai ser servida no evento.';
COMMENT ON COLUMN proj_logico.comida.nome IS 'Nome da comida que vai ser servida no evento.';
COMMENT ON COLUMN proj_logico.comida.teor_calorico IS 'Teor calorico de determinada comida.';

COMMENT ON COLUMN proj_logico.clientes.cod_cliente IS 'COdigo do cliente da tabela clientes.';
COMMENT ON COLUMN proj_logico.clientes.nome IS 'Nome dos clientes.';
COMMENT ON COLUMN proj_logico.clientes.email IS 'Email do cliente.';

COMMENT ON COLUMN proj_logico.telefones.telefone IS 'Telefone dos clientres pk da tabela telefones_clientes.';
COMMENT ON COLUMN proj_logico.telefones.cod_profissional IS 'Pk da tabela tefone.';
COMMENT ON COLUMN proj_logico.telefones.cod_cliente IS 'Código do cliente, PK para a tabela clientes.';
COMMENT ON COLUMN proj_logico.telefones.cod_convidado IS 'Código do convidado, PK para a tabela convidados.';

COMMENT ON COLUMN proj_logico.endereco.tipo_pessoa IS 'Pk da tabela endereço.';
COMMENT ON COLUMN proj_logico.endereco.cod_endereco IS 'Código do endereço. Faz parte da PK da tabela.';
COMMENT ON COLUMN proj_logico.endereco.cod_profissional IS 'Código do profissional, Pk para a tabela profissionais.';
COMMENT ON COLUMN proj_logico.endereco.cod_cliente IS 'Código do cliente, FK para a tabela clientes.';
COMMENT ON COLUMN proj_logico.endereco.logradouro IS 'Logradouro da tabela endereço.';
COMMENT ON COLUMN proj_logico.endereco.cep IS 'Cep do endereço do cliente.';
COMMENT ON COLUMN proj_logico.endereco.uf IS 'Estado em que o cliente reside.';
COMMENT ON COLUMN proj_logico.endereco.cidade IS 'Cidade em que o cliente reside.';
COMMENT ON COLUMN proj_logico.endereco.bairro IS 'Bairro em que o cliente reside.';
COMMENT ON COLUMN proj_logico.endereco.numero IS 'Numero da casa em que o cliente reside.';
COMMENT ON COLUMN proj_logico.endereco.complemento  IS 'Complemento do local onde o cliente mora.';

COMMENT ON COLUMN proj_logico.convites.cod_cliente IS 'Código do cliente da tabela clientes.';
COMMENT ON COLUMN proj_logico.convites.cod_convidado IS 'Código do convidado pk da tabela convidado.';

COMMENT ON COLUMN proj_logico.eventos.cod_evento IS 'Código do evento vai ser pk da tabela eventos.';
COMMENT ON COLUMN proj_logico.eventos.cod_cliente IS 'COdigo do cliente da tabela clientes.';
COMMENT ON COLUMN proj_logico.eventos.data_do_inicio IS 'Data do inicio do evento.';
COMMENT ON COLUMN proj_logico.eventos.nome IS 'Nome de qual tipo de evento vai ser organizado.';
COMMENT ON COLUMN proj_logico.eventos.motivo IS 'Qual vai ser o motivo do evento.';
COMMENT ON COLUMN proj_logico.eventos.data_do_fim  IS 'Data do final do evento.';
COMMENT ON COLUMN proj_logico.eventos.hora_do_inicio IS 'Horario em que o evento vai começar.';
COMMENT ON COLUMN proj_logico.eventos.hora_do_fim IS 'Horario do término do evento.';

COMMENT ON COLUMN proj_logico.consumos.cod_evento IS 'Código do evento vai ser pk da tabela eventos.';
COMMENT ON COLUMN proj_logico.consumos.cod_servico IS 'Cod_servico pk da tabela serviços.';
COMMENT ON COLUMN proj_logico.consumos.quantidade_contratada IS 'Quantidadede comidas e bebidas contratadas.';
COMMENT ON COLUMN proj_logico.consumos.quantidade_consumida IS 'Quantidade de comida e bebida consumida.';

COMMENT ON COLUMN proj_logico.equipes.data_incio IS 'Inicio do evento.';
COMMENT ON COLUMN proj_logico.equipes.cod_profissional IS 'Pk da tabela profissionais.';
COMMENT ON COLUMN proj_logico.equipes.cod_evento IS 'Código do evento vai ser pk da tabela eventos.';
COMMENT ON COLUMN proj_logico.equipes.data_fim IS 'Fim do evento.';

---------------------------------------------//---------------------------------------------

-- Adição das Chaves Estrangeiras:

ALTER TABLE proj_logico.convites ADD CONSTRAINT convidados_convites_fk
FOREIGN KEY (cod_convidado)
REFERENCES proj_logico.convidados (cod_convidado)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.telefones ADD CONSTRAINT convidados_telefones_fk
FOREIGN KEY (cod_convidado)
REFERENCES proj_logico.convidados (cod_convidado)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.consumos ADD CONSTRAINT servicos_consumos_fk
FOREIGN KEY (cod_servico)
REFERENCES proj_logico.servicos (cod_servico)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.comida ADD CONSTRAINT servicos_comida_fk
FOREIGN KEY (cod_servico)
REFERENCES proj_logico.servicos (cod_servico)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.bebidas  ADD CONSTRAINT servicos_bebidas_fk
FOREIGN KEY (cod_servico)
REFERENCES proj_logico.servicos (cod_servico)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.garcons ADD CONSTRAINT profissionais_garcons_fk
FOREIGN KEY (cod_profissional)
REFERENCES proj_logico.profissionais (cod_profissional)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.musicos  ADD CONSTRAINT profissionais_musicos_fk
FOREIGN KEY (cod_profissional)
REFERENCES proj_logico.profissionais (cod_profissional)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.cozinheiros ADD CONSTRAINT profissionais_cozinheiros_fk
FOREIGN KEY (cod_profissional)
REFERENCES proj_logico.profissionais (cod_profissional)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.equipes ADD CONSTRAINT profissionais_equipes_fk
FOREIGN KEY (cod_profissional)
REFERENCES proj_logico.profissionais (cod_profissional)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.endereco ADD CONSTRAINT profissionais_endereco_fk
FOREIGN KEY (cod_profissional)
REFERENCES proj_logico.profissionais (cod_profissional)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.telefones ADD CONSTRAINT profissionais_telefones_fk
FOREIGN KEY (cod_profissional)
REFERENCES proj_logico.profissionais (cod_profissional)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.eventos ADD CONSTRAINT clientes_eventos_fk
FOREIGN KEY (cod_cliente)
REFERENCES proj_logico.clientes (cod_cliente)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.convites ADD CONSTRAINT clientes_convites_fk
FOREIGN KEY (cod_cliente)
REFERENCES proj_logico.clientes (cod_cliente)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.endereco ADD CONSTRAINT clientes_endereco_fk
FOREIGN KEY (cod_cliente)
REFERENCES proj_logico.clientes (cod_cliente)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.telefones ADD CONSTRAINT clientes_telefones_fk
FOREIGN KEY (cod_cliente)
REFERENCES proj_logico.clientes (cod_cliente)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.equipes ADD CONSTRAINT eventos_equipes_fk
FOREIGN KEY (cod_evento)
REFERENCES proj_logico.eventos (cod_evento)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE proj_logico.consumos ADD CONSTRAINT eventos_consumos_fk
FOREIGN KEY (cod_evento)
REFERENCES proj_logico.eventos (cod_evento)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;
