# This file will be sourced by the shell bash.
#
# Filename: 10-remove-obsolete-scripts.bash
#
# Copyright (C) 2016-2020 Hartmut Buhrmester
#                         <wsusoffline-scripts-xxyh@hartmut-buhrmester.de>
#
# License
#
#     This file is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published
#     by the Free Software Foundation, either version 3 of the License,
#     or (at your option) any later version.
#
#     This file is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     General Public License for more details.
#
#     You should have received a copy of the GNU General
#     Public License along with this program.  If not, see
#     <http://www.gnu.org/licenses/>.
#
# Description
#
#     During the development of the new Linux scripts, tasks and
#     libraries sometimes need to be replaced or renumbered. Then
#     the first task would be to delete obsolete files of previous
#     versions. Therefore, this new task is inserted as the first file
#     in the directory common-tasks.

# ========== Functions ====================================================

# WSUS Offline Update 11.9.1-ESR was the first release of a new ESR
# version for Windows 7 and Server Server 2008 (R2). It included the
# Linux download scripts version 1.19. So we need to remove some files
# from that version, but don't go back any further.
#
# In an ESR version, all self-updates should be disabled:
#
# - The self-update of WSUS Offline Update should be disabled, because
#   the next major version 12.0 does not support Windows 7 anymore.
#
# - Self-updates of the Linux scripts should be disabled as well,
#   because their next version won't support Windows 7 either.
#
# - The automatic update of configuration files should be disabled,
#   because these files always refer to the latest version of WSUS
#   Offline Update. Also, the configuration files for Windows 7 won't
#   get any updates this way; they are removed instead. If there are
#   new updates for Windows 7, then this would require a complete new
#   release of the WSUS Offline Update 11.9.x-ESR branch.

function remove_obsolete_scripts ()
{
    local old_name=""
    local new_name=""

    # Disable the self-update of WSUS Offline Update and the Linux
    # download scripts
    rm -f ./common-tasks/50-check-wsusoffline-version.bash
    rm -f ./available-tasks/60-check-script-version.bash

    if [[ -d ./versions ]]
    then
        rm -f ./versions/installed-version.txt
        rm -f ./versions/available-version.txt
        rmdir ./versions
    fi

    # The file 71-make-shapshot.bash was spelled wrong, but this didn't
    # get noticed for a long time. But screen fonts have a large x-height
    # and only short ascenders, and then "n" and "h" can look pretty
    # similar.
    #
    # The filename was corrected to 71-make-snapshot.bash in the Linux
    # download scripts, version 1.16.
    # - https://forums.wsusoffline.net/viewtopic.php?f=9&t=10057
    #
    # The new file finally made it into svn, but now there are two files:
    #
    # ./available-tasks/71-make-shapshot.bash
    # ./available-tasks/71-make-snapshot.bash
    #
    # So we still need to remove the old file:

    old_name="71-make-shapshot.bash"
    rm -f "./available-tasks/${old_name}"

    # The noun "licence" is valid British English, but the directory
    # was renamed to "license" for consistency with the use of American
    # English in the gpl itself (as shown at the top of this file).
    #
    # Rename the old directory, until the new one makes it into svn.

    old_name="licence"
    new_name="license"
    if [[ -d "./${old_name}" ]]
    then
        if [[ -d "./${new_name}" ]]
        then
            rm -f "./${old_name}/gpl.txt"
            rmdir "./${old_name}"
        else
            mv "./${old_name}" "./${new_name}"
        fi
    fi

    return 0
}

# ========== Commands =====================================================

remove_obsolete_scripts

return 0
