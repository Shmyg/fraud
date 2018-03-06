LOAD	DATA
INFILE	*
INTO	TABLE customer_types
FIELDS	TERMINATED BY ';'
	(
	customer_type_id INTEGER EXTERNAL,
	customer_type_des
	)
BEGINDATA
0;Postpaid
1;SimSim
2;Jeans
3;Roamer
4;Unknown
