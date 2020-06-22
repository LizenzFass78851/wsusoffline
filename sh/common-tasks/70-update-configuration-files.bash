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
#     The update of configuration files is disabled, but some obsolete
#     files may still be deleted.

# ========== Functions ====================================================

function remove_obsolete_files ()
{
    # Dummy files are inserted, because zip archives cannot include
    # empty directories. They can be deleted on the first run.
    find .. -type f -name dummy.txt -delete

    return 0
}

# ========== Commands =====================================================

remove_obsolete_files

return 0 # for sourced files
