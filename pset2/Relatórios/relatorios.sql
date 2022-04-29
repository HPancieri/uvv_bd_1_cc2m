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