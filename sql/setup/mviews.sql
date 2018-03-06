/*
|| Script for creating MVIEWS in RA schema
|| Created by Shmyg
|| $Log: mviews.sql,v $
|| Revision 1.2  2006/03/22 14:07:30  shmyg
|| New release
||
|| Revision 1.1  2006/03/16 12:17:21  shmyg
|| First release
||
*/

CREATE	MATERIALIZED VIEW &owner..calls_aggregate
BUILD	DEFERRED
REFRESH	FAST ON DEMAND
ENABLE	QUERY REWRITE
AS
SELECT	DBMS_MVIEW.PMARKER( &owner..msc_data.rowid ),
	call_type_id,
	customer_type_id,
	TRUNC( call_date ) AS call_date,
	is_deleted,
	msc_no,
	trunk_in,
	trunk_out,
	COUNT(*) AS calls_amt,
	SUM( duration ) AS calls_duration,
	SUM( volume_down ) AS total_volume
FROM	&owner..msc_data
GROUP	BY DBMS_MVIEW.PMARKER( &owner..msc_data.rowid ),
	call_type_id,
	customer_type_id,
	TRUNC( call_date ),
	is_deleted,
	msc_no,
	trunk_in,
	trunk_out
/ 

-- This MView contains usage statistics for MOC and SMS MOC
-- for the period of time configured in FRAUD_CONFIG table
CREATE	MATERIALIZED VIEW &owner..usage_stat
REFRESH COMPLETE ON DEMAND
ENABLE	QUERY REWRITE
AS
SELECT	imsi,
	dn_num,
	call_type_id,
	&owner..data_util.zone_name( &owner..msc_data.b_number ) AS zone_name,
	COUNT(*) AS calls_number,
	SUM( duration ) AS total_duration,
	SUB( volume_down ) AS total_volume
FROM	&owner..msc_data
WHERE	call_type_id IN (1, 31 )
AND	call_date >=
	(
	SELECT	TRUNC( sysdate, 'hh' ) - timeframe
	FROM	&owner..fraud_config
	)
GROUP	BY imsi,
	dn_num,
	call_type_id,
	&owner..data_util.zone_name( &owner..msc_data.b_number )
/

