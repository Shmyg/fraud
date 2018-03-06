/*
||
||
|| $Log: global_vars.pks,v $
|| Revision 1.2  2006/03/22 14:07:30  shmyg
|| New release
||
|| Revision 1.1  2006/03/16 12:17:21  shmyg
|| First release
||
|| Revision 1.1.1.1  2005-06-07 11:16:08  serge
||
||
*/

CREATE OR REPLACE
PACKAGE	&owner..global_vars
AS

	c_total_duration	CONSTANT NUMBER := 10;

END;
/

SHOW ERROR
