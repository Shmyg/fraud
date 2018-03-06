/*
|| Package to maintain RA schema
|| All the procedures are AUTONOMOUS_TRANSACTION as they have COMMIT inside
|| Created by Shmyg
||
|| $Log: data_util.pks,v $
|| Revision 1.3  2006/03/22 14:07:30  shmyg
|| New release
||
|| Revision 1.2  2006/03/16 12:17:21  shmyg
|| First release
||
|| Revision 1.1  2006-03-01 07:27:24  shmyg
|| Re-organized the project
||
|| Revision 1.1  2006-02-17 14:35:39  shmyg
|| *** empty log message ***
||
*/

CREATE	OR REPLACE
PACKAGE	&owner..data_util
AS

-- Adds a one-day partition to MSC_DATA table with subpartitions for
-- different call types. Adds a partition for the day after tomorrow
-- plus the number of days passed as parameter, e.g. if a partition
-- should be created for today, i_days_num must be equal to -1
-- Number of partition reflects date for which partition is created,
-- e.g. PART_22022006 contains calls for 22.02.2006
PROCEDURE       add_partition
        (
        i_days_num      IN NUMBER := 0
        );

-- Loads zones from production BSCS database into ZONES table
PROCEDURE       load_zones;

-- Returns global zone name from ZONES table
FUNCTION	zone_name
	(
	i_b_number	IN VARCHAR2
	)
RETURN	VARCHAR2
DETERMINISTIC;

-- Returns zone priority for any dialled number. In case if number
-- doesn't have corresponding zone, -1 is returned
FUNCTION	zone_priority
	(
	i_b_number IN VARCHAR2
	)
RETURN	NUMBER;

-- Collects statistics for MSC_DATA table. Statistics is collected
-- for current (the last) and penultimate partitions in order
-- to avoid collecting statistics for entire table
-- The job containing call to DBMS_STATS is created
PROCEDURE	gather_part_stats;

END	data_util;
/

SHOW ERROR

