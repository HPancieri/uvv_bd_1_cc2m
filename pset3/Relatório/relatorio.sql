/*

Relatório SQL Recursivo
Autor: Hygor Oliveira Pancieri
Professor: Abrantes Araújo Silva Filho

*/

----------------------------------------//----------------------------------------

WITH RECURSIVE lista AS (
	SELECT
		pai.codigo,
		pai.codigo_pai,
		pai.nome,
		CAST(pai.nome AS VARCHAR) AS "Classificações"
	FROM
		classificacao AS pai
	WHERE
		pai.codigo_pai IS NULL
UNION ALL
	SELECT
		filho.codigo,
		filho.codigo_pai,
		filho.nome,
		l."Classificações" || ' --> ' || filho.nome AS "Classificações"
	FROM
		classificacao AS filho INNER JOIN lista AS l
		ON filho.codigo_pai = l.codigo
	WHERE
		filho.codigo_pai IS NOT NULL
) SELECT
	"Classificações"
FROM
	lista
ORDER BY
	"Classificações" ASC;
