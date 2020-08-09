#!/usr/bin/env bash

# Filename: create-iso-image.bash
#
# Copyright (C) 2019-2020 Hartmut Buhrmester
#                    <wsusoffline-scripts-xxyh@hartmut-buhrmester.de>
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
#     This script creates one ISO image of the client directory per
#     run. The included downloads can be restricted with a series of
#     ExcludeListISO-*.txt files.
#
#     The script requires either mkisofs or genisoimage, depending on
#     the distribution:
#
#     - mkisofs is the original tool and preferred. It is part of the
#       cdrtools, which use a Solaris-style license. This seems to
#       restrict the distribution of binary packages, but not that of
#       source packages. Therefore, (only) Linux distributions like
#       Gentoo, which use source packages, may still provide mkisofs
#       and the other cdrtools.
#
#     - genisoimage and cdrkit are forks, which were created after the
#       license change for the cdrtools. They are provided by most other
#       Linux distributions like Debian and Fedora.
#
#     - https://en.wikipedia.org/wiki/Cdrtools
#     - https://en.wikipedia.org/wiki/Cdrkit
#
# Usage
#
# ./create-iso-image.bash <update> [<option> ...]
#
# The first parameter is the profile name. In WSUS Offline Update 12.0
# and later, this can be one of:
#
#   all           All Windows and Office updates, 32-bit and 64-bit
#   all-x86       All Windows and Office updates, 32-bit
#   all-win-x64   All Windows updates, 64-bit
#   all-ofc       All Office updates, 32-bit and 64-bit
#   w62-x64       Windows Server 2012, 64-bit
#   w63           Windows 8.1, 32-bit
#   w63-x64       Windows 8.1 / Server 2012 R2, 64-bit
#   w100          Windows 10, 32-bit
#   w100-x64      Windows 10 / Server 2016/2019, 64-bit
#
# The options are:
#
#   -includecpp        Include Visual C++ Runtime Libraries
#   -includedotnet     Include .NET Frameworks
#   -includewddefs     Include Windows Defender definition updates for
#                      the built-in Defender of Windows 8, 8.1 and 10
#   -output-path <dir> Output directory for the ISO image file - the
#                      default is ../iso
#   -create-hashes     Create a hashes file for the ISO image file
#
#
# The script create-iso-image.bash has basically three modes of operation:
#
# 1. The profile "all" creates one ISO image of the whole client
#    directory. It is left to the user, to restrict the resulting ISO
#    image to a reasonable size.
#
# 2. The profiles "all-x86" and "all-win-x64" create two ISO images,
#    one per architecture. These are the 'X86-cross-product' ISO images
#    of the Windows application UpdateGenerator.exe.
#
#    Originally, these ISO images were supposed to fit on DVD-5 optical
#    disks, and the file size should be restricted to 4.7 GB, but today
#    they may easily grow larger.
#
# 3. The profiles "w63", "w63-x64", etc create a series of ISO images
#    per product.
#
#    Originally, these ISO images were supposed to fit on CD-ROMs, and
#    the file size should be restricted to 700 MB. Again, the resulting
#    ISO images may easily get larger than that.
#
#    These size restrictions may explain, though, why large installers
#    are sometimes excluded from the created ISO images.
#
# The distinction "per selected language" is not used anymore. It was
# useful for localized Windows updates, e.g. for Windows XP and Windows
# Server 2003, but all supported Windows versions in the current version
# of WSUS Offline Update use global/multilingual updates.
#
# Most Office updates will be in the ofc/glb directory, and a filter
# per language will not make a big difference.
#
#
# The Linux script create-iso-images.bash uses its own filter files in
# the sh/exclude directory. These files are based of the files in the
# WSUS Offline Update directory wsusoffline/exclude, but the syntax has
# been reviewed: Many shell pattern seem to be unneeded. For example,
# the directory ofc can be excluded with just the name ofc. Adding shell
# pattern around the name only creates ambiguities. The syntax seems
# to be slightly different on Windows and Linux, although basically the
# same tools (mkisofs and genisoimage) are used.
#
# The file About_the_ExcludeListISO-files.txt in the directory sh/exclude
# explains the translation of the ExcludeListISO-*.txt files from Windows
# to Linux.
#
# User may create local copies of the ExcludeListISO-*.txt files in the
# directory ./exclude/local. These local copies replace the supplied
# files. This is different from the handling of custom files by WSUS
# Offline Update, but it is more the Linux way, and it allows to both
# add and remove filter lines.
#
#
# The created ISO images have filenames like
# 2019-04-14_wsusoffline-11.6.2_all.iso. These are composed of:
#
# 1. The build date from the file wsusoffline/client/builddate.txt,
#    which indicates the last run of the download script
# 2. The name wsusoffline
# 3. The WSUS Offline Update version
# 4. The used profile

# ========== Shell options ================================================

set -o errexit
set -o nounset
set -o pipefail
shopt -s nocasematch

# ========== Environment variables ========================================

export LC_ALL=C

# ========== Global variables =============================================

# The ISO image creation tool is either mkisofs or genisoimage
iso_tool=""

# Command-line parameters for mkisofs and genisoimage
#
# Both tools understand the same parameters. The man page for genisoimage
# is not quite complete, but "genisoimage -help" shows all options.
#
# The filter file, volume id and output filename are added later by the
# corresponding functions.
iso_tool_parameters=(
    -verbose
    -iso-level 4
    -joliet
    -joliet-long
    -rational-rock
    -udf
)

logfile="../log/create-iso-image.log"
# The default output path ../iso can be changed with the command-line
# option -output-path.
output_path="../iso"

command_line="$0 $*"
update_name=""
selected_excludelist=""
filter_file=""
iso_name=""

# The creation of a hashes file is disabled by default, but may be
# enabled with the command-line option -create-hashes.
declare -A options=(
    [cpp]="disabled"
    [dotnet]="disabled"
    [wddefs]="disabled"
    [hashes]="disabled"
)

# ========== Functions ====================================================

function show_usage ()
{
    printf '%s\n' "Usage:
./create-iso-image.bash <update> [<option> ...]

The update can be one of:
    all           All Windows and Office updates, 32-bit and 64-bit
    all-x86       All Windows and Office updates, 32-bit
    all-win-x64   All Windows updates, 64-bit
    all-ofc       All Office updates, 32-bit and 64-bit
    w62-x64       Windows Server 2012, 64-bit
    w63           Windows 8.1, 32-bit
    w63-x64       Windows 8.1 / Server 2012 R2, 64-bit
    w100          Windows 10, 32-bit
    w100-x64      Windows 10 / Server 2016/2019, 64-bit

The options are:
    -includecpp        Include Visual C++ Runtime Libraries
    -includedotnet     Include .NET Frameworks
    -includewddefs     Include Windows Defender definition updates for
                       the built-in Defender of Windows 8, 8.1 and 10
    -output-path <dir> Output directory for the ISO image file - the
                       default is ../iso
    -create-hashes     Create a hashes file for the ISO image file
"
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
        printf '%s\n' "Unknown operation system ${OSTYPE}"
        exit 1
    fi

    # Reveal the normalized, absolute pathname of the running script
    case "${kernel_name}" in
        Linux | FreeBSD | CYGWIN*)
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
            printf '%s\n' "Unknown operating system ${kernel_name}, ${OSTYPE}"
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


# After importing the library messages.bash, the functions can use
# log_info_message and log_error_message as needed.
function start_logging ()
{
    if [[ -f "${logfile}" ]]
    then
        # Print a divider line
        {
            echo ""
            echo "--------------------------------------------------------------------------------"
            echo ""
        } >> "${logfile}"
    else
        # Create a new file
        touch "${logfile}"
    fi
    log_info_message "Starting create-iso-image.bash"
    log_info_message "Command line: ${command_line}"
    return 0
}


function check_requirements ()
{
    local binary_name=""

    for binary_name in mkisofs genisoimage
    do
        if type -P "${binary_name}" >/dev/null
        then
            iso_tool="${binary_name}"
            break
        fi
    done

    if [[ -n "${iso_tool}" ]]
    then
        log_info_message "ISO image creation tool: ${iso_tool}"
    else
        log_error_message "Please install either mkisofs (preferred) or genisoimage, depending on your distribution."
        exit 1
    fi
    echo ""
    return 0
}


function parse_command_line ()
{
    local option_name=""
    local current_dir=""

    if (( $# < 1 ))
    then
        log_error_message "At least one parameter is required."
        show_usage
        exit 1
    fi

    log_info_message "Parsing first parameter..."
    update_name="$1"
    # Verify and set the used ExcludeListISO-*.txt
    case "${update_name}" in
        all | all-x86 | all-win-x64 | all-ofc \
        | w62-x64 | w63 | w63-x64 | w100 | w100-x64)
            log_info_message "Found update ${update_name}"
            # Verify the exclude list: There must be one exclude list
            # for each supported update name.
            #
            # The script create-iso-image.bash uses its own set of exclude
            # lists in the directory ./exclude. A user-created file in
            # the directory ./exclude/local replaces the installed file.
            for current_dir in ./exclude ./exclude/local
            do
                if [[ -f "${current_dir}/ExcludeListISO-${update_name}.txt" ]]
                then
                    selected_excludelist="${current_dir}/ExcludeListISO-${update_name}.txt"
                fi
            done
            if [[ -n "${selected_excludelist}" ]]
            then
                log_info_message "Selected exclude list: ${selected_excludelist}"
            else
                log_error_message "The file ExcludeListISO-${update_name}.txt was not found in the directory sh/exclude. The update ${update_name} may not be supported in this version of WSUS Offline update. Try the profile \"all\" instead."
                exit 1
            fi
        ;;
        *)
            log_error_message "The update ${update_name} was not recognized."
            show_usage
            exit 1
        ;;
    esac
    # Verify the download directories
    case "${update_name}" in
        # There is nothing to do for the profiles all, all-x86 and
        # all-win-x64. Using a simple "no-operation" prevents error
        # messages by the catch-all handler at the end.
        all | all-x86 | all-win-x64)
            :
        ;;
        # For the profile all-ofc and all single Windows downloads,
        # the download directories should be verified.
        #
        # The shell follows symbolic links to the download directory,
        # so the test -d matches both the original directories and valid
        # symbolic links to directories.
        all-ofc)
            if [[ -d "../client/ofc" ]]
            then
                log_info_message "Found download directory ofc."
            else
                log_error_message "The download directory ofc was not found."
                exit 1
            fi
        ;;
        w62-x64 | w63 | w63-x64 | w100 | w100-x64)
            if [[ -d "../client/${update_name}" ]]
            then
                log_info_message "Found download directory ${update_name}."
            else
                log_error_message "The download directory ${update_name} was not found."
                exit 1
            fi
        ;;
        *)
            log_error_message "The update ${update_name} was not recognized."
            show_usage
            exit 1
        ;;
    esac

    log_info_message "Parsing remaining parameter..."
    shift 1
    while (( $# > 0 ))
    do
        option_name="$1"
        case "${option_name}" in
            -includecpp | -includedotnet | -includewddefs)
                case "${update_name}" in
                    all-ofc)
                        log_warning_message "Option ${option_name} is ignored for update all-ofc."
                    ;;
                    *)
                        log_info_message "Found option ${option_name}."
                        # Strip the prefix "-include"
                        option_name="${option_name#-include}"
                        options["${option_name}"]="enabled"
                    ;;
                esac
            ;;
            -output-path)
                log_info_message "Found option -output-path."
                shift 1
                if (( $# > 0 ))
                then
                    output_path="$1"
                else
                    log_error_message "The output directory was not specified."
                    exit 1
                fi
            ;;
            -create-hashes)
                log_info_message "Found option -create-hashes."
                options[hashes]="enabled"
            ;;
            *)
                log_error_message "Option ${option_name} was not recognized."
                show_usage
                exit 1
            ;;
        esac
        shift 1
    done

    echo ""
    return 0
}


function create_filter_file ()
{
    local line=""
    local option_name=""

    # Create a temporary filter file
    log_info_message "Creating temporary filter file for ${iso_tool}..."
    if type -P mktemp >/dev/null
    then
        filter_file="$(mktemp "/tmp/create-iso-image_${update_name}.XXXXXX")"
    else
        filter_file="/tmp/create-iso-image_${update_name}.temp"
        touch "${filter_file}"
    fi
    log_info_message "Created filter file: ${filter_file}"

    # Copy the selected file ExcludeListISO-*.txt
    log_info_message "Copying ${selected_excludelist} ..."
    # Remove empty lines and comments
    grep -v -e "^$" -e "^#" "${selected_excludelist}" >> "${filter_file}"

    # Optional downloads
    for option_name in cpp dotnet wddefs
    do
        if [[ "${options[${option_name}]}" == "enabled" ]]
        then
            log_info_message "Directory ${option_name} is included."
        else
            log_info_message "Excluding directory ${option_name}..."
            # Excluded directories are specified with just the name
            # of the directory; there is no need to construct a full
            # path. Without any shell patterns, only the directory names
            # are matched.
            printf '%s\n' "${option_name}" >> "${filter_file}"
            # Unneeded files in the directory client/md are also excluded:
            if [[ "${option_name}" == "dotnet" ]]
            then
                printf '%s\n' "hashes-dotnet.txt" "hashes-dotnet-x64-glb.txt" \
                              "hashes-dotnet-x86-glb.txt" >> "${filter_file}"
            else
                printf '%s\n' "hashes-${option_name}.txt" >> "${filter_file}"
            fi
        fi
    done

    # Add the filter file to the command-line options
    iso_tool_parameters+=( -exclude-list "${filter_file}" )

    echo ""
    return 0
}


function create_output_filename ()
{
    # Get the version of WSUS Offline Update
    local wsusoffline_version=""
    if [[ -f "../cmd/DownloadUpdates.cmd" ]]
    then
        wsusoffline_version="$(grep -F -e "set WSUSOFFLINE_VERSION=" ../cmd/DownloadUpdates.cmd)"
        wsusoffline_version="$(tr -d '\r' <<< "${wsusoffline_version}")"
        wsusoffline_version="${wsusoffline_version#set WSUSOFFLINE_VERSION=}"
        log_info_message "WSUS Offline Update version: ${wsusoffline_version}"
    else
        log_error_message "The Windows batch file ../cmd/DownloadUpdates.cmd was not found."
        exit 1
    fi

    # Get the build date
    local builddate=""
    if [[ -f "../client/builddate.txt" ]]
    then
        IFS=$'\r\n' read -r builddate < "../client/builddate.txt"
        log_info_message "Builddate: ${builddate}"
    else
        log_error_message "The file ../client/builddate.txt was not found."
        exit 1
    fi

    # Create filename of the ISO image, but without the extension .iso.
    #
    # The iso_name is also used to create an accompanying hashes file.
    iso_name="${builddate}_wsusoffline-${wsusoffline_version}_${update_name}"
    log_info_message "Output filename (without extension): ${iso_name}"

    # Add output path and filename to the parameter list
    iso_tool_parameters+=( -output "${output_path}/${iso_name}.iso" )

    return 0
}


function create_volume_id ()
{
    local iso_volid
    iso_volid="WOU_${update_name}"

    # Add volume id to the parameter list
    iso_tool_parameters+=( -volid "${iso_volid}" )

    return 0
}


function run_iso_tool ()
{
    log_info_message "Running: ${iso_tool} ${iso_tool_parameters[*]} ../client"
    mkdir -p "${output_path}"
    if "${iso_tool}" "${iso_tool_parameters[@]}" "../client"
    then
        log_info_message "Created ISO image ${iso_name}.iso"
    else
        log_error_message "Error $? while creating ISO image"
    fi
    return 0
}


function create_hashes_file ()
{
    if [[ "${options[hashes]}" == "enabled" ]]
    then
        log_info_message "Creating a hashes file for ${iso_name}.iso (this may take some time)..."
        # WSUS Offline Update was always over-engineered by calculating
        # three different hashes for each file.
        hashdeep -b -c sha1 "${output_path}/${iso_name}.iso" > "${output_path}/${iso_name}_hashes.txt"
        log_info_message "Created hashes file ${iso_name}_hashes.txt"
    else
        log_info_message "Skipped creation of hashes file"
    fi
    return 0
}


function cleanup_filter_file ()
{
    if [[ -n "${filter_file}" && -f "${filter_file}" ]]
    then
        rm "${filter_file}"
    fi
    return 0
}


# The main function is called after the script name.
function create_iso_image ()
{
    setup_working_directory
    import_libraries
    start_logging
    check_requirements
    parse_command_line "$@"
    create_filter_file
    create_output_filename
    create_volume_id
    run_iso_tool
    create_hashes_file
    cleanup_filter_file

    return 0
}

# ========== Commands =====================================================

create_iso_image "$@"
exit 0
