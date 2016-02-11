//Author: Jagjinder Singh - jagjindersingh@uchicago.edu
CREATE CONSTRAINT ON (p:Person) ASSERT p.id IS UNIQUE;
CREATE CONSTRAINT ON (m:Merchant) ASSERT m.merchant_name IS UNIQUE;
CREATE CONSTRAINT ON (a:Address) ASSERT a.address IS UNIQUE;

//export FILEPATH=file:///neo4j/community/code/data/adults_2550_male_urban_fraud.csv
//export FILEPATH=file:///neo4j/community/code/adults_2550_male_urban_fraud.csv
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS 
FROM "file:///neo4j/community/code/data/data-4.csv" AS line FIELDTERMINATOR '|'
WITH line.street+' '+line.city+' '+line.state+' '+line.zip as address,
	line.street AS street,
	line.city AS city,
	line.state AS state,
	line.zip AS zip,
	SPLIT(line.dob,'-') AS dob,
	SPLIT(line.trans_date,'-') AS trans_date,
	line.cc_num AS cc_num,
	line.ssn AS ssn,
	line.first AS first,
	line.last AS last,
	line.gender AS gender,
	line.job AS job,
	line.lat AS latitude,
	line.long AS longitude,
	line.merchant AS merchant_name,
	line.merch_lat AS merch_lat,
	line.merch_long AS merch_long,
	line.trans_num AS trans_num,
	line.amt AS amount,
	line.category AS cat,
	line.is_fraud AS is_fraud,
	line.trans_time AS trans_time,
	line.unix_time AS unix_time

//merging all duplicate rows for persons into one node for each person
MERGE (person:Person {id:TOINT(cc_num), first_name:first, last_name:last, social:ssn, gender:gender, job:job, year:dob[0], month:dob[1], day:dob[2]})

//merging all duplicate rows for merchants into one node for each merchant
MERGE (merchant:Merchant {merchant_name: UPPER(merchant_name)})

//merging all duplicate rows for addresses into one node for each person
MERGE (p_address:Address {address:UPPER(address), latitude:TOFLOAT(latitude), longitude:TOFLOAT(longitude), street:UPPER(street), city:UPPER(city), state:UPPER(state), zip:TOINT(zip)})

//create relationship between the person and the merchant
CREATE (person)-[t:BOUGHT_AT {trans:TOINT(trans_num), amount:TOFLOAT(amount), trans_date:trans_date, trans_time:trans_time, category: cat, status:is_fraud, unix_time:TOINT(unix_time)}]->(merchant)

//create relationship between persons and their respective addresses
MERGE (person)-[:LIVES_AT]->(p_address)

SET t.fraud = CASE is_fraud WHEN '1' THEN true ELSE false END
;

//create relationship when two or more persons share same address
MATCH (p:Person)-[:LIVES_AT]->(a:Address),
	(a)<-[:LIVES_AT]-(p2:Person)
CREATE (p)-[:KNOWS]->(p2)
;
