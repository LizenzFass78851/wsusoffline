# This file will be sourced by the shell bash.
#
# Filename: 60-main-updates.bash
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
#     The task downloads updates for Microsoft Windows and Office,
#     and also dynamic updates for the .Net Frameworks.
#
#     Global variables from other files
#     - The indexed arrays updates_list, architectures_list and
#       languages_list are defined in the file 10-parse-command-line.bash

# ========== Configuration ================================================

w100_versions=( 1507 1607 1709 1803 1809 1903 1909 2004 )
w100_versions_file="w100-versions.ini"

# ========== Global variables =============================================

if [[ "${prefer_seconly}" == enabled ]]
then
    if [[ "${revised_method}" == enabled ]]
    then
        used_superseded_updates_list="../exclude/ExcludeList-Linux-superseded-seconly-revised.txt"
    else
        used_superseded_updates_list="../exclude/ExcludeList-Linux-superseded-seconly.txt"
    fi
else
    used_superseded_updates_list="../exclude/ExcludeList-Linux-superseded.txt"
fi

# ========== Functions ====================================================

function get_main_updates ()
{
    local current_update=""
    local current_arch=""
    local current_lang=""

    if (( "${#updates_list[@]}" > 0 ))
    then
        for current_update in "${updates_list[@]}"
        do
            case "${current_update}" in
                # Common Windows updates
                win)
                    process_main_update "win" "x86" "glb"
                ;;
                # 32-bit Windows updates
                w63 | w100)
                    process_main_update "${current_update}" "x86" "glb"
                ;;
                # 64-bit Windows updates
                w62-x64 | w63-x64 | w100-x64)
                    process_main_update "${current_update/-x64/}" "x64" "glb"
                ;;
                # Common Office updates, 32-bit
                ofc)
                    if [[ "${need_localized_ofc}" == "enabled" ]]
                    then
                        # This is needed for Office 2010 and 2013
                        for current_lang in "glb" "${languages_list[@]}"
                        do
                            process_main_update "ofc" "x86" "${current_lang}"
                        done
                    else
                        # This is sufficient, if only Office 2016
                        # is selected
                        process_main_update "ofc" "x86" "glb"
                    fi
                ;;
                # Localized Office versions, 32-bit
                o2k10 | o2k13)
                    for current_lang in "glb" "${languages_list[@]}"
                    do
                        process_main_update "${current_update}" "x86" "${current_lang}"
                    done
                ;;
                # Localized Office versions, 32-bit and 64-bit
                o2k10-x64 | o2k13-x64)
                    for current_lang in "glb" "${languages_list[@]}"
                    do
                        process_main_update "${current_update/-x64/}" "x64" "${current_lang}"
                    done
                ;;
                # Office 2016, 32-bit
                o2k16)
                    process_main_update "o2k16" "x86" "glb"
                ;;
                # Office 2016, 32-bit and 64-bit
                o2k16-x64)
                    process_main_update "o2k16" "x64" "glb"
                ;;
                # Installers and dynamic updates for .Net frameworks,
                # which depend on the architecture
                dotnet)
                    if (( "${#architectures_list[@]}" > 0 ))
                    then
                        for current_arch in "${architectures_list[@]}"
                        do
                            process_main_update "dotnet" "${current_arch}" "glb"
                        done
                    else
                        log_warning_message "Skipped processing of .NET Framework updates, because there are no architectures defined for included downloads. These are derived from Windows updates only."
                    fi
                ;;
                *)
                    fail "${FUNCNAME[0]} - Unknown update name: ${current_update}"
                ;;
            esac
        done
    fi
    return 0
}


function process_main_update ()
{
    local name="$1"
    local arch="$2"
    local lang="$3"
    local -i initial_errors="0"
    initial_errors="$(get_error_count)"

    # Create naming scheme.
    #
    # The variable ${timestamp_pattern} is used to create temporary files
    # like the timestamp files and the static and dynamic download
    # lists. It is also used in messages to identify the download task.
    #
    # The timestamp pattern is usually composed of the first three
    # positional parameters of this function:
    #
    # ${name}-${arch}-${lang}
    #
    # The timestamp pattern for Windows Vista, Windows 7 and .Net
    # Frameworks uses the original language as set on the command-line
    # of the download script, to keep track of localized downloads for
    # Internet Explorer and .Net Framework language packs.
    #
    # 64-bit Office updates always include 32-bit updates, and they are
    # downloaded to the same directories. Therefore, if 64-bit updates
    # have been downloaded, it is not necessary to download 32-bit updates
    # again. The timestamp files should still be different, to make sure,
    # that the additional 64-bit downloads are always included.
    #
    # The names for the hashes_file, hashed_dir and download_dir must
    # be synchronized with the Windows script DownloadUpdates.cmd. All
    # temporary files may vary.

    local timestamp_pattern="not-available"
    local hashes_file="not-available"
    local hashed_dir="not-available"
    local download_dir="not-available"
    local timestamp_file="not-available"
    local valid_static_links="not-available"
    local valid_dynamic_links="not-available"
    local valid_links="not-available"
    local -i interval_length="${interval_length_dependent_files}"
    local interval_description="${interval_description_dependent_files}"

    case "${name}" in
        win | w63 | w100)
            timestamp_pattern="${name}-${arch}-${lang}"
            if [[ "${arch}" == "x86" ]]
            then
                hashes_file="../client/md/hashes-${name}-${lang}.txt"
                hashed_dir="../client/${name}/${lang}"
                download_dir="../client/${name}/${lang}"
            else
                hashes_file="../client/md/hashes-${name}-${arch}-${lang}.txt"
                hashed_dir="../client/${name}-${arch}/${lang}"
                download_dir="../client/${name}-${arch}/${lang}"
            fi
        ;;
        w62)
            # The timestamp pattern includes the language list, as passed
            # on the command-line, because the downloads include localized
            # installers for Internet Explorer.
            timestamp_pattern="${name}-${arch}-${language_parameter}"
            if [[ "${arch}" == "x86" ]]
            then
                hashes_file="../client/md/hashes-${name}-${lang}.txt"
                hashed_dir="../client/${name}/${lang}"
                download_dir="../client/${name}/${lang}"
            else
                hashes_file="../client/md/hashes-${name}-${arch}-${lang}.txt"
                hashed_dir="../client/${name}-${arch}/${lang}"
                download_dir="../client/${name}-${arch}/${lang}"
            fi
        ;;
        ofc | o2k10 | o2k13 | o2k16)
            timestamp_pattern="${name}-${arch}-${lang}"
            hashes_file="../client/md/hashes-${name}-${lang}.txt"
            hashed_dir="../client/${name}/${lang}"
            download_dir="../client/${name}/${lang}"
        ;;
        dotnet)
            # The timestamp pattern includes the language list, as passed
            # on the command-line, because the downloads may include
            # additional language packs for languages other than English.
            timestamp_pattern="${name}-${arch}-${language_parameter}"
            hashes_file="../client/md/hashes-${name}-${arch}-${lang}.txt"
            hashed_dir="../client/${name}/${arch}-${lang}"
            download_dir="../client/${name}/${arch}-${lang}"
        ;;
        *)
            fail "${FUNCNAME[0]} - Unknown update name: ${name}"
        ;;
    esac

    # The download results are influenced by the options to include
    # Service Packs (only in the ESR version) and to prefer security-only
    # updates. If these options change, then the affected downloads should
    # be reevaluated. Including the values of these two options in the
    # name of the timestamp file is a simple way to achieve that much.
    case "${name}" in
        w62 | w63 | dotnet)
            timestamp_file="${timestamp_dir}/timestamp-${timestamp_pattern}-${prefer_seconly}.txt"
        ;;
        *)
            timestamp_file="${timestamp_dir}/timestamp-${timestamp_pattern}.txt"
        ;;
    esac
    valid_static_links="${temp_dir}/ValidStaticLinks-${timestamp_pattern}.txt"
    valid_dynamic_links="${temp_dir}/ValidDynamicLinks-${timestamp_pattern}.txt"
    valid_links="${temp_dir}/ValidLinks-${timestamp_pattern}.txt"

    if same_day "${timestamp_file}" "${interval_length}"
    then
        log_info_message "Skipped processing of \"${timestamp_pattern//-/ }\", because it has already been done less than ${interval_description} ago"
    else
        log_info_message "Start processing of \"${timestamp_pattern//-/ }\" ..."

        seconly_safety_guard "${name}"
        verify_integrity_database "${hashed_dir}" "${hashes_file}"
        calculate_static_updates "${name}" "${arch}" "${lang}" "${valid_static_links}"
        calculate_dynamic_updates "${name}" "${arch}" "${lang}" "${valid_dynamic_links}"
        download_static_files "${download_dir}" "${valid_static_links}"
        download_multiple_files "${download_dir}" "${valid_dynamic_links}"
        cleanup_client_directory "${download_dir}" "${valid_links}" "${valid_static_links}" "${valid_dynamic_links}"
        verify_digital_file_signatures "${download_dir}"
        create_integrity_database "${hashed_dir}" "${hashes_file}"
        verify_embedded_checksums "${hashed_dir}" "${hashes_file}"

        if same_error_count "${initial_errors}"
        then
            update_timestamp "${timestamp_file}"
            log_info_message "Done processing of \"${timestamp_pattern//-/ }\""
        else
            log_warning_message "There were $(get_error_difference "${initial_errors}") runtime errors for \"${timestamp_pattern//-/ }\". See the download log for details."
        fi
    fi

    echo ""
    return 0
}


# To calculate static download links, there should be a non-empty file
# with one of the names:
#
# - StaticDownloadLinks-${name}-${lang}.txt
# - StaticDownloadLinks-${name}-${arch}-${lang}.txt
#
# These files can be found in the ../static and ../static/custom
# directories.
#
# In some cases, the files in the directory ../static may be empty:
#
# - The provided files for ofc are all empty.
# - The global static download files for dotnet may be empty after
#   removing German language packs. (They are added back from the
#   localized static download files.)
# - Static downloads are often large files like service packs. If service
#   packs are excluded from download, then the resulting file with valid
#   static download links will be empty.
#
# In such cases, users can still provide additional files in the
# ../static/custom directory; so both directories must be tested. But this
# makes a test for pre-requirements rather pointless: This test would
# be just as long as the real implementation. Instead, the temporary
# file should be tested after reading all possible locations.
#
# Note: The usage of the "win" static download files for common Windows
# downloads changed in different versions of WSUS Offline update:
#
# - In the ESR version 9.2.x, there were still localized versions with
#   the name StaticDownloadLinks-win-x86-${lang}.txt, but the localized
#   files were all empty.
# - The name StaticDownloadLinks-win-x86-glb.txt implied, that the
#   directory win/glb is for 32-bit downloads only, but actually,
#   it always included a mixture of 32-bit and 64-bit downloads,
#   e.g. Silverlight.exe and Silverlight_x64.exe.
# - In WSUS Offline Update 10.4, the localized files were removed,
#   and the architecture was removed from the filename of the global
#   file. So there is only one file StaticDownloadLinks-win-glb.txt left.

function calculate_static_updates ()
{
    local name="$1"
    local arch="$2"
    local lang="$3"
    local valid_static_links="$4"
    local current_dir=""
    local current_lang=""
    local -a exclude_lists_static=()
    # Added for the determination of Windows 10 exclude lists
    local version=""
    local key=""
    local value=""
    local -i result_code="0"
    local win_10_1903=""
    local win_10_1909=""

    log_info_message "Determining static update links ..."

    # Remove existing files
    rm -f "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt"
    rm -f "${valid_static_links}"
    for current_dir in ../static ../static/custom
    do
        # Global "win" updates (since version 10.4), 32-bit Office updates
        if [[ -s "${current_dir}/StaticDownloadLinks-${name}-${lang}.txt" ]]
        then
            cat_dos "${current_dir}/StaticDownloadLinks-${name}-${lang}.txt" \
                >> "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt"
        fi
        # Updates for Windows and .NET Frameworks, 64-bit Office updates
        if [[ -s "${current_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt" ]]
        then
            cat_dos "${current_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt" \
                >> "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt"
        fi
        # Localized downloads for Internet Explorer and .NET Frameworks
        #
        # .NET Frameworks and all Windows versions since Vista use
        # global/multilingual updates. Therefore, the only download
        # directories in recent versions of WSUS Offline Update are:
        #
        # - w62-x64/glb
        # - w63/glb
        # - w63-x64/glb
        # - w100/glb
        # - w100-x64/glb
        # - dotnet/x86-glb
        # - dotnet/x64-glb
        #
        # There are still some localized downloads, which need to
        # be added:
        #
        # - Internet Explorer installation files for Windows Server 2012
        # - .NET Framework language packs for languages other than English
        #
        # These downloads are added similar to the Windows script
        # AddCustomLanguageSupport.cmd, but without creating additional
        # files in the static/custom directory.
        case "${name}" in
            w62)
                # Localized installers for Internet Explorer 11 on
                # Windows Server 2012.
                #
                # There are no global installation files for Internet
                # Explorer. This means, that glb does not need to be
                # added to the language list at this point.
                for current_lang in "${languages_list[@]}"
                do
                    if [[ -s "${current_dir}/StaticDownloadLinks-ie11-w62-${arch}-${current_lang}.txt" ]]
                    then
                        cat_dos "${current_dir}/StaticDownloadLinks-ie11-w62-${arch}-${current_lang}.txt" \
                            >> "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt"
                    fi
                done
            ;;
        esac
    done

    # At this point, a non-empty file
    # ${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt should
    # be found.
    if [[ -s  "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt" ]]
    then
        sort_in_place "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt"

        # The ExcludeListForce-all.txt is meant to work with both static
        # and dynamic updates. The provided file in the ../exclude
        # directory is empty and does not need to be tested. Users must
        # create copies of the file in the ../exclude/custom directory.
        exclude_lists_static=( "../exclude/custom/ExcludeListForce-all.txt" )

        # Since Community Edition 12.2, Windows 10 version-specific
        # exclude lists are applied to both static and dynamic updates.
        #
        # TODO: This code should only be used once
        if [[ "${name}" == "w100" ]]
        then
            for version in "${w100_versions[@]}"
            do
                key="${version}_${arch}"
                # The shell option errexit and a trap on ERR require some
                # workaround to check the result code
                value="$(read_setting "${w100_versions_file}" "${key}")" \
                    && result_code="0" || result_code="$?"
                case "${result_code}" in
                    0)
                        if [[ "${value}" == "off" ]]
                        then
                            exclude_lists_static+=(
                                "../exclude/ExcludeList-w100-${version}.txt"
                                "../exclude/custom/ExcludeList-w100-${version}.txt"
                            )
                            #log_debug_message "Excluded: ${key} ${value}"
                            [[ "${version}" == "1903" ]] && win_10_1903="off"
                            [[ "${version}" == "1909" ]] && win_10_1909="off"
                        else
                            :
                            #log_debug_message "Included: ${key} ${value}"
                        fi
                    ;;
                    1)
                        log_warning_message "The settings file ${w100_versions_file} was not found. Please install the utility \"dialog\" and run the script update-generator.bash to select your Windows 10 versions."
                        # Break out of the enclosing for loop. There is no
                        # need to check all Windows 10 versions, if the
                        # settings file does not exist. This only causes
                        # the warning to be repeated several times.
                        break
                    ;;
                    2)
                        log_warning_message "The key ${key} was not found in the settings file ${w100_versions_file}. Please run the script update-generator.bash again to update your Windows 10 versions."
                    ;;
                    *)
                        log_error_message "Unknown error ${result_code} in function calculate_dynamic_windows_updates."
                    ;;
                esac
            done
        fi

        if [[ "${win_10_1903}" == "off" && "${win_10_1909}" == "off" ]]
        then
            exclude_lists_static+=(
                "../exclude/ExcludeList-w100-1903_1909.txt"
                "../exclude/custom/ExcludeList-w100-1903_1909.txt"
            )
        fi

        # The filename for the combined exclude list includes the
        # update name and architecture, to distinguish between different
        # Windows versions
        apply_exclude_lists \
            "${temp_dir}/StaticDownloadLinks-${name}-${arch}-${lang}.txt" \
            "${valid_static_links}" \
            "${temp_dir}/ExcludeListStatic-${name}-${arch}.txt" \
            "${exclude_lists_static[@]}"
    fi

    if ensure_non_empty_file "${valid_static_links}"
    then
        log_info_message "Created file ${valid_static_links##*/}"
    else
        case "${name}" in
            ofc)
                # The static download files for ofc in the directory
                # ../static are all empty. So it is expected, that the
                # final download list will be empty - unless the user
                # creates additional files in the ../static/custom
                # directory.
                log_info_message "No static updates found for ${name} ${arch} ${lang}. This is normal for all ofc updates."
            ;;
            *)
                # Static downloads are mostly installers and service
                # packs. If these files are excluded from download, then
                # the download list may be empty. This is not an error.
                log_warning_message "No static updates found for ${name} ${arch} ${lang}. This is normal for some localized Office updates, if service packs are excluded."
            ;;
        esac
    fi
    return 0
}


function calculate_dynamic_updates ()
{
    local name="$1"
    local arch="$2"
    local lang="$3"
    local valid_dynamic_links="$4"

    case "${name}" in
        w62 | w63 | w100 | dotnet)
            calculate_dynamic_windows_updates "$@"
        ;;
        ofc)
            calculate_dynamic_office_updates "$@"
        ;;
        *)
            log_debug_message "${FUNCNAME[0]}: Dynamic updates are not available for ${name}"
        ;;
    esac
    return 0
}


function calculate_dynamic_windows_updates ()
{
    local name="$1"
    local arch="$2"
    local lang="$3"
    local valid_dynamic_links="$4"
    local -a exclude_lists_windows=()
    local version=""
    local key=""
    local value=""
    local -i result_code="0"
    local win_10_1903=""
    local win_10_1909=""

    require_non_empty_file "../xslt/ExtractDownloadLinks-${name}-${arch}-${lang}.xsl" || return 0
    require_non_empty_file "${used_superseded_updates_list}" || fail "The required file ${used_superseded_updates_list} is missing"
    require_non_empty_file "${cache_dir}/package.xml" || fail "The required file package.xml is missing"

    log_info_message "Determining dynamic update links ..."

    # Delete existing files
    rm -f "${valid_dynamic_links}"

    # Extract dynamic download links
    "${xmlstarlet}" tr "../xslt/ExtractDownloadLinks-${name}-${arch}-${lang}.xsl" \
        "${cache_dir}/package.xml" \
        > "${temp_dir}/DynamicDownloadLinks-${name}-${arch}-${lang}.txt"
    sort_in_place "${temp_dir}/DynamicDownloadLinks-${name}-${arch}-${lang}.txt"

    # Removal of superseded and excluded download links
    #
    # Rather than using one big exclude list file, the calculation of
    # valid dynamic links is now done in two steps:
    #
    # Step 1: Superseded updates are removed by matching two sorted files
    # with complete URLs with "join". This is more efficient than using
    # "grep", which can easily run out of memory at this step.
    #
    # join -v1 does a "left join" and writes lines, which are unique on
    # the left side.
    if [[ -s "${used_superseded_updates_list}" ]]
    then
        join -v1 "${temp_dir}/DynamicDownloadLinks-${name}-${arch}-${lang}.txt" \
            "${used_superseded_updates_list}" \
            > "${temp_dir}/CurrentDynamicLinks-${name}-${arch}-${lang}.txt"
    else
        mv "${temp_dir}/DynamicDownloadLinks-${name}-${arch}-${lang}.txt" \
           "${temp_dir}/CurrentDynamicLinks-${name}-${arch}-${lang}.txt"
    fi

    # Step 2: The remaining dynamic download links are compared to one
    # or more exclude lists, which typically contain kb numbers only.
    exclude_lists_windows=(
        "../exclude/ExcludeList-${name}-${arch}.txt"
        "../exclude/custom/ExcludeList-${name}-${arch}.txt"
        "../exclude/custom/ExcludeListForce-all.txt"
    )
    if [[ "${prefer_seconly}" == enabled ]]
    then
        exclude_lists_windows+=(
            "../client/exclude/HideList-seconly.txt"
            "../client/exclude/custom/HideList-seconly.txt"
        )
    fi

    # Add Windows 10 version-specific exclude lists
    if [[ "${name}" == "w100" ]]
    then
        for version in "${w100_versions[@]}"
        do
            key="${version}_${arch}"
            # The shell option errexit and a trap on ERR require some
            # workaround to check the result code
            value="$(read_setting "${w100_versions_file}" "${key}")" \
                && result_code="0" || result_code="$?"
            case "${result_code}" in
                0)
                    if [[ "${value}" == "off" ]]
                    then
                        exclude_lists_windows+=(
                            "../exclude/ExcludeList-w100-${version}.txt"
                            "../exclude/custom/ExcludeList-w100-${version}.txt"
                        )
                        log_debug_message "Excluded: ${key} ${value}"
                        [[ "${version}" == "1903" ]] && win_10_1903="off"
                        [[ "${version}" == "1909" ]] && win_10_1909="off"
                    else
                        log_debug_message "Included: ${key} ${value}"
                    fi
                ;;
                1)
                    log_warning_message "The settings file ${w100_versions_file} was not found. Please install the utility \"dialog\" and run the script update-generator.bash to select your Windows 10 versions."
                    # Break out of the enclosing for loop. There is no
                    # need to check all Windows 10 versions, if the
                    # settings file does not exist. This only causes
                    # the warning to be repeated several times.
                    break
                ;;
                2)
                    log_warning_message "The key ${key} was not found in the settings file ${w100_versions_file}. Please run the script update-generator.bash again to update your Windows 10 versions."
                ;;
                *)
                    log_error_message "Unknown error ${result_code} in function calculate_dynamic_windows_updates."
                ;;
            esac
        done
    fi

    if [[ "${win_10_1903}" == "off" && "${win_10_1909}" == "off" ]]
    then
        exclude_lists_windows+=(
            "../exclude/ExcludeList-w100-1903_1909.txt"
            "../exclude/custom/ExcludeList-w100-1903_1909.txt"
        )
    fi

    apply_exclude_lists \
        "${temp_dir}/CurrentDynamicLinks-${name}-${arch}-${lang}.txt" \
        "${valid_dynamic_links}" \
        "${temp_dir}/ExcludeListDynamic-${name}-${arch}.txt" \
        "${exclude_lists_windows[@]}"

    # Dynamic updates should always be found, so an empty output file
    # is unexpected.
    if ensure_non_empty_file "${valid_dynamic_links}"
    then
        log_info_message "Created file ${valid_dynamic_links##*/}"
    else
        log_warning_message "No dynamic updates found for ${name} ${arch} ${lang}"
    fi
    return 0
}


# New method for the calculation of dynamic Office updates, based on the
# example script "extract-office-locations-v2.bash" in the forum article
# https://forums.wsusoffline.net/viewtopic.php?f=3&t=9954&start=10#p30279

function calculate_dynamic_office_updates ()
{
    local name="$1"
    local arch="$2"
    local lang="$3"
    local valid_dynamic_links="$4"
    local locale_long=""
    local update_id=""
    local url=""
    local skip_rest=""
    local -a exclude_lists_office=()

    # Preconditions
    [[ "${name}" == ofc ]] || return 0
    require_non_empty_file "${used_superseded_updates_list}" || fail "The required file ${used_superseded_updates_list} is missing"
    require_non_empty_file "${cache_dir}/package.xml" || fail "The required file package.xml is missing"

    log_info_message "Determining dynamic update links..."

    # Remove existing files
    rm -f "${valid_dynamic_links}"

    # Locales with language and territory code as used in the Windows
    # script wsusoffline/client/cmd/DetermineSystemProperties.vbs
    #
    # For details see the configuration files in /usr/share/i18n/locales
    # (Debian 10 Buster)
    case "${lang}" in
        deu) locale_long="de-de";;
        enu) locale_long="en-us";;
        ara) locale_long="ar-sa";;
        chs) locale_long="zh-cn";;
        cht) locale_long="zh-tw";;
        csy) locale_long="cs-cz";;
        dan) locale_long="da-dk";;
        nld) locale_long="nl-nl";;
        fin) locale_long="fi-fi";;
        fra) locale_long="fr-fr";;
        ell) locale_long="el-gr";;
        heb) locale_long="he-il";;
        hun) locale_long="hu-hu";;
        ita) locale_long="it-it";;
        jpn) locale_long="ja-jp";;
        kor) locale_long="ko-kr";;
        nor) locale_long="nb-no";;
        plk) locale_long="pl-pl";;
        ptg) locale_long="pt-pt";;
        ptb) locale_long="pt-br";;
        rus) locale_long="ru-ru";;
        esn) locale_long="es-es";;
        sve) locale_long="sv-se";;
        trk) locale_long="tr-tr";;
        glb) log_debug_message "The language parameter glb is silently ignored.";;
        *) fail "Unsupported or unknown language ${lang}";;
    esac

    # The file office-update-ids-and-locations.txt lists all Office
    # UpdateIds (in the form of UUIDs) and their locations, before
    # splitting the file into global and localized updates or applying
    # any exclude lists. This file only depends on the WSUS offline
    # scan file wsusscn2.cab. Once created, it will be cached in the
    # directory wsusoffline/cache and can be reused. Like the list of
    # superseded updates, it will be automatically recalculated, if a
    # new version of the file wsusscn2.cab becomes available.
    if [[ -f "${cache_dir}/office-update-ids-and-locations.txt" ]]
    then
        log_info_message "Found cached file office-update-ids-and-locations.txt"
    else
        # Rebuild the file office-update-ids-and-locations.txt
        #
        # Extract file 1, featuring a new xslt file
        log_info_message "Extracting file 1, office-revision-and-update-ids.txt ..."
        "${xmlstarlet}" transform \
            ../xslt/extract-revision-and-update-ids-ofc.xsl \
            "${cache_dir}/package.xml" \
            > "${temp_dir}/office-revision-and-update-ids.txt"
        sort_in_place "${temp_dir}/office-revision-and-update-ids.txt"

        # The next two files are also used for the calculation of
        # superseded updates. If they already exist, they don't need to
        # be recalculated.

        if [[ ! -f "${temp_dir}/BundledUpdateRevisionAndFileIds.txt" ]]
        then
            # Extract file 2, using an existing xslt file from the
            # calculation of superseded updates
            log_info_message "Extracting file 2, BundledUpdateRevisionAndFileIds.txt ..."
            "${xmlstarlet}" transform \
                ../xslt/extract-update-revision-and-file-ids.xsl \
                "${cache_dir}/package.xml" \
                > "${temp_dir}/BundledUpdateRevisionAndFileIds.txt"
            sort_in_place "${temp_dir}/BundledUpdateRevisionAndFileIds.txt"
        fi

        if [[ ! -f "${temp_dir}/UpdateCabExeIdsAndLocations.txt" ]]
        then
            # Extract file 3, using an existing xslt file from the
            # calculation of superseded updates
            log_info_message "Extracting file 3, UpdateCabExeIdsAndLocations.txt ..."
            "${xmlstarlet}" transform \
                ../xslt/extract-update-cab-exe-ids-and-locations.xsl \
                "${cache_dir}/package.xml" \
                > "${temp_dir}/UpdateCabExeIdsAndLocations.txt"
            sort_in_place "${temp_dir}/UpdateCabExeIdsAndLocations.txt"
        fi

        # Join the first two files to get the FileIds. The UpdateId of
        # the bundle record is copied, because it is needed later for
        # the files UpdateTable-ofc-*.csv.
        #
        # Input file 1: office-revision-and-update-ids.txt
        # - Field 1: RevisionId of the bundle record
        # - Field 2: UpdateId of the bundle record
        # Input file 2: BundledUpdateRevisionAndFileIds.txt
        # - Field 1: RevisionId of the parent bundle record
        # - Field 2: RevisionId of the update record for the PayloadFile
        # - Field 3: FileId of the PayloadFile
        # Output
        # - Field 1: FileId of the PayloadFile
        # - Field 2: UpdateId of the bundle record
        log_info_message "Creating file 4, office-file-and-update-ids.txt ..."
        join -t ',' -o 2.3,1.2 \
            "${temp_dir}/office-revision-and-update-ids.txt" \
            "${temp_dir}/BundledUpdateRevisionAndFileIds.txt" \
            > "${temp_dir}/office-file-and-update-ids.txt"
        sort_in_place "${temp_dir}/office-file-and-update-ids.txt"

        # Join with third file to get the FileLocations (URLs)
        #
        # Input file 1: office-file-and-update-ids.txt
        # - Field 1: FileId of the PayloadFile
        # - Field 2: UpdateId of the bundle record
        # Input file 2: UpdateCabExeIdsAndLocations.txt
        # - Field 1: FileId of the PayloadFile
        # - Field 2: Location (URL)
        # Output
        # - Field 1: UpdateId of the bundle record
        # - Field 2: Location (URL)
        log_info_message "Creating file 5, office-update-ids-and-locations.txt ..."
        join -t ',' -o 1.2,2.2 \
            "${temp_dir}/office-file-and-update-ids.txt" \
            "${temp_dir}/UpdateCabExeIdsAndLocations.txt" \
            > "${cache_dir}/office-update-ids-and-locations.txt"
        sort_in_place "${cache_dir}/office-update-ids-and-locations.txt"
    fi

    # Separate the updates into global and localized versions
    log_info_message "Creating file 6, office-update-ids-and-locations-${lang}.txt ..."
    case "${lang}" in
        glb)
            # Remove all localized files to get the global/multilingual
            # updates
            grep -F -v -f libraries/locales.txt \
                "${cache_dir}/office-update-ids-and-locations.txt" \
                > "${temp_dir}/office-update-ids-and-locations-${lang}.txt"
        ;;
        *)
            # Extract localized files using search strings like "-en-us_"
            grep -F -e "-${locale_long}_" \
                "${cache_dir}/office-update-ids-and-locations.txt" \
                > "${temp_dir}/office-update-ids-and-locations-${lang}.txt" || true
        ;;
    esac

    if ! require_non_empty_file "${temp_dir}/office-update-ids-and-locations-${lang}.txt"
    then
        log_warning_message "The file office-update-ids-and-locations-${lang}.txt is empty, because no localized updates were found. This may happen, if the experimental XSLT file extract-o2k16-revision-and-update-ids.xsl is used to extract Office updates. Then only Office 2016 should be selected in update-generator.bash."
        return 0
    fi

    # Create the files ../client/ofc/UpdateTable-ofc-*.csv, which are
    # needed during the installation of the updates. They link the
    # UpdateIds (in form of UUIDs) to the file names.
    log_info_message "Creating file 7, UpdateTable-ofc-${lang}.csv ..."
    mkdir -p "../client/ofc"
    while IFS=',' read -r update_id url skip_rest
    do
        printf '%s\r\n' "${update_id},${url##*/}"
    done < "${temp_dir}/office-update-ids-and-locations-${lang}.txt" \
         > "../client/ofc/UpdateTable-ofc-${lang}.csv"

    # At this point, the UpdateIds are no longer needed. Only the
    # locations (URLs) are needed to create a list of dynamic download
    # links.
    log_info_message "Creating file 8, DynamicDownloadLinks-ofc-${lang}.txt ..."
    cut -d ',' -f 2 \
        "${temp_dir}/office-update-ids-and-locations-${lang}.txt" \
        > "${temp_dir}/DynamicDownloadLinks-ofc-${lang}.txt"
    sort_in_place "${temp_dir}/DynamicDownloadLinks-ofc-${lang}.txt"

    # Remove the superseded updates to get a list of current dynamic
    # download links
    #
    # TODO: The two alternate lists ExcludeList-Linux-superseded.txt
    # and ExcludeList-Linux-superseded-seconly.txt only make a
    # difference for Windows 7, 8 and 8.1 and the corresponding
    # Windows Server versions. For Office updates, the file
    # ExcludeList-Linux-superseded.txt could be used as before.
    log_info_message "Creating file 9, CurrentDynamicLinks-ofc-${lang}.txt ..."
    if [[ -s "${used_superseded_updates_list}" ]]
    then
        join -v1 "${temp_dir}/DynamicDownloadLinks-ofc-${lang}.txt" \
            "${used_superseded_updates_list}" \
            > "${temp_dir}/CurrentDynamicLinks-ofc-${lang}.txt"
    else
        mv "${temp_dir}/DynamicDownloadLinks-ofc-${lang}.txt" \
           "${temp_dir}/CurrentDynamicLinks-ofc-${lang}.txt"
    fi

    # Apply the remaining exclude lists, which typically contain kb
    # numbers only
    exclude_lists_office=(
        "../exclude/ExcludeList-ofc.txt"
        "../exclude/ExcludeList-ofc-${lang}.txt"
        "../exclude/custom/ExcludeList-ofc.txt"
        "../exclude/custom/ExcludeList-ofc-${lang}.txt"
        "../exclude/custom/ExcludeListForce-all.txt"
    )
    # The file ExcludeList-ofc-lng.txt was added in Community Edition
    # 11.9.4 ESR and 12.2
    if [[ "${lang}" != "glb" ]]
    then
        exclude_lists_office+=(
            "../exclude/ExcludeList-ofc-lng.txt"
            "../exclude/custom/ExcludeList-ofc-lng.txt"
        )
    fi

    log_info_message "Creating file 10, ${valid_dynamic_links##*/} ..."
    apply_exclude_lists \
        "${temp_dir}/CurrentDynamicLinks-ofc-${lang}.txt" \
        "${valid_dynamic_links}" \
        "${temp_dir}/ExcludeListDynamic-ofc-${lang}.txt" \
        "${exclude_lists_office[@]}"

    # Dynamic updates should always be found for "ofc".
    if ensure_non_empty_file "${valid_dynamic_links}"
    then
        log_info_message "Created file ${valid_dynamic_links##*/}"
    else
        log_warning_message "No dynamic updates found for ${name} ${arch} ${lang}"
    fi
    return 0
}


# Safety guard for security-only updates for Windows 8, 8.1 and the
# corresponding server versions.
#
# The download and installation of security-only updates depends on the
# correct configuration of the files:
#
# - wsusoffline/client/exclude/HideList-seconly.txt
# - wsusoffline/client/static/StaticUpdateIds-w62-seconly.txt
# - wsusoffline/client/static/StaticUpdateIds-w63-seconly.txt
#
# Usually, these files must be updated after each official patch day,
# which is the second Tuesday each month. This is done by the maintainer
# of WSUS Offline Update, and new configuration files are downloaded
# automatically.
#
# The function seconly_safety_guard tries to make sure, that the
# configuration files have been updated after the last official patch
# day. Otherwise, the download will be stopped, to prevent unwanted side
# effects. The possible side effect would be the download and installation
# of the most recent quality and security update rollup. Since these
# update rollups are cumulative, they will install everything, which
# was meant to be prevented by specifying security-only updates in the
# first place.

function seconly_safety_guard ()
{
    local update_name="$1"

    # Preconditions
    if [[ "${prefer_seconly}" != "enabled" ]]
    then
        log_debug_message "Option prefer_seconly is not enabled"
        return 0
    fi
    case "${update_name}" in
        w62 | w63)
            log_debug_message "Recognized Windows 8 or 8.1"
        ;;
        *)
            log_debug_message "Not an affected Windows version"
            return 0
        ;;
    esac

    log_info_message "Running safety guard for security-only update rollups..."

    # Get the official patch day of this month

    local this_month=""
    this_month="$(date -u '+%Y-%m')"          # for example 2017-08
    local day_of_month=""                     # as padded strings 08..14
    local current_date=""                     # ISO-8601 format: 2017-08-08
    local -i day_of_week="0"                  # as integer 1..7, with Monday=1
    local patchday_this_month=""              # ISO-8601 format: 2017-08-08
    local -i patchday_this_month_seconds="0"  # seconds since 1970-01-01
    local input_format="%Y-%m-%d %H:%M:%S"    # used for FreeBSD date

    # GNU/Linux date has different options than FreeBSD date. In
    # particular, the option -d or --date must be replaced with the
    # option -v or a combination of -j and -f. The option -v allows time
    # calculations similar to GNU/Linux date. The option -f is suggested
    # for date format conversions.

    case "${kernel_name}" in
        Linux | CYGWIN*)
            # Note: The variable "${day_of_month}" should get the
            # values as zero padded strings, to construct the full
            # date in ISO format. Therefore, the C-style loop "for
            # (start;end;increment)" cannot be used at this point.
            for day_of_month in 08 09 10 11 12 13 14
            do
                current_date="${this_month}-${day_of_month}"
                day_of_week="$(date -u -d "${current_date}" '+%u')"
                if (( day_of_week == 2 ))
                then
                    patchday_this_month="${current_date}"
                    patchday_this_month_seconds="$(date -u -d "${current_date}" '+%s')"
                fi
            done
        ;;
        # TODO: So far, only FreeBSD 12.1 was tested
        Darwin | FreeBSD | NetBSD | OpenBSD)
            for day_of_month in 08 09 10 11 12 13 14
            do
                # The hours, minutes and seconds must be specified for
                # FreeBSD date; otherwise the current time will be used.
                current_date="${this_month}-${day_of_month}"
                day_of_week="$(date -j -u -f "${input_format}" "${current_date} 00:00:00" '+%u')"
                if (( day_of_week == 2 ))
                then
                    patchday_this_month="${current_date}"
                    patchday_this_month_seconds="$(date -j -u -f "${input_format}" "${current_date} 00:00:00" '+%s')"
                fi
            done
        ;;
        *)
            log_error_message "Unknown operating system ${kernel_name}, ${OSTYPE}"
            exit 1
        ;;
    esac
    log_info_message "Official patch day of this month: ${patchday_this_month}"
    log_debug_message "Official patch day of this month in seconds: ${patchday_this_month_seconds}"

    # Get the official patch day of the last month
    local last_month=""
    local patchday_last_month=""
    local -i patchday_last_month_seconds="0"

    case "${kernel_name}" in
        Linux | CYGWIN*)
            # GNU date understands relative date specifications in plain
            # English like "yesterday", "last week" or "last month". To
            # get the last month, we use the 15th of this month and go
            # back to "last month":
            last_month="$(date -u -d "${this_month}-15 last month" '+%Y-%m')"
            for day_of_month in 08 09 10 11 12 13 14
            do
                current_date="${last_month}-${day_of_month}"
                day_of_week="$(date -u -d "${current_date}" '+%u')"
                if (( day_of_week == 2 ))
                then
                    patchday_last_month="${current_date}"
                    patchday_last_month_seconds="$(date -u -d "${current_date}" '+%s')"
                fi
            done
        ;;
        Darwin | FreeBSD | NetBSD | OpenBSD)
            # Go to the 15th of this month and then back for one month.
            last_month="$(date -u -v 15d -v 0H -v 0M -v 0S -v -1m '+%Y-%m')"
            for day_of_month in 08 09 10 11 12 13 14
            do
                current_date="${last_month}-${day_of_month}"
                day_of_week="$(date -j -u -f "${input_format}" "${current_date} 00:00:00" '+%u')"
                if (( day_of_week == 2 ))
                then
                    patchday_last_month="${current_date}"
                    patchday_last_month_seconds="$(date -j -u -f "${input_format}" "${current_date} 00:00:00" '+%s')"
                fi
            done
        ;;
        *)
            log_error_message "Unknown operating system ${kernel_name}, ${OSTYPE}"
            exit 1
        ;;
    esac
    log_info_message "Official patchday of the last month: ${patchday_last_month}"
    log_debug_message "Official patchday of the last month in seconds: ${patchday_last_month_seconds}"

    # The last official patch day is the patch day of this month,
    # if today is on the patch day of this month or later. Otherwise,
    # the last patch day is the patch day of the last month.

    local -i today_seconds="0"
    today_seconds="$(date -u '+%s')"

    local last_patchday=""
    local -i last_patchday_seconds="0"
    if (( today_seconds >= patchday_this_month_seconds ))
    then
        last_patchday="${patchday_this_month}"
        last_patchday_seconds="${patchday_this_month_seconds}"
    else
        last_patchday="${patchday_last_month}"
        last_patchday_seconds="${patchday_last_month_seconds}"
    fi
    log_info_message "Last official patchday: ${last_patchday}"

    # Create a list of configuration files for the correct handling of
    # security-only update rollups. This list only includes the default
    # files of WSUS Offline Update, not user-created files in the custom
    # subdirectories.
    #
    # Appending an asterisk will remove the files from the list, if they
    # cannot be found anymore.

    local -a configuration_files=()
    shopt -s nullglob
    configuration_files=(
        ../client/exclude/HideList-seconly.txt*
        ../client/static/StaticUpdateIds-w62-seconly.txt*
        ../client/static/StaticUpdateIds-w63-seconly.txt*
    )
    shopt -u nullglob

    # Usually, these configuration files must be updated AFTER each patch
    # day. The script prints a warning, if the modification date of one
    # of the configuration files is BEFORE the last patch day.

    local current_file=""
    local modification_date=""              # ISO-8601 format (date only)
    local -i modification_date_seconds="0"  # seconds since 1970-01-01
    local -i misconfiguration="0"
    for current_file in "${configuration_files[@]}"
    do
        modification_date="$(date -u -I -r "${current_file}")"
        modification_date_seconds="$(date -u -r "${current_file}" '+%s')"
        if (( modification_date_seconds < last_patchday_seconds ))
        then
            log_warning_message "The configuration file ${current_file} was modified on ${modification_date}, which was before the last official patch day on ${last_patchday}."
            misconfiguration="1"
        fi
    done

    if (( misconfiguration == 1 ))
    then
        log_message "\
The correct handling of security-only update rollups for both download
and installation depends on the configuration files:

- wsusoffline/client/exclude/HideList-seconly.txt
- wsusoffline/client/static/StaticUpdateIds-w62-seconly.txt
- wsusoffline/client/static/StaticUpdateIds-w63-seconly.txt

These files should be updated after the official patch day, which is the
second Tuesday each month. This is done by the maintainer of WSUS Offline
Update, but it may take some days. New versions of the configuration
files are downloaded automatically.

If these files have not been updated yet, then the download and
installation of security-only updates should be postponed, to prevent
unwanted side effects.

If necessary, you could also update the configuration files yourself. See
the discussion in the forum for details:

- https://forums.wsusoffline.net/viewtopic.php?f=4&t=6897&start=10#p23708

If you have manually updated and verified the configuration files, you
can set the variable exit_on_configuration_problems to \"disabled\" in the
preferences file, to let the script continue at this point.
"
        if [[ "${exit_on_configuration_problems}" == "enabled" ]]
        then
            log_error_message "The script will exit now, to prevent unwanted side effects with the download and installation of security-only updates for Windows 8 and 8.1."
            exit 1
        else
            log_warning_message "There are configuration problems with the download of security-only updates for Windows 8 and 8.1. Proceed with caution to prevent unwanted side effects."
        fi
    else
        log_info_message "No problems found."
    fi

    return 0
}

# ========== Commands =====================================================

get_main_updates
return 0
