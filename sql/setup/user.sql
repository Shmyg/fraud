ACCEPT owner DEFAULT guard prompt "Enter new user name <guard>: "
ACCEPT deftsp prompt "Enter Default tablespace name: "
ACCEPT tmptsp prompt "Enter Temp tablespace name: "
ACCEPT indtsp prompt "Enter Index tablespace name: "

CREATE USER &owner.
IDENTIFIED BY &owner.
DEFAULT TABLESPACE &deftsp
TEMPORARY TABLESPACE &tmptsp
QUOTA UNLIMITED ON &deftsp;

GRANT CREATE SESSION TO &owner.
/
GRANT CREATE TABLE TO &owner.
/
GRANT CREATE PROCEDURE TO &owner.
/
GRANT CREATE MATERIALIZED VIEW TO &owner.
/
GRANT CREATE DIMENSION TO &owner.
/
GRANT CREATE DATABASE LINK TO &owner.
/

GRANT EXECUTE ON utl_smtp TO &owner.
/
GRANT EXECUTE ON dbms_job TO &owner.
/
GRANT EXECUTE ON dbms_stats TO &owner.
/

