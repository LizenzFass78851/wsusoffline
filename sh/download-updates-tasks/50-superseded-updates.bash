# This file will be sourced by the shell bash.
#
# Filename: 50-superseded-updates.bash
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
#     This task calculates superseded updates. The current implementation
#     for both Windows and Linux is depicted in a forum article:
#
#     https://forums.wsusoffline.net/viewtopic.php?f=5&t=5676
#
#     One remaining problem with this implementation is, that superseded
#     updates may be missing, if the superseding updates are excluded
#     from download.
#
#     This is an old problem, which was first found with Windows XP:
#     The desktop versions of Windows XP are not officially supported
#     anymore, but the embedded Windows XP POSReady still is. Updates for
#     the embedded Windows XP would replace (and supersede) older updates
#     for the desktop versions. The newer updates cannot be installed,
#     but the older updates are now missing. This can be solved by adding
#     the missing updates to the file ExcludeList-superseded-exclude.txt,
#     but this only works in retrospect.
#
#     A revised method for the calculation of superseded updates was
#     first suggested in a forum article, to help with the problem,
#     that full quality update rollups superseded security-only updates
#     (but only for the first month). If quality update rollups were
#     excluded from download, then security-only updates would still
#     be treated as superseded. Without any workaround, they would be
#     missing in the download.
#
#     https://forums.wsusoffline.net/viewtopic.php?f=5&t=6141
#
#     Version 1.0-beta-1 of the Linux download scripts (the initial
#     release) already included an experimental implementation of this
#     method in the subdirectory available-tasks.
#
#     But the problem was solved differently at the time, by introducing
#     new configuration files in the exclude, client/static and
#     client/exclude directories. The revised method also needed an
#     "initial block list" of excluded updates to start with, and it
#     was not quite clear, how to create this list.
#
#     But now we can use the file HideList-seconly.txt as input, to
#     automatically correct the list of superseded updates for updates,
#     which are superseded by the full quality update rollups, but not
#     by the security-only updates.
#
#     In the meantime, Microsoft removed the dependencies between quality
#     update rollups and security-only updates after just one month:
#
#     "UPDATED 12/5/2016: Starting in December 2016, monthly rollups
#     will not supersede security only updates. The November 2016 monthly
#     rollup will also be updated to not supersede security only updates."
#     -- https://techcommunity.microsoft.com/t5/Windows-Blog-Archive/More-on-Windows-7-and-Windows-8-1-servicing-changes/ba-p/166783
#
#     So maybe the initial problem doesn't really exist anymore.
#
#     But in rare cases, there are still updates reported as missing. It
#     seems, that the quality update rollups sometimes include (and
#     supersede) older updates, while the security-only updates only
#     include new updates for the current month. Then again, such updates
#     would be missing, if security-only updates are selected.
#
#     In two cases, the revised method could automatically recover
#     the missing updates. Therefore, it may still be useful to have a
#     working implementation of this method around.
#
#     https://forums.wsusoffline.net/viewtopic.php?f=4&t=7085
#     https://forums.wsusoffline.net/viewtopic.php?f=2&t=8697
#
#     To use this method, both options prefer_seconly and revised_method
#     should be set to "enabled" in the preferences file.

# ========== Functions ====================================================

# The WSUS catalog file package.xml is only extracted from the archive
# wsusscn2.cab, if this file changes. Otherwise, a cached copy of
# package.xml is used.

function check_wsus_catalog_file ()
{
    if [[ -f "${cache_dir}/package.xml"           \
       && -f "${cache_dir}/package-formatted.xml" \
       && -f "../client/catalog-creationdate.txt" ]]
    then
        log_info_message "Found cached update catalog file package.xml"
    else
        unpack_wsus_catalog_file
    fi
    return 0
}

function unpack_wsus_catalog_file ()
{
    # Preconditions
    require_file "../client/wsus/wsusscn2.cab" || fail "The required file wsusscn2.cab is missing"

    # Delete existing files, just to be sure
    rm -f "${cache_dir}/package.xml"
    rm -f "${cache_dir}/package-formatted.xml"
    rm -f "../client/catalog-creationdate.txt"

    # Create the cache directory, if it does not exist yet
    mkdir -p "${cache_dir}"

    # cabextract often warns about "possible extra bytes at end of file",
    # if the file wsusscn2.cab is tested or expanded. These warnings
    # can be ignored.

    log_info_message "Extracting Microsoft's update catalog file (ignore any warnings about extra bytes at end of file)..."

    # As of 2019-02-26, cabextract is still broken in Debian 10
    # Buster/testing, although two relevant bug reports have long been
    # closed and marked as "Fixed":
    #
    # - libmspack0: Regression when extracting cabinets using -F option
    #   fixed upstream, needs to be patched
    #   https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=912687
    # - cabextract: -F option doesn't work correctly.
    #   https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=914263
    #
    # cabextract on Debian 10 Buster may create a damaged file package.cab
    # at the first step, but without setting any error code. The file
    # package.cab can only be tested with "cabextract -t", which is used
    # by the function verify_cabinet_file.
    #
    # The workaround is to omit the option -F and extract the file
    # wsusscn2.cab completely.

    log_info_message "Step 1: Extracting package.cab from wsusscn2.cab ..."
    if cabextract -d "${temp_dir}" -F "package.cab" "../client/wsus/wsusscn2.cab" \
       && verify_cabinet_file "${temp_dir}/package.cab"
    then
        log_info_message "The file package.cab was extracted successfully."
    else
        log_warning_message "The extraction of package.cab failed. Trying workaround for broken cabextract in Debian 10 Buster/testing..."
        # The archive wsusscn2.cab must be completely expanded, which
        # may take slightly longer.
        if cabextract -d "${temp_dir}" "../client/wsus/wsusscn2.cab" \
           && verify_cabinet_file "${temp_dir}/package.cab"
        then
            log_info_message "The file package.cab was extracted successfully."
        else
            rm -f "${timestamp_dir}/timestamp-wsus-all-glb.txt"
            fail "The file package.cab could not be extracted. The script cannot continue without this file."
        fi
    fi

    # The option -F was never really needed for the second step, because
    # the archive package.cab only contains one file, package.xml.

    log_info_message "Step 2: Extracting package.xml from package.cab ..."
    if cabextract -d "${cache_dir}" "${temp_dir}/package.cab" \
       && ensure_non_empty_file "${cache_dir}/package.xml"
    then
        log_info_message "The file package.xml was extracted successfully."
    else
        rm -f "${timestamp_dir}/timestamp-wsus-all-glb.txt"
        fail "The file package.xml could not be extracted. The script cannot continue without this file."
    fi

    # Create a formatted copy of the file package.xml
    #
    # The file package.xml contains just one long line without any line
    # breaks. This is the most compact form of XML files and similar
    # formats like JSON. In this form, it can be parsed by applications,
    # but it cannot be displayed in a text editor nor searched with
    # grep. For convenience, the script also creates a pretty-printed
    # copy of the file with the name package-formatted.xml.

    log_info_message "Creating a formatted copy of the file package.xml ..."
    "${xmlstarlet}" format "${cache_dir}/package.xml" > "${cache_dir}/package-formatted.xml"

    # Extract the CreationDate of the file package.xml
    #
    # The CreationDate can be found in the second line of the file
    # package-formatted.xml, for example:
    #
    # <OfflineSyncPackage
    # xmlns="http://schemas.microsoft.com/msus/2004/02/OfflineSync"
    # MinimumClientVersion="5.8.0.2678" ProtocolVersion="1.0"
    # PackageId="ec984487-b493-4c3a-bc8f-b27119c4e4aa"
    # SourceId="cc56dcba-9026-4399-8535-7a3c9bed7086"
    # CreationDate="2019-04-06T03:56:57Z" PackageVersion="1.1">
    #
    # The date can be extracted with sed, but if the search pattern
    # cannot be found, then sed will return the whole input line. To
    # prevent this result, the XML attributes are split into single lines,
    # and the correct one is selected with grep.
    #
    # It is also possible, to use another XSLT transformation for the
    # extraction of this attribute, but this will take much longer.
    #
    # See also: https://forums.wsusoffline.net/viewtopic.php?f=3&t=8997

    # TODO: This always looked like a hack. Using an XSLT file may take
    # longer, but it is only needed once per month.

    if [[ -f "../cache/package-formatted.xml" ]]
    then
        log_info_message "Extract the catalog CreationDate..."

        head -n 2 "../cache/package-formatted.xml"                  \
            | tail -n 1                                             \
            | tr ' ' '\n'                                           \
            | grep -F "CreationDate"                                \
            | sed 's/^CreationDate="\([[:print:]]\{20\}\)".*$/\1/'  \
            | todos_line_endings                                    \
            > "../client/catalog-creationdate.txt"                  \
            || true

        get_catalog_creationdate
    else
        log_warning_message "The file package-formatted.xml was not found."
    fi

    return 0
}


# The files ExcludeList-Linux-superseded.txt,
# ExcludeList-Linux-superseded-seconly.txt, and
# ExcludeList-Linux-superseded-seconly-revised.txt will be deleted, if
# a new version of WSUS Offline Update or the Linux download scripts is
# installed, or if any of the following configurations files has changed:
#
# ../exclude/ExcludeList-superseded-exclude.txt
# ../exclude/ExcludeList-superseded-exclude-seconly.txt
# ../client/exclude/HideList-seconly.txt
# ../client/wsus/wsusscn2.cab
#
# The function check_superseded_updates then checks, if the exclude
# lists still exist.
#
# Previously, this function did some more checks, but since the files
# ExcludeList-superseded.txt and ExcludeList-superseded-seconly.txt were
# renamed in version 1.5 of the Linux download scripts, these tests are
# not needed anymore.

function check_superseded_updates ()
{
    if [[ -f "../exclude/ExcludeList-Linux-superseded.txt" \
       && -f "../exclude/ExcludeList-Linux-superseded-seconly.txt" \
       && -f "../exclude/ExcludeList-Linux-superseded-seconly-revised.txt" ]]
    then
        log_info_message "Found valid list of superseded updates"
    else
        rebuild_superseded_updates
    fi
    return 0
}


# The function rebuild_superseded_updates calculates three alternate lists
# of superseded updates:
#
# ../exclude/ExcludeList-Linux-superseded.txt
# ../exclude/ExcludeList-Linux-superseded-seconly.txt
# ../exclude/ExcludeList-Linux-superseded-seconly-revised.txt

function rebuild_superseded_updates ()
{
    local -a excludelist_overrides=()
    local -a excludelist_overrides_seconly=()
    local current_dir=""
    local current_file=""

    # Preconditions
    require_file "${cache_dir}/package.xml" || fail "The required file package.xml is missing"

    # Delete existing files, just to be sure
    rm -f "../exclude/ExcludeList-Linux-superseded.txt"
    rm -f "../exclude/ExcludeList-Linux-superseded-seconly.txt"
    rm -f "../exclude/ExcludeList-Linux-superseded-seconly-revised.txt"

    log_info_message "Determining superseded updates (please be patient, this will take a while)..."

    # As depicted in a forum article, the calculation of superseded
    # updates uses three steps. Each step joins two input files to a
    # new output file. The input files are csv-formatted text files with
    # the joined fields in the first column.
    #
    # https://forums.wsusoffline.net/viewtopic.php?f=5&t=5676

    # *** First step: Calculate superseded revision ids ***
    #
    # Superseded bundle records can be recognized by an element of type
    # "SupersededBy" with one or more newer bundle RevisionIds. But
    # some of these RevisionIds may not may not actually exist anymore,
    # probably because the update records and the corresponding downloads
    # have been deleted. For example, the bundle record for the Windows
    # 7 update kb2604114 includes the element:
    #
    #  <SupersededBy>
    #    <Revision Id="13941260"/>
    #    <Revision Id="16506826"/>
    #  </SupersededBy>
    #
    # but both RevisionIds don't seem to exist. Therefore, it is necessary
    # to extract a list all existing bundle RevisionIds and use it to
    # correct the list of superseding bundle RevisionIds. The result
    # will be a list of valid superseded bundle RevisionIds.

    log_info_message "Extracting file 1, all existing bundle RevisionIds..."
    "${xmlstarlet}" transform \
        ../xslt/extract-existing-bundle-revision-ids.xsl \
        "${cache_dir}/package.xml" \
        > "${temp_dir}/bundle-revision-ids-all.txt"
    sort_in_place "${temp_dir}/bundle-revision-ids-all.txt"

    log_info_message "Extracting file 2, superseding and superseded bundle RevisionIds..."
    "${xmlstarlet}" transform \
        ../xslt/extract-superseding-and-superseded-revision-ids.xsl \
        "${cache_dir}/package.xml" \
        > "${temp_dir}/superseding-and-superseded-revision-ids.txt"
    sort_in_place "${temp_dir}/superseding-and-superseded-revision-ids.txt"

    # Get valid superseded bundle RevisionIds by verifying, that the
    # superseding bundle RevisionIds actually exist.
    #
    # Input files:
    # File 1: bundle-revision-ids-all.txt
    # - Field 1: all existing bundle RevisionIds
    # File 2: superseding-and-superseded-revision-ids.txt
    # - Field 1: superseding bundle RevisionIds
    # - Field 2: superseded bundle RevisionIds (not verified)
    #
    # Output file: valid superseded bundle RevisionIds
    log_info_message "Joining files 1 and 2 to file 3, valid superseded bundle RevisionIds..."
    join -t ',' -o 2.2 \
        "${temp_dir}/bundle-revision-ids-all.txt" \
        "${temp_dir}/superseding-and-superseded-revision-ids.txt" \
        > "${temp_dir}/ValidSupersededRevisionIds.txt"
    sort_in_place "${temp_dir}/ValidSupersededRevisionIds.txt"

    # *** Second step: Calculate superseded file ids ***
    #
    # Extract three connected fields from the same Update records:
    # - the parent bundle RevisionId from the field "BundledBy"
    # - the RevisionId of the update record itself
    # - the File-Id of the Payload File
    #
    # Note: WSUS Offline Update before version 10.7 did not
    # use GNU join and GNU sort (gsort.exe) to join the input
    # files. Compared to version 10.6.3, the field order of the file
    # BundledUpdateRevisionAndFileIds.txt was modified, so that the
    # bundle RevisionId is now the first field. Previous versions of
    # the Linux download scripts called this the "revised field order".
    #
    # TODO: There are some records with empty FileIds. Maybe the XSLT file
    # should scan for file ids rather than for parent bundle RevisionIds.
    log_info_message "Extracting file 4, bundle and update RevisionIds and FileIds..."
    "${xmlstarlet}" transform \
        ../xslt/extract-update-revision-and-file-ids.xsl \
        "${cache_dir}/package.xml" \
        > "${temp_dir}/BundledUpdateRevisionAndFileIds.txt"
    sort_in_place "${temp_dir}/BundledUpdateRevisionAndFileIds.txt"

    # In the standard method of calculating superseded updates, the
    # first fields of each table will be joined. For the revised method,
    # the file BundledUpdateRevisionAndFileIds.txt needs to be sorted by
    # the third field as well. The option --unique should not be used,
    # if only one field is sorted.
    sort -t ',' -k 3 "${temp_dir}/BundledUpdateRevisionAndFileIds.txt" \
        > "${temp_dir}/BundledUpdateRevisionAndFileIds3.txt"

    # Get superseded FileIds of the PayloadFiles. Since the superseded
    # bundle RevisionIds are verified, this join will also verify the
    # FileIds. This means: if there are bundle RevisionIds in the second
    # file, which don't really exist, they won't be matched by this join.

    # Input files:
    # File 1: ValidSupersededRevisionIds.txt
    # - Field 1: superseded bundle RevisionId (verified)
    # File 2: BundledUpdateRevisionAndFileIds.txt
    # - Field 1: parent bundle RevisionId
    # - Field 2: Update RevisionId (not really needed, but useful for
    #            debugging)
    # - Field 3: FileId
    #
    # Output file: superseded FileIds
    log_info_message "Joining files 3 and 4 to file 5, superseded FileIds..."
    join -t ',' -o 2.3 \
        "${temp_dir}/ValidSupersededRevisionIds.txt" \
        "${temp_dir}/BundledUpdateRevisionAndFileIds.txt" \
        > "${temp_dir}/SupersededFileIds.txt"
    sort_in_place "${temp_dir}/SupersededFileIds.txt"

    # *** Third step: Calculate superseded file locations (URLs) ***

    log_info_message "Extracting file 6, FileIds and Locations (URLs)..."
    "${xmlstarlet}" transform \
        ../xslt/extract-update-cab-exe-ids-and-locations.xsl \
        "${cache_dir}/package.xml" \
        > "${temp_dir}/UpdateCabExeIdsAndLocations.txt"
    sort_in_place "${temp_dir}/UpdateCabExeIdsAndLocations.txt"

    # Input files:
    # File 1: SupersededFileIds.txt
    # - Field 1: superseded FileId
    # File 2: UpdateCabExeIdsAndLocations.txt
    # - Field 1: FileId
    # - Field 2: File Location (URL)
    #
    # Output file: superseded File Locations (URLs)
    log_info_message "Joining files 5 and 6 to file 7, superseded File Locations (URLs)..."
    join -t ',' -o 2.2 \
        "${temp_dir}/SupersededFileIds.txt" \
        "${temp_dir}/UpdateCabExeIdsAndLocations.txt" \
        > "${temp_dir}/ExcludeList-superseded-all.txt"
    sort_in_place "${temp_dir}/ExcludeList-superseded-all.txt"

    # *** Apply ExcludeList-superseded-exclude.txt ***
    #
    # The file ExcludeList-superseded-exclude.txt contains kb numbers
    # of updates, which are marked as superseded by Microsoft, but which
    # should be downloaded and installed nonetheless. This file is used
    # for both "quality" update rollups and security-only updates.
    #
    # The file ExcludeList-superseded-exclude-seconly.txt was introduced
    # in WSUS Offline Update 10.9. It contains kb numbers of updates,
    # which are superseded by the full "quality" update rollups, but
    # not by the security-only updates.
    #
    # When the update rollups were introduced, full "quality"
    # update rollups superseded the security-only updates. Therefore,
    # security-only updates are also removed from the list of superseded
    # updates, if security-only updates are selected.
    excludelist_overrides=(
        ../exclude/ExcludeList-superseded-exclude.txt
        ../exclude/custom/ExcludeList-superseded-exclude.txt
    )

    shopt -s nullglob
    excludelist_overrides_seconly=(
        ../exclude/ExcludeList-superseded-exclude.txt
        ../exclude/ExcludeList-superseded-exclude-seconly.txt
        ../exclude/custom/ExcludeList-superseded-exclude.txt
        ../exclude/custom/ExcludeList-superseded-exclude-seconly.txt
        ../client/static/StaticUpdateIds-w62*-seconly.txt
        ../client/static/StaticUpdateIds-w63*-seconly.txt
        ../client/static/custom/StaticUpdateIds-w62*-seconly.txt
        ../client/static/custom/StaticUpdateIds-w63*-seconly.txt
    )
    shopt -u nullglob

    # The Linux download scripts, version 1.5 and later
    # create the files ExcludeList-Linux-superseded.txt and
    # ExcludeList-Linux-superseded-seconly.txt, because the sort order
    # of the intermediate files is not exactly the same as in Windows.
    apply_exclude_lists \
        "${temp_dir}/ExcludeList-superseded-all.txt" \
        "../exclude/ExcludeList-Linux-superseded.txt" \
        "${temp_dir}/ExcludeList-superseded-exclude.txt" \
        "${excludelist_overrides[@]}"
    sort_in_place "../exclude/ExcludeList-Linux-superseded.txt"

    apply_exclude_lists \
        "${temp_dir}/ExcludeList-superseded-all.txt" \
        "../exclude/ExcludeList-Linux-superseded-seconly.txt" \
        "${temp_dir}/ExcludeList-superseded-exclude-seconly.txt" \
        "${excludelist_overrides_seconly[@]}"
    sort_in_place "../exclude/ExcludeList-Linux-superseded-seconly.txt"

    # ========== Revised method for security-only updates =================

    log_info_message "Recalculate superseded updates for security-only updates, using a revised method..."

    # The file HideList-seconly.txt is used to hide the full "quality"
    # updates rollups from the Windows Update service during installation,
    # if security-only updates are selected. The first column contains
    # the kb numbers of the hidden updates.
    log_info_message "Create a list of hidden kb numbers..."
    for current_dir in ../client/exclude ../client/exclude/custom
    do
        if [[ -s "${current_dir}/HideList-seconly.txt" ]]
        then
            cat_dos "${current_dir}/HideList-seconly.txt" \
                | cut -d ',' -f 1 \
                >> "${temp_dir}/hidden-kb-numbers.txt"
        fi
    done

    if [[ -s "${temp_dir}/hidden-kb-numbers.txt" ]]; then

        # By searching the file UpdateCabExeIdsAndLocations.txt, the kb
        # numbers in the file HideList-seconly.txt can be traced back
        # to the File Locations (URLs) and the FileIds.
        log_info_message "Create a list of hidden FileIds and Locations..."
        grep -F -i -f "${temp_dir}/hidden-kb-numbers.txt" \
            "${temp_dir}/UpdateCabExeIdsAndLocations.txt" \
            > "${temp_dir}/hidden-file-ids-and-locations.txt" || true
        sort_in_place "${temp_dir}/hidden-file-ids-and-locations.txt"

        # Trace back from the hidden FileIds to the parent bundle
        # RevisionIds
        #
        # Input files:
        # File 1: hidden-file-ids-and-locations.txt
        # - Field 1: hidden FileId (sorted and joined field)
        # - Field 2: hidden File Location
        # File 2: BundledUpdateRevisionAndFileIds3.txt
        # - Field 1: bundle RevisionId (exported field)
        # - Field 2: Update RevisionId
        # - Field 3: FileId (sorted and joined field)
        #
        # Output file: hidden bundle RevisionIds
        log_info_message "Create a list of hidden bundle RevisionIds..."
        join -t ',' -1 '1' -2 '3' -o '2.1' \
            "${temp_dir}/hidden-file-ids-and-locations.txt" \
            "${temp_dir}/BundledUpdateRevisionAndFileIds3.txt" \
            > "${temp_dir}/bundle-revision-ids-hidden.txt"
        sort_in_place "${temp_dir}/bundle-revision-ids-hidden.txt"

        # The hidden bundle RevisionIds are removed from the list of
        # existing bundle RevisionIds. Thus, they will not be treated
        # as superseding anymore, when the list of superseded updates
        # is calculated.
        #
        # This "left join" is basically the calculation:
        #
        # all - hidden = valid bundle RevisionIds
        log_info_message "Remove the hidden bundle RevisionIds from the list of existing bundle RevisionIds..."
        join -t ',' -v1 \
            "${temp_dir}/bundle-revision-ids-all.txt" \
            "${temp_dir}/bundle-revision-ids-hidden.txt" \
            > "${temp_dir}/bundle-revision-ids-valid.txt"
        sort_in_place "${temp_dir}/bundle-revision-ids-valid.txt"

        # The remaining calculations are done as in the standard method
        # above. The XSLT transformations don't not need to be done
        # again, because the needed tables already exist. Joining and
        # sorting these tables is very fast. Therefore, the additional
        # calculations don't really impact the performance.

        # Step 1: Get valid superseded bundle RevisionIds by verifying,
        # that the superseding bundle RevisionIds actually exist
        #
        # Input files:
        # File 1: bundle-revision-ids-valid.txt
        # - Field 1: valid bundle RevisionIds = all existing bundle
        #            RevisionIds minus the hidden RevisionIds
        # File 2: superseding-and-superseded-revision-ids.txt
        # - Field 1: superseding bundle RevisionId
        # - Field 2: superseded bundle RevisionId (not verified)
        #
        # Output file: valid superseded bundle RevisionIds (revised)
        log_info_message "Build a list of valid superseded bundle RevisionIds (revised)..."
        join -t ',' -o 2.2 \
            "${temp_dir}/bundle-revision-ids-valid.txt" \
            "${temp_dir}/superseding-and-superseded-revision-ids.txt" \
            > "${temp_dir}/ValidSupersededRevisionIds-Revised.txt"
        sort_in_place "${temp_dir}/ValidSupersededRevisionIds-Revised.txt"

        # Step 2: Get superseded FileIds of the PayloadFiles
        #
        # Input files:
        # File 1: ValidSupersededRevisionIds-Revised.txt
        # - Field 1: valid superseded bundle RevisionId
        # File 2: BundledUpdateRevisionAndFileIds.txt
        # - Field 1: parent bundle RevisionId
        # - Field 2: update RevisionId (not really needed, but useful
        #            for debugging)
        # - Field 3: FileId
        #
        # Output file: superseded FileIds (revised)
        log_info_message "Build a list of superseded FileIds (revised)..."
        join -t ',' -o 2.3 \
            "${temp_dir}/ValidSupersededRevisionIds-Revised.txt" \
            "${temp_dir}/BundledUpdateRevisionAndFileIds.txt" \
            > "${temp_dir}/SupersededFileIds-Revised.txt"
        sort_in_place "${temp_dir}/SupersededFileIds-Revised.txt"

        # Step 3: Calculate superseded file locations (URLs)
        #
        # Input files:
        # File 1: SupersededFileIds-Revised.txt
        # - Field 1: FileId
        # File 2: UpdateCabExeIdsAndLocations.txt
        # - Field 1: FileId
        # - Field 2: File Location (URL)
        #
        # Output file: superseded File Locations (revised)
        log_info_message "Build a list of superseded File Locations (revised)..."
        join -t ',' -o 2.2 \
            "${temp_dir}/SupersededFileIds-Revised.txt" \
            "${temp_dir}/UpdateCabExeIdsAndLocations.txt" \
            > "${temp_dir}/ExcludeList-superseded-all-revised.txt"
        sort_in_place "${temp_dir}/ExcludeList-superseded-all-revised.txt"

        # Apply the exclude list overrides as defined above for the
        # standard method
        apply_exclude_lists \
            "${temp_dir}/ExcludeList-superseded-all-revised.txt" \
            "../exclude/ExcludeList-Linux-superseded-seconly-revised.txt" \
            "${temp_dir}/ExcludeList-superseded-exclude-seconly-revised.txt" \
            "${excludelist_overrides_seconly[@]}"
        sort_in_place "../exclude/ExcludeList-Linux-superseded-seconly-revised.txt"

    else
        # If there are no files to hide, then the revised method should
        # get the same results as the standard method.
        cp "../exclude/ExcludeList-Linux-superseded-seconly.txt" \
           "../exclude/ExcludeList-Linux-superseded-seconly-revised.txt"
    fi

    # ========== Postprocessing ===========================================

    # After recalculating superseded updates, all dynamic updates must
    # be recalculated as well.
    reevaluate_dynamic_updates

    # Test, that all three files were created
    for current_file in "../exclude/ExcludeList-Linux-superseded.txt" \
                        "../exclude/ExcludeList-Linux-superseded-seconly.txt" \
                        "../exclude/ExcludeList-Linux-superseded-seconly-revised.txt"
    do
        if ensure_non_empty_file "${current_file}"
        then
            log_info_message "Created file ${current_file}"
        else
            fail "File ${current_file} was not created"
        fi
    done

    return 0
}

# ========== Commands =====================================================

check_wsus_catalog_file
check_superseded_updates
echo ""
return 0
