#!/usr/bin/env bash
#
# Filename: copy-to-target.bash
#
# Copyright (C) 2018-2020 Hartmut Buhrmester
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
#
# Usage
#
# ./copy-to-target.bash <update> <destination-directory> [<option> ...]
#
# This script uses rsync to copy the updates from the ../client directory
# to a destination directory, which must be specified on the command
# line. rsync copies all files by default. A filter file is used, to
# exclude certain directories and files from being copied.
#
# The Linux script copy-to-target.bash uses the existing files
# wsusoffline/exclude/ExcludeListUSB-*.txt to create the initial filter
# file, just like the Windows script CopyToTarget.cmd. This way, the files
# ExcludeListUSB-*.txt define the available options for the <update>
# parameter of the script copy-to-target.bash.
#
# The supported updates for WSUS Offline Update 12.0 and later are:
#
#   all           All Windows and Office updates, 32-bit and 64-bit
#   all-x86       All Windows and Office updates, 32-bit
#   all-win-x64   All Windows updates, 64-bit
#   all-ofc       All Office updates, 32-bit and 64-bit
#   w62-x64       Server 2012, 64-bit
#   w63           Windows 8.1, 32-bit
#   w63-x64       Windows 8.1 / Server 2012 R2, 64-bit
#   w100          Windows 10, 32-bit
#   w100-x64      Windows 10 / Server 2016/2019, 64-bit
#
# The corresponding files wsusoffline/exclude/ExcludeListUSB-*.txt are:
#
#   all           ExcludeListUSB-all.txt
#   all-x86       ExcludeListUSB-all-x86.txt
#   all-win-x64   ExcludeListUSB-all-x64.txt
#   all-ofc       ExcludeListUSB-ofc.txt
#   w62-x64       ExcludeListUSB-w62-x64.txt
#   w63           ExcludeListUSB-w63-x86.txt
#   w63-x64       ExcludeListUSB-w63-x64.txt
#   w100          ExcludeListUSB-w100-x86.txt
#   w100-x64      ExcludeListUSB-w100-x64.txt
#
# The files wsusoffline/exclude/ExcludeListUSB-*.txt are used with
# xcopy.exe on Windows. They had to be edited to work with rsync on
# Linux. Therefore, the Linux script copy-to-target.bash now uses an
# own set of these files in the directory wsusoffline/sh/exclude.
#
# The differences are:
#
# Windows:
# - Back-slashes are separators in pathnames.
# - Filters are case insensitive.
# - xcopy doesn't use shell patterns. This seems to cause some
#   ambiguities: The file wsusoffline/client/bin/IfAdmin.cpp is excluded,
#   if .NET Frameworks are excluded. This is due to the interpretation
#   of the file ExcludeListISO-dotnet.txt by xcopy.exe. The line "cpp\"
#   matches both the directory "cpp" (as expected) and the source file
#   IfAdmin.cpp.
#
# Linux:
# - Forward slashes are separators in pathnames.
# - Filters are case sensitive: both ndp46 and NDP46, ndp472 and NDP472
#   are needed.
# - rsync supports shell patterns like "*", which are added as
#   needed. For example, service packs are excluded with the file
#   wsusoffline/exclude/ExcludeList-SPs.txt. This file contains
#   kb numbers and other unique identifiers, but not the complete
#   filenames. Therefore, the filters had to be enclosed in asterisks like
#   "*KB914961*".
# - File paths are constructed differently with rsync than with mkisofs
#   or xcopy.exe. To exclude the directory client/cpp, the filter should
#   be written as "/cpp", like an absolute path with the source directory
#   as the root of the filesystem.
#
#
# Compared to the Windows script CopyToTarget.cmd, some options
# were renamed to match those of the Linux download script
# download-updates.bash:
#
# - The option "all-x64" was renamed to "all-win-x64", because it only
#   includes Windows updates, but no Office updates.
# - The option "ofc" was renamed to "all-ofc".
#
#
# Finally, some of the private exclude lists were renamed to better
# match the command line parameters of the script copy-to-target.bash:
#
#   ExcludeListUSB-all-x64.txt   -->  ExcludeListUSB-all-win-x64.txt
#   ExcludeListUSB-ofc.txt       -->  ExcludeListUSB-all-ofc.txt
#   ExcludeListUSB-w60-x86.txt   -->  ExcludeListUSB-w60.txt
#   ExcludeListUSB-w61-x86.txt   -->  ExcludeListUSB-w61.txt
#   ExcludeListUSB-w63-x86.txt   -->  ExcludeListUSB-w63.txt
#   ExcludeListUSB-w100-x86.txt  -->  ExcludeListUSB-w100.txt
#
#
# The Linux script copy-to-target.bash handles some options differently
# than the Windows script CopyToTarget.cmd:
#
# - /includedotnet is replaced with -includecpp -includedotnet.
#
#   The option /includedotnet of the Windows script includes both .NET
#   Frameworks and Visual C++ Runtime Libraries. These downloads don't
#   necessarily depend on each other, and previous versions of WSUS
#   Offline Update handled them separately.
#
#
# The Linux script copy-to-target.bash doesn't support the mode "per
# language". This was most useful for Windows XP and Server 2003, because
# they used localized Windows updates. All Windows versions since Vista
# use global/multilingual updates, and all Office updates are always
# lumped together, with most updates in the directory client/ofc/glb. Then
# the distinction by language is not needed anymore.
#
#
# This script uses associative arrays to simplify the handling of
# included downloads. This requires at least bash 4.0. It was successfully
# tested with:
#
# - Bash version 4.1.5 on Debian 6.0.10 Squeeze
# - Bash version 4.3.30 on Debian 8.11 Jessie
# - Bash version 4.4.12 on Debian 9.5 Stretch

# ========== Shell options ================================================

set -o errexit
set -o nounset
set -o pipefail
shopt -s nocasematch

# ========== Global variables =============================================

source_directory="../client/"
destination_directory=""
link_directory="(unused)"
update=""
selected_excludelist=""
logfile="../log/copy-to-target.log"

declare -A option=(
    ["cpp"]="disabled"
    ["dotnet"]="disabled"
    ["wddefs"]="disabled"
)
filter_file=""

# rsync supports different methods to handle symbolic links. For backup
# purposes, the combination "--links --safe-links" works best, because
# it simply copies symbolic links unchanged. To create a working copy of
# the client directory, is seems to be more useful, to resolve symbolic
# links and copy the original files and folders instead ("--copy-links").
#
# Note: Long options are available in GNU/Linux and in FreeBSD.
rsync_parameters=( --recursive --copy-links --owner --group --perms
                   --times --verbose --stats --human-readable )

# ========== Functions ====================================================

function show_usage ()
{
    log_info_message "Usage:
./copy-to-target.bash <update> <destination-directory> [<option> ...]

The update can be one of:
    all           All Windows and Office updates, 32-bit and 64-bit
    all-x86       All Windows and Office updates, 32-bit
    all-win-x64   All Windows updates, 64-bit
    all-ofc       All Office updates, 32-bit and 64-bit
    w62-x64       Server 2012, 64-bit
    w63           Windows 8.1, 32-bit
    w63-x64       Windows 8.1 / Server 2012 R2, 64-bit
    w100          Windows 10, 32-bit
    w100-x64      Windows 10 / Server 2016/2019, 64-bit

The destination directory is the directory, to which files are copied
or hard-linked. It should be specified without a trailing slash, because
otherwise rsync may create an additional directory within the destination
directory.

The options are:
    -includecpp        Include Visual C++ Runtime Libraries
    -includedotnet     Include .NET Frameworks
    -includewddefs     Include Windows Defender definition updates for
                       the built-in Defender of Windows 8, 8.1 and 10
    -cleanup           Tell rsync to delete obsolete files from included
                       directories. This does not delete excluded files
                       or directories.
    -delete-excluded   Tell rsync to delete obsolete files from included
                       directories and also all excluded files and
                       directories. Use this option with caution,
                       e.g. try it with the option -dryrun first.
    -hardlink <dir>    Create hard links instead of copying files. The
                       link directory should be specified with an
                       absolute path, otherwise it will be relative to
                       the destination directory. The link directory
                       and the destination directory must be on the same
                       file system.
    -dryrun            Run rsync without copying or deleting
                       anything. This is useful for testing.
"
    return 0
}


function check_requirements ()
{
    if ! type -P rsync >/dev/null
    then
        printf '%s\n' "Please install the package rsync"
        exit 1
    fi

    return 0
}


function setup_working_directory ()
{
    local kernel_name=""
    local canonical_name=""
    local home_directory=""

    if type -P uname >/dev/null
    then
        kernel_name="$(uname -s)"
    else
        printf '%s\n' "Unknown operation system"
        exit 1
    fi

    case "${kernel_name}" in
        Linux | FreeBSD)
            canonical_name="$(readlink -f "$0")"
        ;;
        Darwin | NetBSD | OpenBSD)
            # Use greadlink = GNU readlink, if available; otherwise use
            # BSD readlink, which lacks the option -f
            if type -P greadlink >/dev/null
            then
                canonical_name="$(greadlink -f "$0")"
            else
                canonical_name="$(readlink "$0")"
            fi
        ;;
        *)
            printf '%s\n' "Unknown operating system ${kernel_name}"
            exit 1
        ;;
    esac

    # Change to the home directory of the script
    home_directory="$(dirname "${canonical_name}")"
    cd "${home_directory}" || exit 1

    return 0
}


function import_libraries ()
{
    source ./libraries/dos-files.bash
    source ./libraries/messages.bash

    return 0
}


function parse_command_line ()
{
    local next_parameter=""
    local option_name=""

    log_info_message "Starting script copy-to-target.bash ..."
    log_info_message "Command line: ${0} $*"

    if (( $# < 2 ))
    then
        log_error_message "At least two parameters are required."
        show_usage
        exit 1
    else
        log_info_message "Parsing command line..."

        # Parse first parameter
        update="${1}"
        case "${update}" in
            # These are the supported updates in WSUS Offline Update
            # 12.0 and later.
            all | all-x86 | all-win-x64 | all-ofc | \
            w62-x64 | w63 | w63-x64 | w100 | w100-x64)
                # Note, that the script uses its own copies of the
                # exclude lists, because the filters had to be edited
                # to be compatible with rsync.
                #
                # These files are also renamed to match the command
                # line parameters.
                if [[ -f "./exclude/ExcludeListUSB-${update}.txt" ]]
                then
                    log_info_message "Found update ${update}"
                    selected_excludelist="ExcludeListUSB-${update}.txt"
                else
                    log_error_message "The update ${update} is not supported in this version of WSUS Offline Update."
                    exit 1
                fi
            ;;
            *)
                log_error_message "Update ${update} is not recognized"
                show_usage
                exit 1
            ;;
        esac

        # Parse second parameter
        destination_directory="${2}"

        # Parse remaining parameters
        shift 2
        while (( $# > 0 ))
        do
            next_parameter="${1}"
            case "${next_parameter}" in
                -includecpp | -includedotnet | -includewddefs)
                    if [[ "${update}" == "all-ofc" ]]
                    then
                        log_warning_message "Option ${next_parameter} is ignored for update all-ofc"
                    else
                        log_info_message "Found option ${next_parameter}"
                        # Strip the prefix "-include"
                        option_name="${next_parameter/#-include/}"
                        option["${option_name}"]="enabled"
                    fi
                ;;
                -cleanup)
                    log_info_message "Found option -cleanup"
                    # The rsync option --delete removes obsolete files
                    # from the included directories. It does not remove
                    # excluded files or directories. If this is needed,
                    # then the option --delete-excluded must also be used.
                    rsync_parameters+=( --delete )
                ;;
                -delete-excluded)
                    log_info_message "Found option -delete-excluded"
                    # Delete all excluded files and folder. This should
                    # be used with caution: If, for example, the update
                    # is "w60", then all other Windows versions will
                    # be deleted.
                    #
                    # This option may be needed to solve one particular
                    # problem: Files, which are excluded in rsync, are
                    # neither copied nor deleted; they are just ignored.
                    #
                    # rsync needs both options --delete and
                    # --delete-excluded, to actually delete excluded
                    # files. The results should be tested with the dryrun
                    # option first.
                    rsync_parameters+=( --delete --delete-excluded )
                ;;
                -hardlink)
                    log_info_message "Found option -hardlink"
                    # The link directory should be specified with an
                    # absolute path. If the link directory is a relative
                    # path, it will be relative to the destination
                    # directory.
                    shift 1
                    if (( $# > 0 ))
                    then
                        link_directory="${1}"
                    else
                        log_error_message "The link directory was not specified"
                        exit 1
                    fi
                    rsync_parameters+=( "--link-dest=${link_directory}" )
                ;;
                -dryrun)
                    log_info_message "Found option -dryrun"
                    rsync_parameters+=( --dry-run )
                ;;
                *)
                    log_error_message "Parameter ${next_parameter} is not recognized"
                    show_usage
                    exit 1
                ;;
            esac
            shift 1
        done
    fi
    echo ""
    return 0
}


function print_summary ()
{
    log_info_message "Summary after parsing command-line"
    log_info_message "- Destination directory: ${destination_directory}"
    log_info_message "- Link directory: ${link_directory}"
    log_info_message "- Update: ${update}"
    log_info_message "- Selected exclude list: ${selected_excludelist}"
    log_info_message "- Options: $(declare -p option)"

    echo ""
    return 0
}


function create_filter_file ()
{
    local line=""
    local option_name=""

    log_info_message "Creating filter file for rsync..."
    if type -P mktemp >/dev/null
    then
        filter_file="$(mktemp "/tmp/copy-to-target.XXXXXX")"
    else
        filter_file="/tmp/copy-to-target.temp"
        touch "${filter_file}"
    fi

    # Copy the selected file ./exclude/ExcludeListUSB-*.txt
    log_info_message "Copying ${selected_excludelist} ..."
    cat_dos "./exclude/${selected_excludelist}" >> "${filter_file}"

    # Included downloads
    for option_name in cpp dotnet wddefs
    do
        if [[ "${option[${option_name}]}" == "enabled" ]]
        then
            log_info_message "Directory ${option_name} is included"
        else
            log_info_message "Excluding directory ${option_name} ..."
            # Excluded directories are specified with the source
            # directory as the root of the path, e.g. "/cpp", "/dotnet"
            # or "/wddefs". There should be no shell pattern before or
            # after the directory name.
            printf '%s\n' "/${option_name}" >> "${filter_file}"
        fi
    done

    # Add filter to the command-line options
    rsync_parameters+=( "--exclude-from=${filter_file}" )

    echo ""
    return 0
}


function call_rsync ()
{
    log_info_message "Calling rsync..."
    mkdir -p "${destination_directory}"
    rsync "${rsync_parameters[@]}" "${source_directory}" "${destination_directory}"

    # TODO: enable log file for rsync?
    return 0
}


function remove_filter_file ()
{
    rm -f "${filter_file}"
}


# The main function is called after the script name.
function copy_to_target ()
{
    check_requirements
    setup_working_directory
    import_libraries
    parse_command_line "$@"
    print_summary
    create_filter_file
    call_rsync
    remove_filter_file

    return 0
}

# ========== Commands =====================================================

copy_to_target "$@"
exit 0
