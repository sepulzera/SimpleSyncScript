# SimpleSyncScript
Convenient rsyncing for backups with Linux.

This script wraps rsync to make backups easier.

This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software. See LICENSE for full license text including copyright information.

## Setup

Get a copy of this script and save it.
Change the ```do_rsync``` calls at the end of the script.
Be aware that no validation is implemented. If you screw up, don't blame the tool.

Arguments:
```do_rsync $1 $2 $3```
* $1 : FROM directory. Data will be copied from. No data will be copied if this directory does not exist.
* $2 : TO root directory. No Action will be performed if it does not exist.
* $3 : TO sub directory. Data will be copied to root+sub. The directory will be created if it does not exist.

Example:
```stylus
#        $1                              $2                                 $3
# Copy my local stuff to my second internal drive (mounted at '/opt/backup') for quick backups
do_rsync "/home/sepulzera/Documents/"    "/opt/backup"                      "/sepulzera/Documents/"
do_rsync "/home/sepulzera/Pictures/"     "/opt/backup"                      "/sepulzera/Pictures/"

# Copy all backup'ed stuff from my second internal drive to my external drive
do_rsync "/opt/backup/"                  "/media/sepulzera/BackupDrive1"    "/backup/"
# Copy all backup'ed stuff from my second internal drive to my second external drive
do_rsync "/opt/backup/"                  "/media/sepulzera/BackupDrive2"    "/backup/"
```

## Usage

sudo ./SimpleSync.sh [OPTION...]

Options:
```stylus
-d, --dry-run     Backup will only be simulated, no data will be changed.
-v, --verbose     Comprehensive debugging information will be printed.
-h, --help        Displays the help.
```

## Limits

At its core, this script only implements copying data from and to locally connected drives. Anything else will probably fail, like:
* Copying data over ssh. (The script would need be to extended to provide this functionality.)
* Copying data from or to NAS. (May work if mounted into the FS, but untested.)

Copying data from or to encrypted drives works, as long as that the drive is mounted and unlocked.

## Diving deeper into rsync

This script uses the following call to rsync to provide the proper backup-mechanism for my use-case. Feel free to make changes in your copy as needed. Please refer to the manpage of rsync for more information.

```
pkexec rsync [-n] -r -t -p -o -g [-q] [-v] --delete -u -s

pkexec      Executes the command as another user. Used to not modify some file flags, like creator.
-n          Dry-run.
-r          Recursive into directories.
-t          Preserve modification times.
-p          Preserve permissions.
-o          Preserve owner (super-user required).
-g          Preserve group.
-q          Suppress non-error messages.
--delete    Delete extraneous files from dest dirs.
-u          Skip any files which exist on the destination and have a modified time that is newer than the source file.
-s          No space-splitting; wildcard chars only (some safety for the provided arguments).
```
