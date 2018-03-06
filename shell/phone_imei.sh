#!/bin/bash

# Script for fraud report creation. Looks for suspicious customers
# by means of fraud_report.sql and sends data by e-mail
# Loads calls by means of sql*loader
# $Author: shmyg $
# $Date: 2004/05/25 11:24:58 $

. ${HOME}/.bash_profile
export WORK_DIR=/home/shmyg/Work

# Configuration
SPLITSIZE=5000000
from=shmyg@caesar.umc.ua
to=shmyg@umc.com.ua
subj="IMEIs"

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

# Launching sql script
cd $LOG_DIR
echo $DB_PASS | sqlplus -s $DB_USER@$DB_NAME @$WORK_DIR/fraud/sql/phone_imei.sql

# Mailing results
if [ -s $LOG_DIR/phones.txt ]; then
 zip -jr $LOG_DIR/phones.zip $LOG_DIR/phones.txt
 metasend -b \
 -F "$from" \
 -t "$to" \
 -s "$subj" \
 -e base64 \
 -S $SPLITSIZE \
 -m "application/zip; name=\"phones.zip\"" \
 -f $LOG_DIR/phones.zip;
fi

# Cleaning up
rm -f $LOG_DIR/phones.txt
rm -f $LOG_DIR/phones.zip
