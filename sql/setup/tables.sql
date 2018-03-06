/*
|| Script for creating all the tables in RA schema
|| Created by Shmyg
|| $Log: tables.sql,v $
|| Revision 1.3  2006/03/22 14:07:30  shmyg
|| New release
||
|| Revision 1.2  2006/03/20 08:41:44  shmyg
|| Added some fields to MSC_DATA table
||
|| Revision 1.1  2006-03-16 12:17:22  shmyg
|| First release
||
*/

SET ECHO ON
SET VERIFY ON
SET SERVEROUTPUT ON

CREATE	TABLE &owner..zone_rates
	(
	priority	NUMBER NOT NULL,
	rate_des	VARCHAR2(60) NOT NULL,
	CONSTRAINT	pk_zone_rates
	PRIMARY	KEY
		(
		priority
		)
	)
ORGANIZATION	INDEX
PCTFREE	0
/

CREATE	TABLE &owner..zones
	(
	zpcode		NUMBER NOT NULL,
	des		VARCHAR2(30) NOT NULL,
	digits		VARCHAR2(63) NOT NULL,
	priority	NUMBER NOT NULL,
	zone_name	VARCHAR2(30) NOT NULL
	CONSTRAINT	pkzones
	PRIMARY KEY
		(
		digits
		)
	)
ORGANIZATION	INDEX
PCTFREE	0
/

COMMENT ON COLUMN &owner..zones.zone_name IS 'Global zone name, e.g. Kyivstar, international etc'
/

-- Constraints
ALTER	TABLE &owner..zones
ADD	CONSTRAINT fkzones_zone_rates
FOREIGN	KEY ( priority )
REFERENCES &owner..zone_rates( priority )
/

CREATE	TABLE &owner..call_types
	(
	call_type_id	NUMBER(3),
	call_type_des	VARCHAR2(50) NOT NULL,
	CONSTRAINT pk_call_types
	PRIMARY KEY
		(
		call_type_id
		)
	)
ORGANIZATION INDEX
PCTFREE	0
/

CREATE	TABLE &owner..customer_types
	(
	customer_type_id	NUMBER(1),
	customer_type_des	VARCHAR2(20),
	CONSTRAINT pk_customer_types
	PRIMARY KEY
		(
		customer_type_id
		)
	)
ORGANIZATION INDEX
PCTFREE	0
/

CREATE	TABLE &owner..record_types
	(
	record_type_id	NUMBER(1),
	record_type_des	VARCHAR2(30),
	CONSTRAINT pk_record_types
	PRIMARY	KEY
		(
		record_type_id
		)
	)
ORGANIZATION INDEX
PCTFREE	0
/

-- This is the main table. It will have one partition for each day
-- subpartition by call types. Partitions will be added nighthly for
-- the next day. It is possible to create subpartition template
-- but maybe it is better to have subpartitions specification in the script
CREATE  TABLE &owner..msc_data
        (
	file_id		NUMBER NOT NULL,
        call_type_id    NUMBER(3),
        record_type_id  NUMBER(1),
        customer_type_id        NUMBER(1),
        call_date       DATE,
        duration        NUMBER,
        msc_no          VARCHAR2(8),
	is_deleted	VARCHAR2(1),
        cid             VARCHAR2(4),
        imei            VARCHAR2(16),
        imsi            VARCHAR2(16),
        dn_num          VARCHAR2(24),
	msrn		VARCHAR2(24),
        b_number        VARCHAR2(30),
	b_msrn		VARCHAR2(24),
	trans_b_number	VARCHAR2(24),
	c_number	VARCHAR2(24),
        trunk_in        VARCHAR2(8),
        trunk_out       VARCHAR2(8),
	volume_up	NUMBER,
	volume_down	NUMBER
	)
PARTITION BY RANGE ( call_date )
SUBPARTITION BY LIST ( call_type_id )
        (
        PARTITION part_18022006 VALUES LESS THAN ( TO_DATE( '18.02.2006', 'DD.MM.YYYY' ) ) 
	PCTFREE 0
	STORAGE
		(
		INITIAL 16M
		NEXT 16M
		)
	COMPRESS
                (
                SUBPARTITION part_18022006_1 VALUES (30),
                SUBPARTITION part_18022006_2 VALUES (31),
                SUBPARTITION part_18022006_3 VALUES (1),
                SUBPARTITION part_18022006_4 VALUES (2),
                SUBPARTITION part_18022006_5 VALUES (DEFAULT)
                )
        )
/

COMMENT ON TABLE &owner..msc_data IS 'Contains all the events recorded by MSCs'
/
COMMENT ON COLUMN &owner..msc_data.call_type_id IS 'Call type - FK to CALL_TYPES'
/
COMMENT ON COLUMN &owner..msc_data.record_type_id IS 'Record type - FK to RECORD_TYPES'
/
COMMENT ON COLUMN &owner..msc_data.customer_type_id IS 'Customer type - FK to CUSTOMER_TYPES'
/
COMMENT ON COLUMN &owner..msc_data.msc_no IS 'MSC SPC or SGSN IP-address in hex format'
/
COMMENT ON COLUMN &owner..msc_data.b_number IS 'Other party number'
/
COMMENT ON COLUMN &owner..msc_data.msrn IS 'Mobile subscriber roaming number'
/
COMMENT ON COLUMN &owner..msc_data.b_msrn IS 'Other party MSRN'
/
COMMENT ON COLUMN &owner..msc_data.trans_b_number IS 'Translated other party number'
/
COMMENT ON COLUMN &owner..msc_data.c_number IS 'Third party number'
/

ALTER	TABLE &owner..msc_data PARALLEL 8;

CREATE	TABLE &owner..times
	(
	day,
	week_num,
	mmyyyy,
	yyyy
	)
AS
SELECT	SYSDATE + LEVEL,
	CAST ( TO_CHAR( ( SYSDATE + LEVEL ), 'IWYYYY' ) AS NUMBER ) AS week_num,
	CAST ( TO_CHAR( ( SYSDATE + LEVEL ), 'MMYYYY' ) AS NUMBER ) AS mmyyyy,
	CAST ( TO_CHAR( ( SYSDATE + LEVEL ), 'YYYY' ) AS NUMBER ) AS yyyy
FROM	DUAL
CONNECT	BY LEVEL < 5001
/

CREATE	DIMENSION &owner..times_dim
	LEVEL	day IS &owner..times.day
	LEVEL	week_num IS &owner..times.week_num
	LEVEL	mmyyyy IS &owner..times.mmyyyy
	LEVEL	yyyy IS &owner..times.yyyy
HIERARCHY times_rollup
	(
	day		CHILD OF
	week_num	CHILD OF
	mmyyyy		CHILD OF
	yyyy
	)
/

CREATE	TABLE	&owner..fraud_config
	(
	timeframe	NUMBER NOT NULL,
	moc_type_id	NUMBER NOT NULL,
	umc_imsi_prefix	VARCHAR2(3) NOT NULL,
	max_calls_qty	NUMBER NOT NULL,
	max_calls_dur	NUMBER NOT NULL
	)
PCTFREE	0
/
	 
CREATE	TABLE &owner..loaded_files
	(
	file_id		NUMBER,
	file_name	VARCHAR2(100) NOT NULL,
	load_date	DATE DEFAULT SYSDATE,
	CONSTRAINT	pk_loaded_files
	PRIMARY	KEY
		(
		file_id
		)
	)
ORGANIZATION INDEX
PCTFREE	0
/

CREATE	SEQUENCE &owner..file_id_seq
/

