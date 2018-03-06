/*
Fraud report
Makes 2 reports: high usage report and overlapping calls report
$Id: fraud_report.sql,v 1.2 2006/03/16 12:17:21 shmyg Exp $ 
*/

SET TERMOUT OFF
SET TRIMSPOOL ON
SET ECHO OFF
SET TAB OFF
SET LINESIZE 32767
SET FEEDBACK OFF

ALTER SESSION SET NLS_DATE_FORMAT='DD.MM.YYYY hh24:mi:ss';
ALTER SESSION SET NLS_NUMERIC_CHARACTERS=',.';

-- Declaring thresholds
-- Period of time to look back for
VAR v_hours NUMBER;
-- Maximum number of calls allowed;
VAR v_max_calls_qty NUMBER;
-- Maximum total duration of calls allowed
VAR v_max_duration NUMBER;
-- UMC IMSI prefix
VAR v_imsi_prefix VARCHAR2(3);
-- Call_type_id for outgoing calls in MSC_DATA
VAR v_out_call_type NUMBER;

BEGIN
	:v_hours := 32;
	:v_max_calls_qty := 3;
	:v_max_duration := 15;
	:v_imsi_prefix := '255';
	:v_out_call_type := 1;
END;
/


-- Declaring emergency, FF and other numbers wich should not be
-- included in the calculations
DEFINE v_umc_prefix = 8050
DEFINE v_ukr_prefix = 80
DEFINE v_ff_prefix = 77
DEFINE v_cug_prefix = 97
DEFINE v_vpn_prefix = 15
DEFINE v_cc_number = 111
DEFINE v_wap_number = 950
DEFINE v_www_number = 955
DEFINE v_cc1_number = 177
DEFINE v_cc2_number = 188

SPOOL fraud.txt

-- Showing current time
SELECT	TO_CHAR( SYSDATE, 'DD.MM.YYYY HH24:MI:SS') AS "Report time"
FROM	DUAL
/

PROMPT
PROMPT High usage report

-- Formatting report
COLUMN dn_num NEW_VALUE dn_num_var NOPRINT
BREAK ON dn_num SKIP PAGE
TTITLE LEFT dn_num_var SKIP 1


SELECT	'Phone number:	' || cc.dn_num || '
IMSI:		' || cc.imsi || '
Total duration:	' || 	
	LTRIM( TO_CHAR( TRUNC( total_duration / 3600 ), '00' ) ) || ':' ||
	LTRIM( TO_CHAR( TRUNC( total_duration / 60 ) - TRUNC ( total_duration / 3600 ) * 60, '00' ) ) || ':' ||
		LTRIM( TO_CHAR( MOD( total_duration, 60 ), '00' ) ) AS dn_num,
	zone_priority( cc.b_number )  AS "Destination",
	cc.b_number AS "Called number",
	cc.call_date AS "Call date",
	LPAD( LTRIM( TO_CHAR( TRUNC( cc.duration / 60 ), '00' ) ) || ':' ||
		LTRIM( TO_CHAR( MOD( cc.duration, 60 ), '00' ) ), 8 ) AS "Duration"
FROM	&owner..msc_data	cc,
	(
	-- Here we need to select customers who match our criteria
	SELECT	imsi,
		SUM( duration ) AS total_duration
	FROM	&owner..msc_data	
	WHERE	call_date >= SYSDATE - :v_hours / 24
	AND	call_type_id = :v_out_call_type
	AND	&owner..zone_priority( b_number ) IN ( 0, 1 )
	AND	imsi LIKE :v_imsi_prefix || '%'
	GROUP	BY imsi
	HAVING	(
		COUNT(*) > :v_max_calls_qty
		AND
		ROUND( SUM( duration ) / 60, 2 ) > :v_max_duration
		)
	)	fr
WHERE	fr.imsi = cc.imsi
AND	cc.call_type_id = :v_out_call_type
AND	cc.call_date >= SYSDATE - :v_hours / 24
ORDER	BY total_duration DESC
/

SPOOL OFF
