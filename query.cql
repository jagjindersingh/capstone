//return all transactions which are only fraud
MATCH ()-[r:BOUGHT_AT {fraud:true}]->() RETURN r LIMIT 50;

//return all transactions which are only fraud
MATCH (victim:Person)-[r:BOUGHT_AT{fraud:true}]->(merchant)
RETURN victim.id as `Credit Card#`, 
		victim.first_name+' '+victim.last_name as Person, 
		merchant.merchant_name as Merchant,
		r.amount as Amount, 
		r.category as Category,
		r.trans_date[0]+'/'+r.trans_date[1]+'/'+r.trans_date[2] as Trans_date, 
		r.trans_time as Trans_time
ORDER BY Trans_date DESC, Trans_time DESC
LIMIT 25;

//return customers with most frauds and respective total amount
MATCH (victim:Person)-[r:BOUGHT_AT{fraud:true}]->(merchant)
RETURN victim.id as `Credit Card#`, 
	victim.first_name+' '+victim.last_name as Person, 
	COUNT(victim.id) as `Total Transaction Count`, 
	SUM(distinct r.amount) as `Total Fraud Amt`	
ORDER BY `Total Transaction Count` DESC, `Total Fraud Amt` DESC;

//return nodes of customer having highest frauds
MATCH ({id:5296348804609746})-[r:BOUGHT_AT{fraud:true}]->() RETURN r LIMIT 50;

//return merchants with most frauds and respective total amount
MATCH (victim:Person)-[r:BOUGHT_AT{fraud:true}]->(merchant)
RETURN merchant.merchant_name as merchant_name,  
	COUNT(merchant.merchant_name) as fraud_incidents, 
	SUM(distinct r.amount) as cc_amt
ORDER BY fraud_incidents DESC, cc_amt DESC;

//return nodes of merchant having highest frauds
MATCH ()-[r:BOUGHT_AT]->({merchant_name:"DOYLE LTD"}) RETURN r LIMIT 50;

//Matches customers living at same address
MATCH (p1)-[x:LIVES_AT]->(a1:Address)
MATCH (p2)-[y:LIVES_AT]-(a2:Address)
WHERE 	
	p1.id <> p2.id and 
	a1.address = a2.address
	RETURN DISTINCT p1.id AS cc_num, p1.first_name AS Person, p2.first_name AS Knows, 
	a1.address AS address
LIMIT 25
;



//return all transactions where job, category and merchant matches
MATCH (p1:Person)-[r:BOUGHT_AT{fraud:true}]->(m1:Merchant)
MATCH (p2:Person)-[t:BOUGHT_AT{fraud:true}]-(m2:Merchant)
WHERE 	p1.id <> p2.id and 
		p1.job = p2.job AND 
		m1.merchant_name = m2.merchant_name AND
		r.category = t.category 
RETURN DISTINCT p1.id as cc_num, p1.job, p2.id, p2.job, r.category, t.category, m1.merchant_name, m2.merchant_name
ORDER BY cc_num ASC, p2.id ASC
LIMIT 25
;

//return all transactions where job, category, merchant and city matches - no rows in datasets
MATCH (p1:Person)-[r:BOUGHT_AT{fraud:true}]->(m1:Merchant)
MATCH (p2:Person)-[t:BOUGHT_AT{fraud:true}]-(m2:Merchant)
MATCH (p1)-[x:LIVES_AT]->(a1:Address)
MATCH (p2)-[y:LIVES_AT]-(a2:Address)
WHERE 	
	p1.id <> p2.id and 
	p1.job = p2.job AND 
	m1.merchant_name = m2.merchant_name AND
	r.category = t.category AND
	a1.city = a2.city AND
	a1.state = a2.state
RETURN DISTINCT p1.id AS cc_num, p1.job AS job, p1.first_name AS first_name, p2.first_name AS second_person, 
	m1.merchant_name AS merchant_name, a1.city AS city, a2.city, a1.state AS state, a2.state
LIMIT 25
;


//matches the ID, job, merchant and state.
MATCH (p1:Person)-[r:BOUGHT_AT{fraud:true}]->(m1:Merchant)
MATCH (p2:Person)-[t:BOUGHT_AT{fraud:true}]-(m2:Merchant)
MATCH (p1)-[x:LIVES_AT]->(a1:Address)
MATCH (p2)-[y:LIVES_AT]-(a2:Address)
WHERE 	
	p1.id <> p2.id and 
	p1.job = p2.job AND 
	m1.merchant_name = m2.merchant_name AND
	a1.state = a2.state
RETURN DISTINCT p1.id AS cc_num, p1.job AS job, p1.first_name AS first_name, p2.first_name AS second_person, 
	m1.merchant_name AS merchant_name, a1.city AS city, a2.city, a1.state AS state, a2.state
LIMIT 25
;



//matches the ID, category, merchant, city and state.
MATCH (p1:Person)-[r:BOUGHT_AT{fraud:true}]->(m1:Merchant)
MATCH (p2:Person)-[t:BOUGHT_AT{fraud:true}]-(m2:Merchant)
MATCH (p1)-[x:LIVES_AT]->(a1:Address)
MATCH (p2)-[y:LIVES_AT]-(a2:Address)
WHERE 	
	p1.id <> p2.id and 
	r.category=t.category AND 
	m1.merchant_name = m2.merchant_name AND
	a1.state = a2.state
RETURN DISTINCT p1.id AS cc_num, p1.job AS job, p1.first_name AS first_name, p2.first_name AS second_person, 
	m1.merchant_name AS merchant_name, r.category as Category, a1.city AS city, a1.state AS state
LIMIT 25
;

MATCH ({id:5296348804609746})-[r:LIVES_AT]->() RETURN r LIMIT 50;


//not working
MATCH (p:Person)-[r:BOUGHT_AT{fraud:true}]->() 
WHERE p.id = 529634880460974 or p.id = 5270441615999263
RETURN r LIMIT 50;

//total fraud in a ring
//MATCH (victim:Person)-[r:BOUGHT_AT{fraud:true}]->(merchant)
MATCH victim-[t:BOUGHT_AT{fraud:true}]->(othermerchants)
//WHERE t.fraud=false AND t.trans_time<r.trans_time
WITH victim, othermerchants, t ORDER BY t.time DESC
RETURN DISTINCT othermerchants.merchant_name AS `Merchant`, count(DISTINCT t) AS Count, 
collect(DISTINCT victim.first_name) AS `Person`,
	SUM(distinct t.amount) as `Transaction Amount`
ORDER BY Count DESC
;


MATCH (victim:Person)-[r:BOUGHT_AT{fraud:true}]->(merchant)
MATCH victim-[t:BOUGHT_AT]->(othermerchants)
WHERE t.fraud=false AND t.trans_time<r.trans_time
WITH victim, othermerchants, t ORDER BY t.time DESC
RETURN DISTINCT victim.first_name AS `Customer Name`, 
othermerchants.merchant_name AS `Store Name`, t.amount AS Amount,
t.trans_date[0]+'/'+t.trans_date[1]+'/'+t.trans_date[2] as `Trans Date`,t.trans_time AS `Transaction Time`
ORDER BY `Trans Date` DESC,`Transaction Time` DESC
;

//total fraud in a ring
MATCH (victim:Person)-[r:BOUGHT_AT{fraud:true}]->(merchant)
MATCH victim-[t:BOUGHT_AT]->(othermerchants)
WHERE t.fraud=false AND t.trans_time<r.trans_time
WITH victim, othermerchants, t ORDER BY t.time DESC
RETURN DISTINCT othermerchants.merchant_name AS `Merchant`, count(DISTINCT t) AS Count, 
collect(DISTINCT victim.first_name) AS `Person`,
	SUM(distinct t.amount) as `Transaction Amount`
ORDER BY Count DESC
;
