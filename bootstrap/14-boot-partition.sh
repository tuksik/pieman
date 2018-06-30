#!/bin/bash
# Copyright (C) 2017 Evgeny Golyshev <eugulixes@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# The script must be run only after 11-pm.sh and 12-kernel.sh because it
# requires some of the files which are available only after installation all
# of the specified packages, including the kernel package.

check_if_variable_is_set SOURCE_DIR

# Get the files, which must present on the boot partition, from different
# sources and put them in the directory specified via BOOT.
boot="`get_attr ${OS} boot`"
for f in ${boot}; do
    # Split the name of the target file or directory into two parts:
    # original name and copy name.
    FILE_NAMES=($(echo "${f//->/$'\n'}"))
    source_file=""

    if [ ! -z `echo ${f} | egrep "^https://|^http://|^ftp://"` ]; then
        info "downloading ${FILE_NAMES[0]} to ${BOOT}"
        source_file="${BOOT}/$(basename "${FILE_NAMES[0]}")"
        wget -q -O "${source_file}" "${FILE_NAMES[0]}"
    elif [[ ${f:0:1} == "/" ]]; then
        info "copying ${R}${FILE_NAMES[0]} to ${BOOT}"
        cp -r "${R}"${FILE_NAMES[0]} "${BOOT}"
        source_file="${BOOT}/${FILE_NAMES[0]}"
    else
        info "copying `dirname ${YML_FILE}`/${f} to ${BOOT}"
        cp "${SOURCE_DIR}/${FILE_NAMES[0]}" "${BOOT}"
        source_file="${BOOT}/${FILE_NAMES[0]}"
    fi

    if [ ! -z "${FILE_NAMES[1]}" ]; then
        info "renaming ${source_file} into ${FILE_NAMES[1]}"
        dir="$(dirname "${FILE_NAMES[1]}")"
        if [ ! -z "${dir}" ]; then
            mkdir -p "${BOOT}/${dir}"
        fi

        mv "${source_file}" "${BOOT}/${FILE_NAMES[1]}"
    fi
done
