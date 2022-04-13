/*

Implementação do projeto de banco de dados Elmasri no PostgreSQL.

Autor: Hygor Oliveira Pancieri
Professor: Abrantes Araújo Silva Filho

*/

---------------------------------------------//---------------------------------------------

-- Criação do Usuário com permissão de criar bancos de dados e fazer login.
CREATE USER hpancieri WITH
	CREATEDB LOGIN;

-- Criação do banco de dados com os atributos necessários.
CREATE DATABASE uvv WITH
	OWNER = hpancieri
	TEMPLATE = template0
	ENCODING = UTF8
	LC_COLLATE = "pt_BR.utf8"
	LC_CTYPE = "pt_BR.utf8"
	ALLOW_CONNECTIONS = TRUE;

-- Conexão com o banco de dados "uvv" com o usuário "hpancieri".
\c uvv hpancieri;

-- Criação do esquema com autorização para ser usado pelo usuário "hpancieri".
CREATE SCHEMA elmasri AUTHORIZATION hpancieri;

-- Alteração temporária para o usuário utilizar o esquema "elmasri".
SET SEARCH_PATH TO elmasri, "$user", public;

-- Alteração permanente para o usuário utilizar o esquema "elmasri".
ALTER USER hpancieri SET SEARCH_PATH TO elmasri, "$user", public;

---------------------------------------------//---------------------------------------------

-- Criação das Tabelas.

-- Tabela "funcionario":
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

-- Tabela "dependente":
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

-- Tabela "localizacoes_departamento":
CREATE TABLE localizacoes_departamento (
	numero_departamento INTEGER NOT NULL, -- PFK
	local VARCHAR(15) NOT NULL, -- PK

	-- Chave Primária:
	PRIMARY KEY (numero_departamento, local)
);

-- Tabela "departamento":
CREATE TABLE departamento (
	numero_departamento INTEGER NOT NULL, -- PK

	nome_departamento VARCHAR(15) NOT NULL, -- AK
	cpf_gerente CHAR(11), -- Esse campo deve aceitar valores nulos para possibilitar a inserção de dados sem conflitos com a relação "funcionário".
	data_inicio_gerente DATE,

	-- Chave Primária:
	PRIMARY KEY (numero_departamento),

	-- Chave Única:
	UNIQUE (nome_departamento)
);

-- Tabela "projeto":
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

-- Tabela "trabalha_em":
CREATE TABLE trabalha_em (
	cpf_funcionario CHAR(11) NOT NULL, -- PFK
	numero_projeto INTEGER NOT NULL, -- PFK

	horas DECIMAL(3,1), -- Esse atributo deve aceitar valores nulos, pois será necessário na etapa de inserção.

	-- Chave Primária:
	PRIMARY KEY (cpf_funcionario, numero_projeto)
);

---------------------------------------------//---------------------------------------------

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

---------------------------------------------//---------------------------------------------

-- Adicionar comentários nas tabelas.

COMMENT ON TABLE departamento IS 'Tabela que armazena as informações dos departamentos.';
COMMENT ON TABLE dependente IS 'Tabela que armazena as informações dos dependentes dos funcionários.';
COMMENT ON TABLE funcionario IS 'Tabela que armazena as informações dos funcionários.';
COMMENT ON TABLE localizacoes_departamento IS 'Tabela que armazena as possíveis localizações dos departamentos.';
COMMENT ON TABLE projeto IS 'Tabela que armazena as informações sobre os projetos dos departamentos.';
COMMENT ON TABLE trabalha_em IS 'Tabela para armazenar quais funcionários trabalham em quais projetos.';

---------------------------------------------//---------------------------------------------

-- Adicionar comentários nas colunas.

-- Tabela "departamento":
COMMENT ON COLUMN departamento.numero_departamento IS 'Número do departamento. É a PK desta tabela.';
COMMENT ON COLUMN departamento.nome_departamento IS 'Nome do departamento. Deve ser único.';
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
COMMENT ON COLUMN localizacoes_departamento.local IS 'Localização do departamento. Faz parte da PK desta tabela';

-- Tabela "projeto":
COMMENT ON COLUMN projeto.numero_projeto IS 'Número do projeto. É a PK desta tabela.';
COMMENT ON COLUMN projeto.nome_projeto IS 'Nome do projeto. Deve ser único.';
COMMENT ON COLUMN projeto.local_projeto IS 'Localização do projeto.';
COMMENT ON COLUMN projeto.numero_departamento IS 'Número do departamento. É uma FK para a tabela departamento.';

-- Tabela "trabalha_em":
COMMENT ON COLUMN trabalha_em.cpf_funcionario IS 'CPF do funcionário. Faz parte da PK desta tabela e é uma FK para a tabela funcionário.';
COMMENT ON COLUMN trabalha_em.numero_projeto IS 'Número do projeto. Faz parte da PK desta tabela e é uma FK para a tabela projeto.';
COMMENT ON COLUMN trabalha_em.horas IS 'Horas trabalhadas pelo funcionário neste projeto.';

---------------------------------------------//---------------------------------------------

-- Inserção de dados.

/* Devemos começar pela tabela "departamento",
mas ainda não podemos inserir dados para o campo "cpf_gerente",
pois a tabela "funcionario" ainda não possui valores para
serem referenciados, o que causaria erros.*/
INSERT INTO departamento VALUES
	(5, 'Pesquisa',      NULL, '1988-05-22'),
	(4, 'Administração', NULL, '1995-01-01'),
	(1, 'Matriz',        NULL, '1981-06-19');


/* Agora, na tabela "funcionario", devemos começar pelo
funcionario que não possui supervisor, depois, inserimos
os funcionários diretamente subordinados a este, e assim por diante,
uma vez que o campo "cpf_supervisor" referencia o cpf de um funcionário.*/
INSERT INTO funcionario VALUES
	('88866555576', 'Jorge',    'E', 'Brito',   '1937-11-10', 'Rua do Horto, 35, São Paulo, SP',         'M', 55000.00,  NULL,         1),
	('33344555587', 'Fernando', 'T', 'Wong',    '1955-12-08', 'Rua da Lapa, 34, São Paulo',              'M', 40000.00, '88866555576', 5),
	('98765432168', 'Jennifer', 'S', 'Sousa',   '1941-06-20', 'Av. Arthur de Lima, 54, Santo André, SP', 'F', 43000.00, '88866555576', 4),
	('12345678966', 'João',     'B', 'Silva',   '1965-01-09', 'Rua das Flores, 751, São Paulo, SP',      'M', 30000.00, '33344555587', 5),
	('66688444476', 'Ronaldo',  'K', 'Lima',    '1962-09-15', 'Rua Rebouças, 65, Piracicaba, SP',        'M', 38000.00, '33344555587', 5),
	('45345345376', 'Joice',    'A', 'Leite',   '1972-07-31', 'Av. Lucas Obes, 74, São Paulo, SP',       'F', 25000.00, '33344555587', 5),
	('99988777767', 'Alice',    'J', 'Zelaya',  '1968-01-19', 'Rua Souza Lima, 35, Curitiba, PR',        'F', 25000.00, '98765432168', 4),
	('98798798733', 'André',    'V', 'Pereira', '1969-03-29', 'Rua Timbira, 35, São Paulo, SP',          'M', 25000.00, '98765432168', 4);


/* Atualizando os valores da tabela "departamento"
com os campos "cpf_gerente" preenchidos corretamente.*/
UPDATE departamento SET
	cpf_gerente = '33344555587'
	WHERE numero_departamento = 5;
UPDATE departamento SET
	cpf_gerente = '98765432168'
	WHERE numero_departamento = 4;
UPDATE departamento SET
	cpf_gerente = '88866555576'
	WHERE numero_departamento = 1;


-- Tabela "localizacoes_departamento":
INSERT INTO localizacoes_departamento VALUES
	(1, 'São Paulo'),
	(4, 'Mauá'),
	(5, 'Santo André'),
	(5, 'Itu'),
	(5, 'São Paulo');


-- Tabela "projeto":
INSERT INTO projeto VALUES
	(1,  'ProdutoX',         'Santo André', 5),
	(2,  'ProdutoY',         'Itu',         5),
	(3,  'ProdutoZ',         'São Paulo',   5),
	(10, 'Informatização',  'Mauá',        4),
	(20, 'Reorganização',   'São Paulo',   1),
	(30, 'Novosbenefícios', 'Mauá',        4);


-- Tabela "dependente":
INSERT INTO dependente VALUES
	('33344555587', 'Alicia',    'F', '1986-04-05', 'Filha'),
	('33344555587', 'Tiago',     'M', '1983-10-25', 'Filho'),
	('33344555587', 'Janaína',   'F', '1958-05-03', 'Esposa'),
	('98765432168', 'Antonio',   'M', '1942-02-28', 'Marido'),
	('12345678966', 'Michael',   'M', '1988-01-04', 'Filho'),
	('12345678966', 'Alicia',    'F', '1988-12-30', 'Filha'),
	('12345678966', 'Elizabeth', 'F', '1967-05-05', 'Esposa');


-- Tabela "trabalha_em":
INSERT INTO trabalha_em VALUES
	('12345678966', 1,  32.5),
	('12345678966', 2,  7.5),
	('66688444476', 3,  40.0),
	('45345345376', 1,  20.0),
	('45345345376', 2,  20.0),
	('33344555587', 2,  10.0),
	('33344555587', 3,  10.0),
	('33344555587', 10, 10.0),
	('33344555587', 20, 10.0),
	('99988777767', 30, 30.0),
	('99988777767', 10, 10.0),
	('98798798733', 10, 35.0),
	('98798798733', 30, 5.0),
	('98765432168', 30, 20.0),
	('98765432168', 20, 15.0),
	('88866555576', 20, NULL);