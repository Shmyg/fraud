-- This script should be executed under schema's owner
VAR v_job_num NUMBER
exec DBMS_JOB.SUBMIT( :v_job_num, 'begin data_util.add_partition; end;', TRUNC( SYSDATE ) + 1 + 1/24, 'TRUNC( SYSDATE ) + 1 + 1/24' );
exec DBMS_JOB.SUBMIT( :v_job_num, 'begin DBMS_STATS.GATHER_SCHEMA_STATS( ''RASH''); end;', TRUNC( SYSDATE ) + 1 + 1/6, 'TRUNC(SYSDATE) + 1 + 1/6');
exec DBMS_JOB.SUBMIT( :v_job_num, 'begin DBMS_MVIEW.REFRESH(''CALLS_AGGREGATE''); end;', TRUNC( SYSDATE ) + 1 + 1/4, 'TRUNC( SYSDATE ) + 1 + 1/4' );
COMMIT;
