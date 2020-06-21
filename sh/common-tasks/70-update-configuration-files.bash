# This file will be sourced by the shell bash.
#
# Filename: 70-update-configuration-files.bash
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
#     This script updates the configuration files in the exclude,
#     static, client/exclude and client/static directories. This was
#     formerly known as the "update of static download definitions"
#     (SDD), but it now includes all four directories.
#
#     The update of configuration files can be disabled by setting the
#     variable check_for_self_updates to "disabled".

# ========== Functions ====================================================

function no_pending_updates ()
{
    local result_code=1

    if [[ -f "../static/StaticDownloadLink-this.txt" && -f "../static/StaticDownloadLink-recent.txt" ]]
    then
        if diff "../static/StaticDownloadLink-this.txt" "../static/StaticDownloadLink-recent.txt" > /dev/null
        then
            result_code="0"
        fi
    fi
    return "${result_code}"
}

# The configuration files in the directories exclude, static,
# client/exclude and client/static can be updated individually using a
# mechanism known as the update of static download definitions (SDD).
#
# These updates are always relative to the latest available version
# of WSUS Offline Update. Once a new version of WSUS Offline Update is
# available, the updated files are integrated into the zip archive for
# the new version. Then the individual files are no longer available
# for download.
#
# This seems to imply, that the configuration files should only be
# updated, if the latest available version of WSUS Offline Update
# is installed. This script doesn't need to do an online check for
# new versions, because this has already been done by the script
# 50-check-wsusoffline-version.bash; but it does compare the files
# StaticDownloadLink-this.txt and StaticDownloadLink-recent.txt again:
#
# - If these files are the same, then the latest version is installed.
# - If they are different, then a new version of WSUS Offline Update is
#   available, and the update of the individual configuration files will
#   be postponed.

function run_update_configuration_files ()
{
    local timestamp_file="${timestamp_dir}/update-configuration-files.txt"
    local -i interval_length="${interval_length_configuration_files}"
    local interval_description="${interval_description_configuration_files}"
    local -i initial_errors="0"
    initial_errors="$(get_error_count)"

    if [[ "${check_for_self_updates}" == "disabled" ]]
    then
        log_info_message "The update of configuration files for WSUS Offline Update is disabled in preferences.bash"
    elif same_day "${timestamp_file}" "${interval_length}"
    then
        log_info_message "Skipped update of configuration files for WSUS Offline Update, because it has already been done less than ${interval_description} ago"
    elif no_pending_updates
    then
        log_info_message "Start updating configuration files for WSUS Offline Update..."
        remove_obsolete_files
        update_configuration_files

        if same_error_count "${initial_errors}"
        then
            log_info_message "Done updating configuration files for WSUS Offline Update."
            update_timestamp "${timestamp_file}"
        else
            log_warning_message "The update of configuration files failed. See the download log for possible error messages."
        fi
    else
        log_info_message "The update of configuration files was postponed, because there is a new version of WSUS Offline Update available, which should be installed first."
    fi
    return 0
}


function remove_obsolete_files ()
{
    local -a file_list=()
    local current_file=""

    log_info_message "Removing obsolete files from previous versions of WSUS Offline Update..."
    # Only changes since WSUS Offline Update version 9.5.3 are considered.

    # Dummy files are inserted, because zip archives cannot include
    # empty directories. They can be deleted on the first run.
    find .. -type f -name dummy.txt -delete

    # *** Obsolete internal stuff ***
    file_list+=(
        ../cmd/ExtractUniqueFromSorted.vbs
        ../cmd/CheckTRCerts.cmd
        ../client/static/StaticUpdateIds-w100-x86.txt
        ../client/static/StaticUpdateIds-w100-x64.txt
    )

    # The file ../client/exclude/ExcludeUpdateFiles-modified.txt was
    # removed in WSUS Offline Update 10.9
#    file_list+=(
#        ../client/exclude/ExcludeUpdateFiles-modified.txt
#    )

    # *** Windows Server 2003 stuff ***
    shopt -s nullglob
    file_list+=(
        ../client/static/StaticUpdateIds-w2k3-x64.txt
        ../client/static/StaticUpdateIds-w2k3-x86.txt
        ../exclude/ExcludeList-w2k3-x64.txt
        ../exclude/ExcludeList-w2k3-x86.txt
        ../exclude/ExcludeListISO-w2k3-x64.txt
        ../exclude/ExcludeListISO-w2k3-x86.txt
        ../exclude/ExcludeListUSB-w2k3-x64.txt
        ../exclude/ExcludeListUSB-w2k3-x86.txt
        ../static/StaticDownloadLinks-w2k3-x64-*.txt
        ../static/StaticDownloadLinks-w2k3-x86-*.txt
        ../xslt/ExtractDownloadLinks-w2k3-x64-*.xsl
        ../xslt/ExtractDownloadLinks-w2k3-x86-*.xsl
    )
    shopt -u nullglob

    # *** Windows language specific stuff ***
    #
    # Localized win updates are not used since Windows XP and Server
    # 2003. The only remaining file StaticDownloadLinks-win-x86-glb.txt
    # was renamed to StaticDownloadLinks-win-glb.txt.
    shopt -s nullglob
    file_list+=(
        ../static/StaticDownloadLinks-win-x86-*.txt
    )
    shopt -u nullglob

    # *** Windows 8, 32-bit stuff ***
    #
    # The server version Windows Server 2012, 64-bit (w62-x64) is still
    # supported.
    file_list+=(
        ../client/static/StaticUpdateIds-w62-x86.txt
        ../exclude/ExcludeList-w62-x86.txt
        ../exclude/ExcludeListISO-w62-x86.txt
        ../exclude/ExcludeListUSB-w62-x86.txt
        ../static/StaticDownloadLinks-w62-x86-glb.txt
        ../xslt/ExtractDownloadLinks-w62-x86-glb.xsl
    )

    # *** Windows 10 Version 1511 stuff ***
    file_list+=(
        ../client/static/StaticUpdateIds-w100-10586-x86.txt
        ../client/static/StaticUpdateIds-w100-10586-x64.txt
    )

    # Office 2007 was removed in WSUS Offline Update 11.1
    shopt -s nullglob
    file_list+=(
        ../client/static/StaticUpdateIds-o2k7.txt
        ../static/StaticDownloadLinks-o2k7-*.txt
    )
    shopt -u nullglob

    # *** Windows Essentials 2012 (Windows Live Essentials) stuff ***
    shopt -s nullglob
    file_list+=(
        ../static/StaticDownloadLinks-wle-*.txt
        ../static/custom/StaticDownloadLinks-wle-*.txt
        ../exclude/ExcludeList-wle.txt
        ../client/md/hashes-wle.txt
    )
    shopt -u nullglob

    # Print the resulting file list:
    log_debug_message "Obsolete files:" "${file_list[@]}"

    # Delete all obsolete files, if existing
    if (( ${#file_list[@]} > 0 ))
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

    # *** Warn if unsupported updates are found ***
    if [[ -d ../client/wxp || -d ../client/wxp-x64 ]]
    then
        log_warning_message "Windows XP is no longer supported."
    fi
    if [[ -d ../client/w2k3 || -d ../client/w2k3-x64 ]]
    then
        log_warning_message "Windows Server 2003 is no longer supported."
    fi
    if [[ -d ../client/w62 ]]
    then
        log_warning_message "Windows 8, 32-bit (w62) is no longer supported."
    fi
    if [[ -d ../client/o2k3 ]]
    then
        log_warning_message "Office 2003 is no longer supported."
    fi
    if [[ -d ../client/wle ]]
    then
        log_warning_message "Windows Live Essentials are no longer supported."
    fi
    # Office 2007 was removed in WSUS Offline Update 11.1
    if [[ -d ../client/o2k7 ]]
    then
        log_warning_message "Office 2007 no longer supported."
    fi

    return 0
}


# Download one file and then all URLs within that file. This is used for
# the "update of static download definitions (SDD)" in the directory
# "static", but also for the configuration files in the directories
# "exclude" and "client/static".
function recursive_download ()
{
    local download_dir="$1"
    local download_link="$2"
    local filename="${download_link##*/}"
    local -i initial_errors="0"
    initial_errors="$(get_error_count)"

    download_single_file "${download_dir}" "${download_link}"
    if same_error_count "${initial_errors}"
    then
        # The downloaded file may be empty, which is actually the default
        # state for the "update of static download definitions". These
        # files only contain URLs for configuration files, which have
        # changed since the latest release of WSUS Offline Update.
        if [[ -s "${download_dir}/${filename}" ]]
        then
            download_multiple_files "${download_dir}" "${download_dir}/${filename}"
        fi
    else
        log_warning_message "The download of ${filename} failed."
    fi
    return 0
}


function update_configuration_files ()
{
    # Testing the files ExcludeList-superseded-exclude.txt and
    # ExcludeList-superseded-exclude-seconly.txt separately seems
    # to be redundant, because they could just be added to the file
    # ExcludeDownloadFiles-modified.txt. Most probably this is done
    # in the Windows script DownloadUpdates.cmd, because the files
    # ExcludeList-superseded.txt and ExcludeList-superseded-seconly.txt
    # need to be recalculated, if these configuration files change.
    log_info_message "Downloading/validating file ExcludeList-superseded-exclude.txt ..."
    download_single_file "../exclude" "https://download.wsusoffline.net/ExcludeList-superseded-exclude.txt"
    log_info_message "Downloading/validating file ExcludeList-superseded-exclude-seconly.txt ..."
    download_single_file "../exclude" "https://download.wsusoffline.net/ExcludeList-superseded-exclude-seconly.txt"
    # The file ../client/exclude/HideList-seconly.txt was introduced
    # in WSUS Offline Update version 10.9. It replaces the former file
    # ../client/exclude/ExcludeUpdateFiles-modified.txt.
    log_info_message "Downloading/validating file HideList-seconly.txt ..."
    download_single_file "../client/exclude" "https://download.wsusoffline.net/HideList-seconly.txt"
    log_info_message "Checking directory wsusoffline/static ..."
    recursive_download "../static" "https://download.wsusoffline.net/StaticDownloadFiles-modified.txt"
    log_info_message "Checking directory wsusoffline/exclude ..."
    recursive_download "../exclude" "https://download.wsusoffline.net/ExcludeDownloadFiles-modified.txt"
    log_info_message "Checking directory wsusoffline/client/static ..."
    recursive_download "../client/static" "https://download.wsusoffline.net/StaticUpdateFiles-modified.txt"

    # The final message should indicate success or warn about
    # any errors. This is now done in the calling function
    # run_update_configuration_files.
    return 0
}

# ========== Commands =====================================================

run_update_configuration_files
echo ""
return 0 # for sourced files
