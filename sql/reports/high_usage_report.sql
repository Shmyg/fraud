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

