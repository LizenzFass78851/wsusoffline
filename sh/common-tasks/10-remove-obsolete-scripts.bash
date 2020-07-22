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

# WSUS Offline Update, Community Editions CE-11.9.1 and CE-12.0 are new
# development branches.
#
# Both came with the Linux download scripts, version 1.19.
#
# Then we only need to remove obsolete files from previous versions,
# if they are still found in version 1.19. This mainly refers to two
# renamed files and folders: 71-make-shapshot.bash and licence. They were
# renamed in version 1.16, but the changes never made it into svn/Trak
# at wsusoffline.net.
#
# Version 1.19 of the Linux download scripts is the common predecessor
# of versions 1.19.1-ESR and 1.20.

function remove_obsolete_scripts ()
{
    local old_name=""
    #local new_name=""
    local -a file_list=()
    local current_file=""

    # Obsolete files in version 1.16
    #
    # The file 71-make-shapshot.bash was spelled wrong, but this didn't
    # get noticed for a long time. But screen fonts have a large x-height
    # and only short ascenders, and then "n" and "h" can look pretty
    # similar.
    #
    # The filename was corrected to 71-make-snapshot.bash in the Linux
    # download scripts, version 1.16.
    # - https://forums.wsusoffline.net/viewtopic.php?f=9&t=10057
    #
    # In WSUS Offline Update, version 11.9.1-ESR at wsusoffline.net,
    # there were two files:
    #
    # ./available-tasks/71-make-shapshot.bash
    # ./available-tasks/71-make-snapshot.bash
    #
    # This was finally solved in the Community Editions 11.9.1 and
    # 12.0. The old file, if still present, can be deleted:

    old_name="71-make-shapshot.bash"
    rm -f "./available-tasks/${old_name}"

    # The noun "licence" is valid British English, but the directory
    # was renamed to "license" for consistency with the use of American
    # English in the gpl itself (as shown at the top of this file).
    #
    # The old directory, if still present, can be deleted.

    old_name="licence"
    if [[ -d "./${old_name}" ]]
    then
        rm -f "./${old_name}/gpl.txt"
        rmdir "./${old_name}"
    fi

    # Obsolete files in version 1.20
    #
    # Version 1.20 of the Linux download scripts was meant for WSUS
    # Offline Update, version 12.0. This version removed support for
    # Windows Server 2008 and Windows 7 / Server 2008 R2.

    file_list+=(
        ./exclude/ExcludeListISO-w60.txt
        ./exclude/ExcludeListISO-w60-x64.txt
        ./exclude/ExcludeListISO-w61.txt
        ./exclude/ExcludeListISO-w61-x64.txt

        ./exclude/ExcludeListUSB-w60.txt
        ./exclude/ExcludeListUSB-w60-x64.txt
        ./exclude/ExcludeListUSB-w61.txt
        ./exclude/ExcludeListUSB-w61-x64.txt
    )

    # Obsolete files in version 1.21-CE
    #
    # The community edition 1.20-CE introduced an early implementation
    # of the download from GitLab, comparing ETags instead of
    # timestamping. This was more a hack and it would dump the whole
    # server response to ../cache/filename.headers.

    shopt -s nullglob
    file_list+=(
        ../cache/*.headers
    )
    shopt -u nullglob

    # The self-update of the Linux download scripts was introduced in
    # the first beta-versions, but it is considered obsolete by now.

    rm -f ./available-tasks/60-check-script-version.bash

    if [[ -d ./versions ]]
    then
        rm -f ./versions/installed-version.txt
        rm -f ./versions/available-version.txt
        rmdir ./versions
    fi

    if [[ -d ../timestamps ]]
    then
        rm -f ../timestamps/check-sh-version.txt
    fi

    # Delete all obsolete files, if existing
    if (( "${#file_list[@]}" > 0 ))
    then
        for current_file in "${file_list[@]}"
        do
            if [[ -f "${current_file}" ]]
            then
                log_debug_message "Deleting ${current_file}"
                rm "${current_file}"
            fi
        done
    fi
    return 0
}

# ========== Commands =====================================================

remove_obsolete_scripts
return 0
