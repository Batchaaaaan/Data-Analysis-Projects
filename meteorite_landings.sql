DROP TABLE meteorite_data_raw; 

--create table for raw data
CREATE TABLE meteorite_data_raw(
	id SERIAL,
	name VARCHAR(100),
	meteor_id INTEGER,
	nametype VARCHAR(20),
	reclass VARCHAR(50),
	mass NUMERIC,
	fall VARCHAR(50),
	year INTEGER,
	reclat NUMERIC,
	reclong NUMERIC,
	geolocation TEXT);

--copy the csv file into the table created
COPY meteorite_data_raw(name,meteor_id,nametype,reclass,mass,fall,year,reclat,reclong,geolocation)
FROM 'D:\datasets\Meteorite_Landings.csv'
WITH (FORMAT CSV, HEADER);


SELECT * FROM meteorite_data_raw;


--create dimension tables
CREATE TABLE meteorite_name_validity(
	id SERIAL PRIMARY KEY,
	nametype VARCHAR(10) UNIQUE);
	
	
CREATE TABLE meteor_fell_or_found(
	id SERIAL PRIMARY KEY,
	name VARCHAR(10) UNIQUE);


CREATE TABLE reclass_data(
	id SERIAL PRIMARY KEY,
	name VARCHAR(30)
);

--create the fact table
CREATE TABLE meteorite_data(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50),
	meteorite_id INTEGER,
	nametype_id INTEGER REFERENCES meteorite_name_validity ON DELETE CASCADE,
	nametype VARCHAR(50),
	reclass_id INTEGER REFERENCES reclass_data ON DELETE CASCADE,
	reclass VARCHAR(50),
	mass NUMERIC,
	fall_id INTEGER REFERENCES meteor_fell_or_found ON DELETE CASCADE,
	fall VARCHAR(50),
	year INTEGER,
	reclat NUMERIC(9,6),
	reclong NUMERIC(9,6)
);


--insert data into dimension table
INSERT INTO meteorite_name_validity(nametype) 
SELECT nametype
FROM meteorite_data_raw
GROUP BY nametype;

SELECT * FROM meteorite_name_validity;


INSERT INTO meteor_fell_or_found(name)
SELECT fall
FROM meteorite_data_raw
GROUP BY fall;

SELECT * FROM meteor_fell_or_found;


INSERT INTO reclass_data(name)
SELECT reclass
FROM meteorite_data_raw
GROUP BY reclass;

SELECT * FROM reclass_data;

INSERT INTO meteorite_data(name,meteorite_id,nametype,reclass,mass,fall,year,reclat,reclong)
SELECT name,meteor_id,nametype,reclass,mass,fall,year,reclat,reclong
FROM meteorite_data_raw;

SELECT * FROM meteorite_data;

--update the fact table and insert data
UPDATE meteorite_data SET nametype_id = 
(SELECT meteorite_name_validity.id 
 FROM meteorite_name_validity 
 WHERE meteorite_name_validity.nametype = meteorite_data.nametype);
 
SELECT * FROM meteorite_data;


UPDATE meteorite_data SET reclass_id = 
(SELECT reclass_data.id
FROM reclass_data
WHERE reclass_data.name = meteorite_data.reclass);

SELECT * FROM meteorite_data;


UPDATE meteorite_data SET fall_id = 
(SELECT meteor_fell_or_found.id
FROM meteor_fell_or_found
WHERE meteor_fell_or_found.name = meteorite_data.name);

SELECT * FROM meteor_fell_or_found;


ALTER TABLE meteorite_data DROP COLUMN nametype;
ALTER TABLE meteorite_data DROP COLUMN reclass;
ALTER TABLE meteorite_data DROP COLUMN fall;

SELECT * FROM meteorite_data ORDER BY id;

DROP TABLE meteorite_data_raw;

--Data exploration


--Query the count of each class of the meteorite from highest to lowest count
SELECT reclass_data.name, count(*) AS TOTAL
FROM meteorite_data JOIN reclass_data
ON meteorite_data.reclass_id = reclass_data.id
GROUP BY reclass_data.name
ORDER BY TOTAL DESC;


--Query the count of meteoriote sightings grouped by year
SELECT year,count(*) AS TOTAL
FROM meteorite_data
GROUP BY year
ORDER BY total DESC
LIMIT 10;


--Query the count of different meteorite classifications grouped by year 2023
SELECT r.name, m.year,count(*) TOTAL
FROM meteorite_data m JOIN reclass_data r
ON m.reclass_id = r.id
WHERE year = '2003'
GROUP BY r.name,year
ORDER BY total DESC
LIMIT 10;

--Query the total count of fell or found meteorites 
SELECT f.name fall, count(*) TOTAL
FROM meteorite_data m JOIN meteor_fell_or_found f
ON m.fall_id = f.id
GROUP BY f.name
ORDER BY total;

SELECT * FROM meteorite_data;

