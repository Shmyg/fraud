/*
|| Script for RA schema creation
|| Created by Shmyg
|| $Log: dbsetup.sql,v $
|| Revision 1.3  2006/03/22 14:07:30  shmyg
|| New release
||
|| Revision 1.2  2006/03/16 12:17:21  shmyg
|| First release
||
*/

SET VERIFY ON
SET ECHO ON
SET TIME ON
SET FEEDBACK ON
SET HEADING ON
SET LINESIZE 400
SET PAGESIZE 400
SET TRIMSPOOL ON

SPOOL &owner..log

@tables
@packages
@mviews
@jobs

exec &owner..data_util.add_partition(-1);
exec &owner..data_util.add_partition;

SPOOL OFF
SET ECHO OFF
SET TIME OFF
