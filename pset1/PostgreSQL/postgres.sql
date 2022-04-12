/*

Implementação do projeto de banco de dados Elmasri no PostgreSQL.

Autor: Hygor Oliveira Pancieri
Professor: Abrantes Araújo Silva Filho

*/

----------------------------------------------------------------

-- Criação do Usuário com permissão de criar bancos de dados e fazer login.
CREATE USER hpancieri WITH
CREATEDB LOGIN;

-- Criação do banco de dados com os atributos necessários.
CREATE DATABASE uvv WITH
OWNER hpancieri
TEMPLATE template0
ENCODING UTF8
LC_COLLATE pt_BR.UTF-8
LC_CTYPE pt_BR.UTF-8
ALLOW_CONECTIONS TRUE;

-- Conexão com o banco de dados "uvv" com o usuário "hpancieri".
\c uvv hpancieri;

-- Criação do esquema com autorização para ser uzada pelo usuário "hpancieri".
CREATE SCHEMA elmasri AUTHORIZATION hpancieri;

-- Alteração temporária para o usuário utilizar o esquema "elmasri".
SET SEARCH_PATH TO elmasri, "$user", public;

----------------------------------------------------------------

-- Criação das Relações.

CREATE TABLE funcionario (
	cpf CHAR(11) NOT NULL, -- PK

	primeiro_nome VARCHAR(15) NOT NULL,
	nome_meio CHAR(1),
	ultimo_nome VARCHAR(15) NOT NULL,
	data_nascimento DATE,
	endereco VARCHAR(40), -- Esse VARCHAR terá tamanho 40, pois existe um valor da etapa de inserção que possui mais do que 30 caracteres.
	sexo CHAR(1),
	salario DECIMAL(10,2),
	cpf_supervisor CHAR(11),-- FK -- Esse campo deve poder receber valores nulos, pois será necessário na etapa de inserção.
	numero_departamento INTEGER NOT NULL, -- FK

	-- Chave Primária:
	PRIMARY KEY (cpf),

	-- Restrições:
	CONSTRAINT salario_valido CHECK (salario > 0), -- O salário não pode ser um número negativo.
	CONSTRAINT sexo_valido CHECK (sexo = 'M' OR sexo = 'F') -- O sexo pode ser apenas os caracteres 'F' ou 'M'.
);

CREATE TABLE dependente (
	cpf_funcionario CHAR(11) NOT NULL, -- PFK
	nome_dependente VARCHAR(15) NOT NULL, -- PK

	sexo CHAR(1),
	data_nascimento DATE,
	parentesco VARCHAR(15),

	-- Chave Primária:
	PRIMARY KEY (cpf_funcionario, nome_dependente),

	-- Restrições:
	CONSTRAINT sexo_valido CHECK (sexo = 'M' OR sexo = 'F') -- O sexo pode ser apenas os caracteres 'F' ou 'M'.
);

CREATE TABLE localizacoes_departamento (
	numero_departamento INTEGER NOT NULL, -- PFK
	local VARCHAR(15) NOT NULL, -- PK

	-- Chave Primária:
	PRIMARY KEY (numero_departamento, local)
);

CREATE TABLE departamento (
	numero_departamento INTEGER NOT NULL, -- PK

	nome_deparamento VARCHAR(15) NOT NULL, -- AK
	cpf_gerente CHAR(11), -- Esse campo deve aceitar valores nulos para possibilitar a inserção de dados sem conflitos com a relação "funcionário".
	data_inicio_gerente DATE,

	-- Chave Primária:
	PRIMARY KEY (numero_departamento),

	-- Chave Única:
	UNIQUE (nome_deparamento)
);

CREATE TABLE projeto (
	numero_projeto INTEGER NOT NULL, -- PK

	nome_projeto VARCHAR(15) NOT NULL, -- AK
	local_projeto VARCHAR(15),
	numero_departamento INTEGER NOT NULL, -- FK

	-- Chave Primária:
	PRIMARY KEY (numero_projeto),

	-- Chave Única:
	UNIQUE (nome_projeto)
);

CREATE TABLE trabalha_em (
	cpf_funcionario CHAR(11) NOT NULL, -- PFK
	numero_projeto INTEGER NOT NULL, -- PFK

	horas DECIMAL(3,1), -- Esse atributo deve aceitar valores nulos, pois será necessário na etapa de inserção.

	-- Chave Primária:
	PRIMARY KEY (cpf_funcionario, numero_projeto)
);

----------------------------------------------------------------

-- Criação dos relacionamentos:

-- Tabela "funcionario":
ALTER TABLE funcionario ADD FOREIGN KEY (cpf_supervisor) REFERENCES funcionario (cpf);
ALTER TABLE funcionario ADD FOREIGN KEY (numero_departamento) REFERENCES departamento (numero_departamento);

-- Tabela "dependente":
ALTER TABLE dependente ADD FOREIGN KEY (cpf_funcionario) REFERENCES funcionario (cpf);

-- Tabela "localizacoes_departamento":
ALTER TABLE localizacoes_departamento ADD FOREIGN KEY (numero_departamento) REFERENCES departamento (numero_departamento);

-- Tabela "departamento":
ALTER TABLE departamento ADD FOREIGN KEY (cpf_gerente) REFERENCES funcionario (cpf);

-- Tabela "projeto":
ALTER TABLE projeto ADD FOREIGN KEY (numero_departamento) REFERENCES departamento (numero_departamento);

-- Tabela "trabalha_em":
ALTER TABLE trabalha_em ADD FOREIGN KEY (cpf_funcionario) REFERENCES funcionario (cpf);
ALTER TABLE trabalha_em ADD FOREIGN KEY (numero_projeto) REFERENCES projeto (numero_projeto);

----------------------------------------------------------------

-- Adicionar comentários nas tabelas.

COMMENT ON TABLE departamento IS 'Tabela que armazena as informações dos departamentos.';
COMMENT ON TABLE dependente IS 'Tabela que armazena as informações dos dependentes dos funcionários.'
COMMENT ON TABLE funcionario IS 'Tabela que armazena as informações dos funcionários.'
COMMENT ON TABLE localizacoes_departamento IS 'Tabela que armazena as possíveis localizações dos departamentos.'
COMMENT ON TABLE projeto IS 'Tabela que armazena as informações sobre os projetos dos departamentos.'
COMMENT ON TABLE trabalha_em IS 'Tabela para armazenar quais funcionários trabalham em quais projetos.'

----------------------------------------------------------------

-- Adicionar comentários nas colunas.

-- Tabela "departamento":
COMMENT ON COLUMN departamento.numero_departamento IS 'Número do departamento. É a PK desta tabela.';
COMMENT ON COLUMN departamento.nome_deparamento IS 'Nome do departamento. Deve ser único.';
COMMENT ON COLUMN departamento.cpf_gerente IS 'CPF do gerente do departamento. É uma FK para a tabela funcionários.';
COMMENT ON COLUMN departamento.data_inicio_gerente IS 'Data do início do gerente no departamento.';

-- Tabela "dependente":
COMMENT ON COLUMN dependente.cpf_funcionario IS 'CPF do funcionário. Faz parte da PK desta tabela e é uma FK para a tabela funcionário.';
COMMENT ON COLUMN dependente.nome_dependente IS 'Nome do dependente. Faz parte da PK desta tabela.';
COMMENT ON COLUMN dependente.sexo IS 'Sexo do dependente. Só aceita os valores "M" ou "F".';
COMMENT ON COLUMN dependente.data_nascimento IS 'Data de nascimento do dependente.';
COMMENT ON COLUMN dependente.parentesco IS 'Descrição do parentesco do dependente com o funcionário.';

-- Tabela "funcionario":
COMMENT ON COLUMN funcionario.cpf IS 'CPF do funcionário. Será a PK da tabela.';
COMMENT ON COLUMN funcionario.primeiro_nome IS 'Primeiro nome do funcionário.';
COMMENT ON COLUMN funcionario.nome_meio IS 'Inicial do nome do meio.';
COMMENT ON COLUMN funcionario.ultimo_nome IS 'Sobrenome do funcionário.';
COMMENT ON COLUMN funcionario.data_nascimento IS 'Data de nascimento do funcionário.';
COMMENT ON COLUMN funcionario.endereco IS 'Endereço do funcionário.';
COMMENT ON COLUMN funcionario.sexo IS 'Sexo do funcionário. Só aceita valores "M" ou "F".';
COMMENT ON COLUMN funcionario.salario IS 'Salário do funcionário. Não pode ser um número negativo.';
COMMENT ON COLUMN funcionario.cpf_supervisor IS 'CPF do supervisor. Será uma FK para a própria tabela (um auto-relacionamento).';
COMMENT ON COLUMN funcionario.numero_departamento IS 'Número do departamento do funcionário. Será uma FK para a tabela departamento.';

-- Tabela "localizacoes_departamento":
COMMENT ON COLUMN localizacoes_departamento.numero_departamento IS 'Número do departamento. Faz parte da PK desta tabela e também é uma FK para a tabela departamento.';
COMMENT ON COLUMN localizacoes_departmento.local IS 'Localização do departamento. Faz parte da PK desta tabela';

-- Tabela "projeto":
COMMENT ON COLUMN projeto.numero_projeto IS 'Número do projeto. É a PK desta tabela.';
COMMENT ON COLUMN projeto.nome_projeto IS 'Nome do projeto. Deve ser único.';
COMMENT ON COLUMN projeto.local_projeto IS 'Localização do projeto.';
COMMENT ON COLUMN projeto.numero_departamento IS 'Número do departamento. É uma FK para a tabela departamento.';

-- Tabela "trabalha_em":
COMMENT ON COLUMN trabalha_em.cpf_funcionario IS 'CPF do funcionário. Faz parte da PK desta tabela e é uma FK para a tabela funcionário.';
COMMENT ON COLUMN trabalha_em.numero_projeto IS 'Número do projeto. Faz parte da PK desta tabela e é uma FK para a tabela projeto.';
COMMENT ON COLUMN trabalha_em.horas IS 'Horas trabalhadas pelo funcionário neste projeto.';
