#!/bin/bash

#####################################################
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
#
#####################################################


#####################################################
#
# Simple and dirty script for pulling existent git repos
#
# Author: solacol
# Version: 0.1_20180414
#
#####################################################
#
#
# TODO:
#   - ls is not the best way to get the repos
#
###



REPOSITORIES='/srv/github'

IFS=$'\n'

LS="$(/usr/bin/which ls)"
DATE="$(/usr/bin/which date)"
ECHO="$(/usr/bin/which echo)"
GIT="$(/usr/bin/which git)"
MOUNT="$(/usr/bin/which mount)"
GREP="$(/usr/bin/which grep)"
CHMOD="$(/usr/bin/which chmod)"
CHOWN="$(/usr/bin/which chown)"
FIND="$(/usr/bin/which find)"

DATE="$(${DATE})"

DEFAULT_USER='userXXX'
DEFAULT_GROUP='groupXXX'

# Check if dir is existent
if [[ -d "${REPOSITORIES}" ]]; then
    # Pull for each repo found if .git folder is present
    for REPO in `${LS} "${REPOSITORIES}/"`; do
        if [[ -d "${REPOSITORIES}/${REPO}" ]]; then
            ${ECHO} "${DATE} ${REPOSITORIES}/${REPO} ..."

            if [[ -d "${REPOSITORIES}/${REPO}/.git" ]]; then
                cd "${REPOSITORIES}/${REPO}"
                ${ECHO} "... pulling"
                ${GIT} reset --hard
                ${GIT} pull
                ${ECHO} "... done"
            else
                ${ECHO} "No .git folder found ... skipping ..."
            fi

            ${ECHO}
        fi

        # Just a random sleep
        sleep $[(${RANDOM}%10)+1]s
    done

    # Set permissions quick and dirty ... can be skipped, but is nice if providing content with sftp or so
    ${FIND} ${REPOSITORIES} -type f -not -perm 640 -a -not -path "*/lost\+found*" -exec ${CHMOD} 640 {} \;
    ${FIND} ${REPOSITORIES} -type d -not -perm 750 -a -not -path "*/lost\+found*" -exec ${CHMOD} 750 {} \;
    ${FIND} ${REPOSITORIES} -not -group ${DEFAULT_GROUP} -a -not -path "*/lost\+found*" -exec ${CHOWN} ${DEFAULT_USER}:${DEFAULT_GROUP} {} \;
    ${FIND} ${REPOSITORIES} -not -user ${DEFAULT_USER} -a -not -path "*/lost\+found*" -exec ${CHOWN} ${DEFAULT_USER}:${DEFAULT_GROUP} {} \;
else
    ${ECHO} "Directory ${REPOSITORIES} seems not to be existent?!"
fi
