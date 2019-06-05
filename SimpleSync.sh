#!/bin/bash
###############################################################################
#
# Perform hot backups of and to given locations.
# Add do_rsync lines as needed (see end of this script).
#
# Usage: sudo ./bak.sh
#
# Version: 1.0.1
# Author:  Frank Hartung
# Contact: https://github.com/sepulzera/SimpleSyncScript
#
# Exit codes:
#   0 - Success.
#   1 - Script called with a wrong argument or without root permission.
#   2 - Too few arguments provided to do_rsync.
#
###############################################################################

VERBOSE=0
DRY_RUN=0

RED='\033[0;31m'
NC='\033[0m' # No Color

err() {
  if [[ ${VERBOSE} == 1 ]]; then
    echo -e "${RED}[$(date +'%Y-%m-%dT%H:%M:%S%z')] [E]: $@${NC}" >&2
  else
    echo -e "${RED}[$(date +'%H:%M:%S')] [E]: $@${NC}" >&2
  fi
}

dbg() {
  if [[ ${VERBOSE} == 1 ]]; then
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [D]: $@" >&1
  else
    echo "[$(date +'%H:%M:%S')] [D]: $@" >&1
  fi
}

usage() {
  echo "Backup helper script, developed by Frank Hartung. Version 1.0.1."
  echo ""
  echo "Usage:"
  echo "  [sudo] bak.sh [OPTION...]"
  echo ""
  echo "Options:"
  echo "  -d, --dry-run       Backup will only be simulated, no data will be changed."
  echo "  -v, --verbose       Comprehensive debugging information will be printed."
  echo "  -h, --help          Show this help."
}

do_rsync() {
  if [[ $# != 3 ]]; then
    err "Too few arguments."
    exit 2
  fi

  if [ -d $1 ]; then
    if [ -d $2 ]; then
      if [[ ${DRY_RUN} == 1 ]]; then
        dbg "$1 ==> $2$3 (DRY_RUN)"
        if [[ ${VERBOSE} == 1 ]]; then
          pkexec rsync -r -n -t -p -o -g -v --progress --delete -u -s $1 $2$3
        else
          pkexec rsync -r -n -t -p -o -g -q --delete -u -s $1 $2$3
        fi
      else
        dbg "$1 ==> $2$3"
        if [[ ${VERBOSE} == 1 ]]; then
          pkexec rsync -r -t -p -o -g -v --progress --delete -u -s $1 $2$3
        else
          pkexec rsync -r -t -p -o -g -q --delete -u -s $1 $2$3
        fi
      fi
    else
      dbg "$1 ==> $2$3 : SKIPPED (Root not found)"
    fi
  else
    err "$1 does not exist!"
  fi
}

##### Main

while [ "$1" != "" ]; do
  case $1 in
      -d | --dry-run )       DRY_RUN=1
                             ;;
      -v | --verbose )       VERBOSE=1
                             ;;
      -h | --help )          usage
                             exit
                             ;;
      * )                    usage
                             exit 1
  esac
  shift
done

if [[ $EUID > 0 ]]; then
  err "Root permission required to run this script."
  exit 1
fi


##### Change this part

#    $1    FROM directory. Data will be copied from. No data will be copied if this directory does not exist.
#    $2    TO root directory. No Action will be performed if it does not exist.
#    $3    TO sub directory. Data will be copied to root+sub. The directory will be created if it does not exist.

#        $1                              $2                                 $3
# Copy my local stuff to my second internal drive (mounted at '/opt/backup') for quick backups
do_rsync "/home/sepulzera/Documents/"    "/opt/backup"                      "sepulzera/Documents/"
do_rsync "/home/sepulzera/Pictures/"     "/opt/backup"                      "sepulzera/Pictures/"

# Copy all backup'ed stuff from my second internal drive to my external drive
do_rsync "/opt/backup/"                  "/media/sepulzera/BackupDrive1"    "/backup/"
# Copy all backup'ed stuff from my second internal drive to my second external drive
do_rsync "/opt/backup/"                  "/media/sepulzera/BackupDrive2"    "/backup/"



sync
exit 0
