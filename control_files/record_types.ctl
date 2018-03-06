LOAD	DATA
INFILE	*
INTO	TABLE record_types
FIELDS	TERMINATED BY ';'
	(
	record_type_des,
	record_type_id	INTEGER EXTERNAL
	)
BEGINDATA
singleBillingRecordA;0
firstBillingRecordA;1
intermediateBillingRecordA;2
lastBillingRecordA;3
singleBillingRecordB;4
firstBillingRecordB;5
intermediateBillingRecordB;6
lastBillingRecordB;7
