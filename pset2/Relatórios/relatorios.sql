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
	CONCAT(f.primeiro_nome, ' ', f.nome_meio, '. ', f.ultimo_nome),
	DATE_PART('year', AGE(CURRENT_DATE, f.data_nascimento)),
	CAST(f.salario AS MONEY),
	CAST(f.salario * 1.15 AS MONEY)
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
	gerentes.nome_departamento AS "Nome do Departamento",
	CONCAT(gerentes.primeiro_nome, ' ', gerentes.nome_meio, '. ', gerentes.ultimo_nome) AS "Nome do Gerente",
	CONCAT(funcionarios.primeiro_nome, ' ', funcionarios.nome_meio, '. ', funcionarios.ultimo_nome) AS "Nome do Funcionario"
FROM
	(
		departamento
		INNER JOIN
		funcionario
		ON
			departamento.cpf_gerente = funcionario.cpf
	) AS gerentes,
	(
		departamento
		INNER JOIN
		funcionario
		ON
			departamento.numero_departamento = funcionario.numero_departamento
	) AS funcionarios
ORDER BY
	gerentes.nome_departamento ASC,
	funcionarios.salario DESC;

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
