#!/usr/local/bin/bash

#***********************************************************************#
# NAME
#       
#  load_calls.sh
#
# SYNOPSIS
#       
#  load_calls.sh
#
# DESCRIPTION
#
#  Loads EDR  from recdump files into Revenue Assurance system by means of
#  SQL*Loader. First the check is performed to verify if there is no
#  process which is loading files. It is done by looking for load_calls.log
#  file in the $LOG_DIR directory. If there is no such file, the script
#  creates this file and continue. All the files from $CALLS_DIR directory
#  are processed one-by-one. In case if the process should be terminated,
#  'load_calls.log' should be removed.
# 
# AUTHOR
#       
#  Shmyg
#
# HISTORY OF CHANGES
#
#  $Log: load_calls.sh,v $
#  Revision 1.28  2006/03/20 08:41:44  shmyg
#  Added some fields to MSC_DATA table
#
#  Revision 1.27  2006-03-16 12:17:21  shmyg
#  First release
#
#  Revision 1.26  2006-03-01 07:27:24  shmyg
#  Re-organized the project
#
#
#***********************************************************************#

trap "rm $LOG_DIR/load_calls.log; exit 1" 0 1 2 15

. "${HOME}"/.bash_profile

# Startup checks

: ${LOG_DIR:?} ${WORK_DIR:?} ${CALLS_DIR:?} ${ARCHIVE_DIR:?}
: ${DB_USER:?} ${DB_NAME:?} ${DB_PASS:?}

if [ ! -d "${CALLS_DIR}" ] ; then
    echo Directory "${CALLS_DIR}" does not exist or not a directory
    exit 1
fi

if [ ! -d "${LOG_DIR}" ] ; then
    echo Directory "${LOG_DIR}" does not exist or not a directory
    exit 1
fi

if [ ! -d "${WORK_DIR}" ] ; then
    echo Directory "${WORK_DIR}" does not exist or not a directory
    exit 1
fi

if [ ! -d "${ARCHIVE_DIR}" ] ; then
    echo Directory "${ARCHIVE_DIR}" does not exist or not a directory
    exit 1
fi

# Checking if there is previous process
if [ -f $LOG_DIR/load_calls.log -o  -f $LOG_DIR/fraud_report.log ]; then
 echo ERROR: There is previous process; exit 1
else
 touch $LOG_DIR/load_calls.log
fi

# Checking if there are  some files to process
FILE_QTY=`ls "${CALLS_DIR}"/*recdump* | wc -l`

cd "${CALLS_DIR}"

if [[ "${FILE_QTY}" -gt "0" ]]
then
 for EDR_FILE in `ls *recdump*`; do
# Checking if there is log file. If not - exiting.
 if ! [ -f $LOG_DIR/load_calls.log ]; then
  echo "Somebody removed log file - stopping process"
  exit
 fi
 
 # Checking if this is a GZIP archive
 is_gzpipped=`file "${EDR_FILE}" | grep gzip`
 is_gzipped=$?

  if [[ "${is_gzipped}" -eq "0" ]]
  then
   gzip -d "${EDR_FILE}"
  fi

  EDR_FILE=${EDR_FILE%%.gz}

 # Inserting information about the file into LOADED_FILES table
 # returning filename into variable to use later
 FILE_NUM=`echo '${DB_PASS} | sqlplus -s '{$DB_USER}@'${DB_NAME}' <<END
 set pagesize 0 feedback off verify off heading off echo off

 INSERT	INTO loaded_files
 	(
	file_id,
	file_name
	)
 (
 SELECT	file_id_seq.NEXTVAL,
 	'${EDR_FILE}'
 FROM	DUAL
 );

 COMMIT;

 SELECT	file_id_seq.CURRVAL
 FROM	DUAL;

 QUIT;

 END`

 # Creating a temporary file containing filename in it
 ret_code=`cat "${EDR_FILE}" | awk '{  printf "%d,%s\n", "'"$FILE_NUM"'", $0 }'  > calls.tmp`
 if [[ ret_code -ne "0" ]]
 then
  rm -f $LOG_DIR/load_calls.log
  exit 1
 fi

 # Checking if the file is not locked 'cause it could be not completely loaded
 # Invoking SQL*Loader
  echo $DB_PASS | sqlldr control=$WORK_DIR/control_files/calls.ctl \
                  data=calls.tmp \
                  log=$LOG_DIR/"${EDR_FILE}".log \
                  bad=$LOG_DIR/"${EDR_FILE}".bad \
                  discard=$LOG_DIR/"${EDR_FILE}".disc \
                  userid=$DB_USER@$DB_NAME direct=y \
                  MULTITHREADING=y
  RET_CODE=$?
  # Checking return code
  # 2 - it's warning - maybe some bad records found
  if [ "${RET_CODE}" -eq "0" -o "${RET_CODE}" -eq "2" ]; then
   # Removing calls files
   mv "${EDR_FILE}" "${ARCHIVE_DIR}"
   gzip "${ARCHIVE_DIR}"/"${EDR_FILE}"
   # Checking if there is discards file
   test -f $LOG_DIR/"${EDR_FILE}".disc && rm -f $LOG_DIR/"${EDR_FILE}".disc
  else
   echo SQLLoader returned with code "${RET_CODE}". Something might be wrong
   rm -f "${LOG_DIR}"/load_calls.log
   exit 1
  fi
 done
else
 rm -f $LOG_DIR/load_calls.log
 echo No files to process; exit 0
fi

# Cleaning up
rm -f $LOG_DIR/load_calls.log

exit 0
