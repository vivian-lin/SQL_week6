-- RELATIVELY SIMPLE JOINS
-- What languages are spoken in the United States? (12) Brazil? (not Spanish...) Belgium? (6)
SELECT
	cl.language
FROM
	countries c JOIN countrylanguages cl ON c.code = cl.countrycode
WHERE
	c.code = 'USA' --'BEL'
-- What are the cities of the US? (274) India? (341)
SELECT
	ct.name
FROM
	countries c JOIN cities ct ON c.code = ct.countrycode
WHERE
	c.code = 'USA' --'IND'

-- LANGUAGES
-- What are the official languages of Belgium?
SELECT
	cl.language
FROM
	countrylanguages AS cl
WHERE
	cl.countrycode = 'BEL'
	AND
	cl.isofficial = true
-- Which country or countries speak the most languages?
WITH total_lang AS
	(SELECT
		*
	FROM
		countrylanguages AS cl)
SELECT
	tl.countrycode,
	c.name,
	COUNT(tl.countrycode) AS totallanguages
FROM
	total_lang tl JOIN countries c ON tl.countrycode = c.code
GROUP BY
	tl.countrycode,
	c.name
ORDER BY
	totallanguages DESC
-- Which country or countries have the most official languages?
WITH official_lang AS
	(SELECT
		*
	FROM
		countrylanguages AS cl
	WHERE
		cl.isofficial = true)
SELECT
	ol.countrycode,
	c.name,
	COUNT(ol.countrycode) AS olc
FROM
	official_lang ol JOIN countries c ON ol.countrycode = c.code
GROUP BY
	ol.countrycode,
	c.name
ORDER BY
	olc DESC
-- Which languages are spoken in the ten largest (area) countries?
-- Hint: Use WITH to get the countries and join with that table
WITH largest_countries AS
  (SELECT
  	*
  FROM
  	countries AS c
  ORDER BY
  	c.surfacearea DESC
  LIMIT
  	10)
SELECT DISTINCT
	cl.language
FROM
	largest_countries lc JOIN countrylanguages cl ON lc.code = cl.countrycode
-- What languages are spoken in the 20 poorest (GNP/ capita) countries in the world? (94?)
-- Hint: Use WITH to get the countries, and SELECT DISTINCT to remove duplicates
WITH poorest_countries AS
  (SELECT
  	c.code,
  	c.name AS country_name,
  	c.gnp / c.population AS gnp_per_capita
  FROM
  	public.countries AS c
  WHERE
  	c.population > 0
  	AND
  	c.gnp > 0
  ORDER BY
  	gnp_per_capita ASC
  LIMIT
  	20)
SELECT DISTINCT
	cl.language
FROM
	poorest_countries pc JOIN countrylanguages cl ON pc.code = cl.countrycode;
-- Are there any countries without an official language?
-- Hint: Use NOT IN with a SELECT
WITH total_unofficial AS
  (SELECT
    	c.name,
    	COUNT(cl.isofficial) AS unofficial_languages
  FROM
    	countries c JOIN countrylanguages cl ON c.code = cl.countrycode
  WHERE
    	cl.isofficial = false
  GROUP BY
    	c.name),
total_languages AS
  (SELECT
      	c.name,
      	COUNT(cl.language) AS total_lang
  FROM
      	countries c JOIN countrylanguages cl ON c.code = cl.countrycode
  GROUP BY
    	c.name)
SELECT
	tl.name,
	tuo.unofficial_languages,
	tl.total_lang
FROM
	total_unofficial tuo JOIN total_languages tl ON tuo.name = tl.name
WHERE
	tuo.unofficial_languages = tl.total_lang
GROUP BY
	tl.name,
	tuo.unofficial_languages,
	tl.total_lang;
--VERSION 2!!!!!
  SELECT
  	c.name
  FROM
  	countries AS c
  WHERE c.name NOT IN (SELECT
  			c.name
  		FROM
  			countries c JOIN countrylanguages cl ON c.code = cl.countrycode
  		WHERE
  			cl.isofficial = true)
-- What are the languages spoken in the countries with no official language?
WITH no_official_language_countries AS
(SELECT
	c.name,
	c.code
FROM
	countries AS c
WHERE c.name NOT IN (SELECT
			c.name
		FROM
			countries c JOIN countrylanguages cl ON c.code = cl.countrycode
		WHERE
			cl.isofficial = true))
SELECT DISTINCT
	cl.language
FROM
	no_official_language_countries nolc JOIN countrylanguages cl ON nolc.code = cl.countrycode
-- Which countries have the highest proportion of official language speakers? The lowest?
WITH official_languages AS
(SELECT
	*
FROM
	countrylanguages AS cl
WHERE
	cl.isofficial = true
ORDER BY
	cl.percentage DESC) --ASC for lowest
SELECT
	c.name,
	ol.language,
	ol.percentage
FROM
	official_languages ol JOIN countries c ON ol.countrycode = c.code
-- What is the most spoken language in the world?
SELECT
	cl.language,
	COUNT(cl.language) AS count_languages
FROM
	countrylanguages AS cl
GROUP BY
	cl.language
ORDER BY
	count_languages DESC
-- CITIES
-- What is the population of the United States? What is the city population of the United States?
SELECT
	population
FROM
	countries
WHERE
	countries.name = 'United States'
-----------
SELECT
	SUM(ct.population)
FROM
	countries c JOIN cities ct ON c.code = ct.countrycode
WHERE
	c.name = 'United States'
-- What is the population of the India? What is the city population of the India?
SELECT
	population
FROM
	countries
WHERE
	countries.name = 'India'
-----------
SELECT
	SUM(ct.population)
FROM
	countries c JOIN cities ct ON c.code = ct.countrycode
WHERE
	c.name = 'India'
-- Which countries have no cities? (7 not really contries...)
SELECT
	c.name
FROM
	countries AS c
WHERE c.name
	NOT IN
	(SELECT DISTINCT
	  c.name
	FROM
    cities ct JOIN countries c ON ct.countrycode = c.code)
-- LANGUAGES AND CITIES
-- What is the total population of cities where English is the offical language? Spanish?
-- Hint: The official language of a city is based on country.
SELECT
  SUM(ct.population)
FROM
  countrylanguages cl JOIN cities ct ON cl.countrycode = ct.countrycode
WHERE
  cl.language = 'English'
  AND
  cl.isofficial = 't'; --'Spanish'
-- Which countries have the 100 biggest cities in the world?
WITH biggest_cities AS
  (SELECT
  	*
  FROM
  	cities
  ORDER BY
  	cities.population DESC
  LIMIT
  	100
  )
SELECT DISTINCT
	c.name
FROM
	countries c JOIN biggest_cities bc ON c.code = bc.countrycode
-- What languages are spoken in the countries with the 100 biggest cities in the world?
WITH biggest_cities AS
  (SELECT
  	*
  FROM
  	cities
  ORDER BY
  	cities.population DESC
  LIMIT
  	100
  )
SELECT DISTINCT
	cl.language
FROM
	countrylanguages cl JOIN biggest_cities bc ON cl.countrycode = bc.countrycode
