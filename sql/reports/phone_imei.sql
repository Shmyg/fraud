SET TERMOUT OFF
SET TRIMSPOOL ON
SET ECHO OFF
SET TAB OFF
SET PAGESIZE 0
SET LINESIZE 32767
SET FEEDBACK OFF

ALTER SESSION SET NLS_DATE_FORMAT='DD.MM.YYYY';
ALTER SESSION SET NLS_NUMERIC_CHARACTERS=',.';

DEFINE owner=shmyg

SPOOL phones.txt

SELECT	DISTINCT ph.phone_num || '	' ||
	ph.imei || '	' ||
	ph.phone_name || '	' ||
	cc.imei || '	' ||
	pm.company || '	' ||
	pm.model
FROM	&owner..phones		ph,
	&owner..customer_calls	cc,
	&owner..phone_tacs	pm
WHERE	cc.dn_num = ph.phone_num
AND	SUBSTR( cc.imei, 1, 6 ) = pm.tac(+)
/

SPOOL OFF
