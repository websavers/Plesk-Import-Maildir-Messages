#!/bin/bash
# plesk_import_mail.sh v2.0. Last edited March 9, 2017
#
# Usage: plesk_import_mail.sh <domain> <mailname> <mailname_src_dir>
# Example: plesk_import_mail.sh websavers.ca jordan /home/websavers/mailaccounts/jordan
# Check to make sure the mailname_src_dir provided contains the inbox mails and mail folders!
#

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -eq 3 ] || die "3 arguments required, $# provided"

DOMAIN=$1
MAILNAME=$2
SRC_DIR=$3

DST_DIR=/var/qmail/mailnames/$DOMAIN/$MAILNAME/Maildir

if [ -d "$DST_DIR" ] && [ -d "$SRC_DIR" ]; then
  rsync -avt --progress $SRC_DIR/ $DST_DIR/ --exclude ".Trash" --exclude "courierimap*" --exclude "dovecot*"
else
  echo "Error: directory does not exist. Src: $SRC_DIR | Dest: $DST_DIR"
fi