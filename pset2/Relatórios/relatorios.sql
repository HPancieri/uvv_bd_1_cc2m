/*

Relatórios SQL
Autor: Hygor Oliveira Pancieri
Professor: Abrantes Araújo Silva Filho

*/

----------------------------------------//----------------------------------------

-- QUESTÃO 01: prepare um relatório que mostre a média salarial dos funcionários de cada departamento.

SELECT 
	f.numero_departamento AS "Número do Departamento",
	d.nome_departamento AS "Nome do Departamento",
	CAST(AVG(f.salario) AS MONEY) AS "Média Salarial"
FROM
	funcionario AS f
	INNER JOIN
	departamento AS d
	ON
		(f.numero_departamento = d.numero_departamento)
GROUP BY
	d.numero_departamento, f.numero_departamento
ORDER BY
	d.numero_departamento ASC;

----------------------------------------//----------------------------------------

-- QUESTÃO 02: prepare um relatório que mostre a média salarial dos homens e das mulheres.

SELECT
	CASE f.sexo
	 	WHEN 'M' THEN 'Masculino'
		WHEN 'F' THEN 'Feminino'
	END AS "Sexo",
	CAST(AVG(f.salario) AS MONEY) AS "Média Salarial"
FROM
	funcionario AS f
GROUP BY
	f.sexo
ORDER BY
	f.sexo ASC;

----------------------------------------//----------------------------------------

-- QUESTÃO 03: prepare um relatório que liste o nome dos departamentos e, para
-- cada departamento, inclua as seguintes informações de seus funcionários: o nome
-- completo, a data de nascimento, a idade em anos completos e o salário.

SELECT
	d.nome_departamento AS "Nome do Departamento",
	CONCAT(f.primeiro_nome, ' ', f.nome_meio, '. ', f.ultimo_nome) AS "Nome do Funcionário",
	TO_CHAR(f.data_nascimento, 'dd/mm/yyyy') AS "Data de Nascimento",
	DATE_PART('year', AGE(CURRENT_DATE, f.data_nascimento)) AS "Idade",
	CAST(f.salario AS MONEY) AS "Salário"
FROM
	departamento AS d
	INNER JOIN
	funcionario AS f
ON
	(d.numero_departamento = f.numero_departamento)
ORDER BY
	d.nome_departamento ASC;

----------------------------------------//----------------------------------------

-- QUESTÃO 04: prepare um relatório que mostre o nome completo dos funcionários,
-- a idade em anos completos, o salário atual e o salário com um reajuste que
-- obedece ao seguinte critério: se o salário atual do funcionário é inferior a 35.000 o
-- reajuste deve ser de 20%, e se o salário atual do funcionário for igual ou superior a
-- 35.000 o reajuste deve ser de 15%.

SELECT
	CONCAT(f.primeiro_nome, ' ', f.nome_meio, '. ', f.ultimo_nome) AS "Nome do Funcionário",
	DATE_PART('year', AGE(CURRENT_DATE, f.data_nascimento)) AS "Idade",
	CAST(f.salario AS MONEY) AS "Salário Atual",
	CAST(f.salario * 1.2 AS MONEY) AS "Salário com Reajuste"
FROM
	funcionario AS f
WHERE
	f.salario < 35000
UNION
SELECT
	CONCAT(f.primeiro_nome, ' ', f.nome_meio, '. ', f.ultimo_nome) AS "Nome do Funcionário",
	DATE_PART('year', AGE(CURRENT_DATE, f.data_nascimento)) AS "Idade",
	CAST(f.salario AS MONEY) AS "Salário Atual",
	CAST(f.salario * 1.15 AS MONEY) AS "Salário com Reajuste"
FROM
	funcionario AS f
WHERE
	f.salario >= 35000
ORDER BY
	"Nome do Funcionário" ASC;

----------------------------------------//----------------------------------------

-- QUESTÃO 05: prepare um relatório que liste, para cada departamento, o nome
-- do gerente e o nome dos funcionários. Ordene esse relatório por nome do departamento
-- (em ordem crescente) e por salário dos funcionários (em ordem decrescente).

SELECT
	d.nome_departamento AS "Nome do Departamento",
	CONCAT(f2.primeiro_nome, ' ', f2.nome_meio, '. ', f2.ultimo_nome) AS "Nome do Gerente",
	CONCAT(f1.primeiro_nome, ' ', f1.nome_meio, '. ', f1.ultimo_nome) AS "Nome do Funcionario"
FROM
	departamento AS d
	NATURAL JOIN
	funcionario AS f1
	INNER JOIN
	funcionario AS f2
	ON
		d.cpf_gerente = f2.cpf
ORDER BY
	d.nome_departamento ASC,
	f1.salario DESC;

----------------------------------------//----------------------------------------

-- QUESTÃO 06: prepare um relatório que mostre o nome completo dos funcionários
-- que têm dependentes, o departamento onde eles trabalham e, para cada funcionário,
-- também liste o nome completo dos dependentes, a idade em anos de cada
-- dependente e o sexo (o sexo NÃO DEVE aparecer como M ou F, deve aparecer
-- como “Masculino” ou “Feminino”).

SELECT
	CONCAT(f.primeiro_nome, ' ', f.nome_meio, '. ', f.ultimo_nome) AS "Nome do Funcionário",
	d.nome_departamento AS "Nome do Departamento",
	dep.nome_dependente AS "Nome do Dependente",
	DATE_PART('year', AGE(CURRENT_DATE, dep.data_nascimento)) AS "Idade do Dependente",
	CASE dep.sexo
		WHEN 'M' THEN 'Masculino'
		WHEN 'F' THEN 'Feminino'
	END AS "Sexo do Dependente"
FROM
	funcionario AS F
	INNER JOIN
	departamento AS d
	ON
		f.numero_departamento = d.numero_departamento
	INNER JOIN
	dependente AS dep
	ON
		f.cpf = dep.cpf_funcionario
ORDER BY
	"Idade do Dependente" ASC;

----------------------------------------//----------------------------------------

-- QUESTÃO 07: prepare um relatório que mostre, para cada funcionário que NÃO
-- TEM dependente, seu nome completo, departamento e salário.

SELECT
	CONCAT(f.primeiro_nome, ' ', f.nome_meio, '. ', f.ultimo_nome) AS "Nome do Funcionário",
	d.nome_departamento AS "Nome do Departamento",
	CAST(f.salario AS MONEY) AS "Salário"
FROM
	funcionario AS f
	INNER JOIN
	departamento AS d
	ON
		f.numero_departamento = d.numero_departamento
WHERE NOT EXISTS
	(
		SELECT
			*
		FROM
			dependente AS dep
		WHERE
			f.cpf = dep.cpf_funcionario
	)
ORDER BY
	"Nome do Funcionário" ASC;

----------------------------------------//----------------------------------------

-- QUESTÃO 08: prepare um relatório que mostre, para cada departamento, os projetos
-- desse departamento e o nome completo dos funcionários que estão alocados
-- em cada projeto. Além disso inclua o número de horas trabalhadas por cada funcionário,
-- em cada projeto.

SELECT
	d.nome_departamento AS "Nome do Departamento",
	p.nome_projeto AS "Nome do Projeto",
	CONCAT(f.primeiro_nome, ' ', f.nome_meio, '. ', f.ultimo_nome) AS "Nome do Funcionário",
	te.horas AS "Horas Trabalhadas"
FROM
	departamento AS d
	NATURAL JOIN
	projeto AS p
	NATURAL JOIN
	trabalha_em AS te
	INNER JOIN
	funcionario AS f
	ON
		f.cpf = te.cpf_funcionario
ORDER BY
	d.nome_departamento ASC,
	p.nome_projeto ASC,
	"Nome do Funcionário" ASC;

----------------------------------------//----------------------------------------

-- QUESTÃO 09: prepare um relatório que mostre a soma total das horas de cada
-- projeto em cada departamento. Obs: o relatório deve exibir o nome do
-- departamento, o nome do projeto e a soma total das horas.

SELECT
	d.nome_departamento AS "Nome do Departamento",
	p.nome_projeto AS "Nome do Projeto",
	SUM(te.horas) AS "Total de Horas Trabalhadas"
FROM
	trabalha_em AS te
	NATURAL JOIN
	projeto AS p
	NATURAL JOIN
	departamento AS d
GROUP BY
	d.nome_departamento,
	p.nome_projeto
ORDER BY
	d.nome_departamento ASC,
	p.nome_projeto ASC;

----------------------------------------//----------------------------------------

-- QUESTÃO 10: prepare um relatório que mostre a média salarial dos
-- funcionários de cada departamento.

SELECT
	d.nome_departamento AS "Nome do Departamento",
	CAST(AVG(f.salario) AS MONEY) AS "Média Salarial"
FROM
	departamento AS d
	NATURAL JOIN
	funcionario AS f
GROUP BY
	d.nome_departamento
ORDER BY
	d.nome_departamento ASC;

----------------------------------------//----------------------------------------

-- QUESTÃO 11: considerando que o valor pago por hora trabalhada em um projeto
-- é de 50 reais, prepare um relatório que mostre o nome completo do funcionário, o
-- nome do projeto e o valor total que o funcionário receberá referente às horas
-- trabalhadas naquele projeto.

SELECT
	CONCAT(f.primeiro_nome, ' ', f.nome_meio, '. ', f.ultimo_nome) AS "Nome do Funcionário",
	p.nome_projeto AS "Nome do Projeto",
	CAST(50 * te.horas AS MONEY) AS "Valor"
FROM
	trabalha_em AS te
	NATURAL JOIN
	projeto AS p
	INNER JOIN
	funcionario AS f
	ON
		te.cpf_funcionario = f.cpf
ORDER BY
	"Nome do Funcionário" ASC,
	"Nome do Projeto" ASC;

----------------------------------------//----------------------------------------

-- QUESTÃO 12: seu chefe está verificando as horas trabalhadas pelos funcionários
-- nos projetos e percebeu que alguns funcionários, mesmo estando alocadas à algum
-- projeto, não registraram nenhuma hora trabalhada. Sua tarefa é preparar um
-- relatório que liste o nome do departamento, o nome do projeto e o nome dos funcionários
-- que, mesmo estando alocados a algum projeto, não registraram nenhuma hora trabalhada.

SELECT
	d.nome_departamento AS "Nome do Departamento",
	p.nome_projeto AS "Nome do Projeto",
	CONCAT(f.primeiro_nome, ' ', f.nome_meio, '. ', f.ultimo_nome) AS "Nome do Funcionário"
FROM
	departamento AS d
	NATURAL JOIN
	projeto AS p
	NATURAL JOIN
	funcionario AS f
	INNER JOIN
	trabalha_em AS te
	ON
		te.cpf_funcionario = f.cpf
WHERE
	te.horas IS NULL;

----------------------------------------//----------------------------------------

-- QUESTÃO 13: durante o natal deste ano a empresa irá presentear todos os
-- funcionários e todos os dependentes (sim, a empresa vai dar um presente para cada
-- funcionário e um presente para cada dependente de cada funcionário) e pediu para
-- que você preparasse um relatório que listasse o nome completo das pessoas a serem
-- presenteadas (funcionários e dependentes), o sexo e a idade em anos completos
-- (para poder comprar um presente adequado). Esse relatório deve estar ordenado
-- pela idade em anos completos, de forma decrescente.

SELECT
	CONCAT(f.primeiro_nome, ' ', f.nome_meio, '. ', f.ultimo_nome) AS "Nome",
	CASE f.sexo
		WHEN 'F' THEN 'Feminino'
		WHEN 'M' THEN 'Masculino'
	END AS "Sexo",
	DATE_PART('year', AGE(CURRENT_DATE, f.data_nascimento)) AS "Idade"
FROM
	funcionario AS f
UNION
SELECT
	dep.nome_dependente AS "Nome",
	CASE dep.sexo
		WHEN 'F' THEN 'Feminino'
		WHEN 'M' THEN 'Masculino'
	END AS "Sexo",
	DATE_PART('year', AGE(CURRENT_DATE, dep.data_nascimento)) AS "Idade"
FROM
	dependente AS dep
ORDER BY
	"Idade" DESC;

----------------------------------------//----------------------------------------

-- QUESTÃO 14: prepare um relatório que exibaquantos funcionários cada departamento tem.

SELECT
	d.nome_departamento AS "Nome do Departamento",
	COUNT(f.cpf) AS "Número de Funcionários"
FROM
	departamento AS d
	NATURAL JOIN
	funcionario AS f
GROUP BY
	d.numero_departamento
ORDER BY
	"Nome do Departamento" ASC;

----------------------------------------//----------------------------------------

-- QUESTÃO 15: como um funcionário pode estar alocado em mais de um projeto,
-- prepare um relatório que exiba o nome completo do funcionário, o departamento
-- desse funcionário e o nome dos projetos em que cada funcionário está alocado.
-- Atenção: se houver algum funcionário que não está alocado em nenhum projeto,
-- o nome completo e o departamento também devem aparecer no relatório.

SELECT
	CONCAT(f.primeiro_nome, ' ', f.nome_meio, '. ', f.ultimo_nome) AS "Nome do Funcionário",
	d.nome_departamento AS "Nome do Departamento",
	p.nome_projeto AS "Nome do Projeto"
FROM
	departamento AS d
	NATURAL JOIN
	projeto AS p
	NATURAL JOIN
	trabalha_em AS te
	RIGHT OUTER JOIN
	funcionario AS f
	ON
		te.cpf_funcionario = f.cpf
ORDER BY
	"Nome do Funcionário" ASC,
	"Nome do Departamento" ASC;