# This file will be sourced by the shell bash.
#
# Filename: 30-remove-default-languages.bash
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
#     This script removes the default German and English
#     installers from global static download files, similar to
#     the Windows scripts RemoveGermanLanguageSupport.cmd and
#     RemoveEnglishLanguageSupport.cmd.
#
#     Localized installers for the selected languages are added
#     back on the fly by the scripts 40-included-downloads.bash and
#     60-main-updates.bash. This removes the need to create and maintain
#     additional files in the wsusoffline/static/custom directory.
#
#     This task should be run after checking for possible updates to
#     the static download files.

# ========== Configuration ================================================

# The localized installers for Internet Explorer 11 on Windows Server
# 2012 are handled similar to the .NET Frameworks: The English
# installers are always downloaded and installed - these are the
# only full installers. Other languages are supported with language
# packs. Therefore, this script can only remove the German installers
# for dotnet and w62, but not the English installers.
#
# Actually, after removing w60, w61 and msse in WSUS Offline Update
# 12.0, the list of English source files is empty, and the function
# remove_english_language_support cannot be used anymore.

german_source_files=(
    "../static/StaticDownloadLinks-dotnet.txt"
    "../static/StaticDownloadLinks-dotnet-x86-glb.txt"
    "../static/StaticDownloadLinks-dotnet-x64-glb.txt"
    "../static/StaticDownloadLinks-w62-x64-glb.txt"
)


english_source_files=()

# ========== Functions ====================================================

function remove_german_language_support ()
{
    local pathname=""

    log_debug_message "Removing German language support..."
    if (( "${#german_source_files[@]}" > 0 ))
    then
        for pathname in "${german_source_files[@]}"
        do
            if grep -F -i -q -e 'deu.' -e 'de.' -e 'de-de' "${pathname}"
            then
                log_debug_message "Removing German installers from ${pathname}"
                mv "${pathname}" "${pathname}.bak"
                grep -F -i -v -e 'deu.' -e 'de.' -e 'de-de' "${pathname}.bak" \
                    > "${pathname}" || true
                # Keep file modification date
                touch -r "${pathname}.bak" "${pathname}"
                rm "${pathname}.bak"
            fi
        done
    fi
    return 0
}


function remove_english_language_support ()
{
    local pathname=""

    log_debug_message "Removing English language support..."
    if (( "${#english_source_files[@]}" > 0 ))
    then
        for pathname in "${english_source_files[@]}"
        do
            if grep -F -i -q -e 'enu.' -e 'us.' "${pathname}"
            then
                log_debug_message "Removing English installers from ${pathname}"
                mv "${pathname}" "${pathname}.bak"
                grep -F -i -v -e 'enu.' -e 'us.' "${pathname}.bak" \
                    > "${pathname}" || true
                # Keep file modification date
                touch -r "${pathname}.bak" "${pathname}"
                rm "${pathname}.bak"
            fi
        done
    fi
    return 0
}

# ========== Commands =====================================================

remove_german_language_support
#remove_english_language_support
return 0
