/*
Fraud report
Makes 2 reports: high usage report and overlapping calls report
$Id: fraud_report.sql,v 1.2 2006/03/22 14:07:30 shmyg Exp $ 
*/

SET TERMOUT OFF
SET TRIMSPOOL ON
SET ECHO OFF
SET TAB OFF
SET LINESIZE 32767
SET FEEDBACK OFF

ALTER SESSION SET NLS_DATE_FORMAT='DD.MM.YYYY hh24:mi:ss';
ALTER SESSION SET NLS_NUMERIC_CHARACTERS=',.';

-- Creating index for query
CREATE  INDEX imsi_idx
ON      outgoing_calls
        (
        imsi,
        b_number,
        call_date
        )
TABLESPACE indx
STORAGE (
        INITIAL 50M
        NEXT    10M
        PCTINCREASE 0
        )
UNRECOVERABLE
PARALLEL
/

-- Declaring thresholds
DEFINE v_max_duration = 15	-- maximum total duration of calls allowed
DEFINE v_max_calls_qty = 10	-- maximum number of calls allowed
DEFINE v_hours = 3		-- period of time to look back for

-- Declaring emergency, FF and other numbers wich should not be
-- included in the calculations
DEFINE v_imsi_prefix = 255
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


/*
Very old and bad performance. Should be changed for RANK usage for LENGTH(digits)
*/
SELECT	'Phone number:	' || cc.dn_num || '
IMSI:		' || cc.imsi || '
Total duration:	' || 	
	LTRIM( TO_CHAR( TRUNC( total_duration / 3600 ), '00' ) ) || ':' ||
	LTRIM( TO_CHAR( TRUNC( total_duration / 60 ) - TRUNC ( total_duration / 3600 ) * 60, '00' ) ) || ':' ||
		LTRIM( TO_CHAR( MOD( total_duration, 60 ), '00' ) ) AS dn_num,
	zn.des AS "Destination",
	cc.b_number AS "Called number",
	cc.call_date AS "Call date",
	LPAD( LTRIM( TO_CHAR( TRUNC( cc.duration / 60 ), '00' ) ) || ':' ||
		LTRIM( TO_CHAR( MOD( cc.duration, 60 ), '00' ) ), 8 ) AS "Duration"
FROM	outgoing_calls	cc,
	zones		zn,
	(
	-- Here we need to select customers who match our criteria
	SELECT	imsi,
		SUM( duration ) AS total_duration
	FROM	outgoing_calls
	WHERE	call_date >= SYSDATE - &v_hours / 24
	AND	guard.zone_priority( b_number ) IN ( 0, 1 )
	AND	imsi LIKE '&v_imsi_prefix' || '%'
	GROUP	BY dn_num,
		imsi
	HAVING	(
		COUNT(*) > &v_max_calls_qty
		AND
		ROUND( SUM( duration ) / 60, 2 ) > &v_max_duration
		)
	)	fr
WHERE	fr.imsi = cc.imsi
AND	zn.digits = SUBSTR( cc.b_number, 1, LENGTH( zn.digits ))
-- Here we need to find 'best match' zone, e.g. for call beginning with 12
-- if we have '1' and '12' zone, we need to select '12'
AND	LENGTH( zn.digits ) = 
	(
	SELECT	MAX( LENGTH ( digits ) )
	FROM	zones
	WHERE	digits = SUBSTR( cc.b_number, 1, LENGTH( digits ))
	)
-- Filtering out local and free of charge calls
AND	zn.priority IN ( 0, 1 )
AND	cc.call_date >= SYSDATE - &v_hours / 24
AND	b_number NOT LIKE '&v_cug_prefix' || '%'
AND	b_number NOT LIKE '&v_umc_prefix' || '%'
AND	b_number NOT LIKE '&v_vpn_prefix' || '%'
AND	b_number NOT LIKE '&v_ff_prefix' || '%'
AND	b_number != '&v_www_number'
AND	b_number != '&v_cc_number'
AND	b_number != '&v_cc1_number'
AND	b_number != '&v_wap_number'
AND	b_number != '&v_cc2_number'
AND	LENGTH( b_number ) != 7
ORDER	BY total_duration DESC
/

PROMPT
PROMPT Overlapping calls report

SELECT	'Phone number:	' || cc.dn_num || '
IMSI:		' || cc.imsi AS dn_num,
	cc.b_number AS "Called number",
	cc.call_date AS "Call date",
	LPAD( LTRIM( TO_CHAR( TRUNC( cc.duration / 60 ), '00' ) ) || ':' ||
		LTRIM( TO_CHAR( MOD( cc.duration, 60 ), '00' ) ), 8 ) AS "Duration",
	ol.call_end AS "Call end date"
FROM	(
	SELECT	imsi,
		-- Here we need to calculate call finish time
		-- in most cases this time should be equal for those calls
		call_date + ( duration / ( 60 * 60 * 24 ) ) AS call_end
	FROM	outgoing_calls
	WHERE	call_date >= SYSDATE - &v_hours / 24
	GROUP	BY imsi,
		call_date + ( duration / ( 60 * 60 * 24 ) )
	HAVING	COUNT(*) > 1
	)	ol,
	outgoing_calls	cc
WHERE	cc.imsi = ol.imsi
AND	cc.call_date + ( cc.duration / ( 60 * 60 * 24 ) ) = ol.call_end
ORDER	BY cc.imsi,
	ol.call_end,
	cc.call_date
/

SPOOL OFF

DROP	INDEX imsi_idx
/