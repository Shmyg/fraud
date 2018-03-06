UNRECOVERABLE LOAD DATA
APPEND
INTO	TABLE msc_data
WHEN	call_type_id != '910'
FIELDS	TERMINATED BY ','
TRAILING NULLCOLS
	(
	file_id		INTEGER EXTERNAL,
	is_deleted	CHAR,
	record_type_id	INTEGER EXTERNAL,
	call_type_id		INTEGER EXTERNAL,
	customer_type_id	INTEGER EXTERNAL,
	dn_num		CHAR,
	imsi		CHAR,
	imei		CHAR,
	msrn		CHAR,
	b_number	CHAR,
	trans_b_number	CHAR,
	c_number	CHAR,
	call_date	DATE 'YYYY-MM-DD hh24:mi:ss',
	duration	INTEGER EXTERNAL,
	trunk_in	CHAR,
	trunk_out	CHAR,
	msc_no		CHAR,
	mcc		FILLER CHAR TERMINATED BY '-',
	mnc		FILLER CHAR TERMINATED BY '-',
	lac		FILLER CHAR TERMINATED BY '-',
	cid		CHAR,
	trash10		FILLER CHAR,
	b_msrn		CHAR,
	trash12		FILLER CHAR,
	trash13		FILLER CHAR,
	trash14		FILLER CHAR
	)
INTO	TABLE msc_data
WHEN	call_type_id = '910'
FIELDS	TERMINATED BY ','
TRAILING NULLCOLS
	(
	file_id		POSITION(1) INTEGER EXTERNAL,
	is_deleted	CHAR,
	record_type_id	INTEGER EXTERNAL,
	call_type_id		INTEGER EXTERNAL,
	customer_type_id	INTEGER EXTERNAL,
	dn_num		CHAR,
	imsi		CHAR,
	imei		CHAR,
	msrn		CHAR,
	b_number	CHAR,
	trans_b_number	CHAR,
	c_number	CHAR,
	call_date	DATE 'YYYY-MM-DD hh24:mi:ss',
	duration	INTEGER EXTERNAL,
	volume_up	INTEGER EXTERNAL,
	volume_down	INTEGER EXTERNAL,
	msc_no		CHAR,
	mcc		FILLER CHAR TERMINATED BY '-',
	mnc		FILLER CHAR TERMINATED BY '-',
	lac		FILLER CHAR TERMINATED BY '-',
	cid		CHAR,
	trash10		FILLER CHAR,
	b_msrn		CHAR,
	trash12		FILLER CHAR,
	trash13		FILLER CHAR,
	trash14		FILLER CHAR
	)
