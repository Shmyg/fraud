CREATE	OR REPLACE
PACKAGE	BODY &owner..data_util
AS

PROCEDURE	add_partition
	(
	i_days_num	IN NUMBER := 0
	)
AS

	PRAGMA	AUTONOMOUS_TRANSACTION;

	-- This is unique partition number. Reflects call_date for all calls
	-- inside the partition
	c_part_num	CONSTANT VARCHAR2(8) :=
				TO_CHAR( SYSDATE + 1 + i_days_num, 'DDMMYYYY');

	-- This is the upper bound for the partition. It is SYSDATE + 2 days as
	-- partition is created for the next day only (if the parameter is not passed)
	-- Parameter allows to create a partition for any day
	c_max_date	CONSTANT VARCHAR2(10) :=
				TO_CHAR( TRUNC( SYSDATE ) + 2 + i_days_num, 'DD.MM.YYYY' );

	-- String to store dynamic SQL
	v_exec_string	VARCHAR2(2000);

	TYPE	number_array_type
	IS	VARRAY(10)
	OF	NUMBER;

	-- Call types for different subpartitions
	call_types	number_array_type := number_array_type (1, 2, 30, 31);
	
	i		PLS_INTEGER;
BEGIN

	v_exec_string := 'ALTER TABLE MSC_DATA ADD PARTITION part_' || c_part_num  ||
		' VALUES LESS THAN ( TO_DATE( ''' ||  c_max_date || ''', ''DD.MM.YYYY'' ) ) ' ||
		' PCTFREE 0 STORAGE ( INITIAL 16M NEXT 16M ) COMPRESS (';

	-- Creating subpartitions for each of call types
	FOR	i IN call_types(1)..call_types.COUNT
	LOOP
		v_exec_string := v_exec_string ||
			' SUBPARTITION part_' || c_part_num  || '_' || i ||
			' VALUES (' || call_types(i) || '),';

	END	LOOP;

	i := call_types.COUNT + 1;

	-- Adding last partition for 'all others' values
	v_exec_string := v_exec_string ||
		' SUBPARTITION part_' || c_part_num  || '_' || i ||
		' VALUES ( DEFAULT ))';

	DBMS_OUTPUT.PUT_LINE( v_exec_string );

	EXECUTE IMMEDIATE( v_exec_string );

EXCEPTION
	WHEN    OTHERS
	THEN
		ROLLBACK;
		logger.log_error(logger.who_am_i, SQLCODE, SQLERRM );
		RAISE;
END	add_partition;

PROCEDURE	load_zones
IS
	PRAGMA	AUTONOMOUS_TRANSACTION;
BEGIN
	INSERT	INTO &owner..zones
		(
		zpcode,
		des,
		digits,
		priority
		)
	(
	SELECT	zpcode,
		des,
		-- First of all we need to strip Ukraine Int. Prefix
		-- (+380). For all others we need to strip heading '+'
		REPLACE( REPLACE( digits, '+380', '80' ), '+', '' ),
		0
	FROM	mpuzptab@prod	zp
	WHERE	zp.zpcode NOT IN
		(
		SELECT	zpcode
		FROM	&owner..zones
		)
	-- This is strange zone code. It has '*' digits like zpcode 168.
	-- So we need to filter one of them
	AND	zpcode != 521
	);
	
	COMMIT;

EXCEPTION
	WHEN    OTHERS
	THEN
		ROLLBACK;
		logger.log_error(logger.who_am_i, SQLCODE, SQLERRM );
		RAISE;
END	load_zones;

FUNCTION	zone_name
	(
	i_b_number IN VARCHAR2
	)
RETURN	VARCHAR2
DETERMINISTIC
AS

	CURSOR	zone_name_cur
	IS
	SELECT	zone_name
	FROM	&owner..zones
	WHERE	digits = SUBSTR( i_b_number, 1, LENGTH( digits ))
	ORDER	BY LENGTH( digits ) DESC;

	v_zone_name	&owner..zones.zone_name%TYPE;

BEGIN

	OPEN	zone_name_cur;

		FETCH	zone_name_cur
		INTO	v_zone_name;

	CLOSE	zone_name_cur;

	RETURN	v_zone_name;
END	zone_name;

FUNCTION	zone_priority
	(
	i_b_number IN VARCHAR2
	)
RETURN	NUMBER
AS

	CURSOR	zone_priority_cur
	IS
	SELECT	priority
	FROM	&owner..zones
	WHERE	digits = SUBSTR( i_b_number, 1, LENGTH( digits ))
	ORDER	BY LENGTH( digits ) DESC;

	v_zone_priority	&owner..zones.priority%TYPE;

BEGIN

	OPEN	zone_priority_cur;

		FETCH	zone_priority_cur
		INTO	v_zone_priority;

	CLOSE	zone_priority_cur;

	RETURN	v_zone_priority;

END	zone_priority;

PROCEDURE	gather_part_stats
IS

	PRAGMA	AUTONOMOUS_TRANSACTION;

	v_curr_part_name	VARCHAR2(13) := TO_CHAR( SYSDATE, 'DDMMYYYY' );
	v_prev_part_name	VARCHAR2(13) := TO_CHAR( SYSDATE - 1, 'DDMMYYYY' );
	v_job_num	PLS_INTEGER;

BEGIN

	v_curr_part_name := 'PART_' || v_curr_part_name;
	v_prev_part_name := 'PART_' || v_prev_part_name;

	DBMS_JOB.SUBMIT
		(
		v_job_num, 
		'DBMS_STATS.GATHER_TABLE_STATS( ''&owner'', ''MSC_DATA'', ''' || v_curr_part_name || ''');'
		);

	DBMS_JOB.SUBMIT
		(
		v_job_num, 
		'DBMS_STATS.GATHER_TABLE_STATS( ''&owner'', ''MSC_DATA'', ''' || v_prev_part_name || ''');'
		);

	
	COMMIT;

END	gather_part_stats;

END	data_util;
/

SHOW ERROR
