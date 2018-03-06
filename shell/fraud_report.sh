#!/bin/bash

# Script for fraud report creation. Looks for suspicious customers
# by means of fraud_report.sql and sends data by e-mail
# Loads calls by means of sql*loader
# $Id: fraud_report.sh,v 1.14 2004/04/14 09:27:11 shmyg Exp $

. ${HOME}/.bash_profile

MAIL_LIST=$WORK_DIR/mail_list.txt

# Configuration
SPLITSIZE=5000000
from=shmyg@caesar.umc.ua
subj="Fraud report"

# Checking mail list
if [ ! -f $MAIL_LIST ]; then
 echo "Mail list $MAIL_LIST doesn't exist or not readable"
 exit
fi

# Checking that DB access vars set
if [ -z "$DB_USER" -o -z "$DB_NAME" -o -z "$DB_PASS" ] ; then
    echo "Cannot access database - DB_USER/DB_NAME/DB_PATH not set"
    exit
fi

# Check working environment
if [ -z "$LOG_DIR" -o -z "$WORK_DIR" ] ; then
    echo "LOG_DIR or WORK_DIR is not set"
    exit
fi

# Checking if there is previous process
if [ -f $LOG_DIR/load_calls.log -o  -f $LOG_DIR/fraud_report.log ]; then
 echo "There is previous process"
 exit
else
 touch $LOG_DIR/fraud_report.log
fi

# Launching fraud report
cd $LOG_DIR
echo $DB_PASS | sqlplus -s $DB_USER@$DB_NAME @$WORK_DIR/fraud/sql/fraud_report.sql

# Mailing results
if [ -s $LOG_DIR/fraud.txt ]; then
 cat $MAIL_LIST | while read USER; do
 metasend -b -F "$from" -t "$USER"  -s "$subj" -e base64 -S $SPLITSIZE \
 -m "text/plain" -f $LOG_DIR/fraud.txt;
 done
fi

# Cleaning up
rm -f $LOG_DIR/fraud_report.log
