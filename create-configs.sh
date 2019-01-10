#!/bin/bash

# -----------------------------------------------------------------------------
# Copyright © 2018 AT&T USA
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# -----------------------------------------------------------------------------

#
# This script generates docker-compose volume overlay files from the oom
# kubernetes configuration files.  Multiple environments can be supported. By
# default the environment is the 'local' environment and the docker-compose 
# file is named docker-compose-local.yml.  This script only generates the
# overlay files, not the docker-compose file.
#
# Overlay files contain the springboot configuration for each SO container.
#
# The idea here is that docker-compose is lighter weight than kubernetes with
# rancher, and people will find it easier to use in a development environment.
# Whenever the overlay files in oom are modified, this script can be used to
# (re)build overlay files for the docker-compose environment.
#
# Reasonably up-to-date overlay files for the docker-compose environment may
# be checked into the docker-config repository as a convenience to those who
# don't want to (or can't) run this script.  This script will refresh those.
#
# Example Workflow:
#
# 1) build SO software and docker images -or- pull SO docker images from nexus3
#
# 2) Create configuration for 'local' environment:
#       ./create-configs.sh -e local -i -u rd472p -b master
#
# 3) Start the environment:
#       docker-compose -f docker-compose-local.yml up
#

function usage
{
	echo "usage: $(basename $0) [-e env] [-i] [-u oom-git-user] [-b oom-git-branch]"
	echo "where  -e specifies the environment name (default: 'local')"
	echo "       -i re-initializes the staging directory (default: no)"
	echo "       -u specifies the git user for cloning oom (default: current user)"
	echo "       -b specifies the oom branch (default: current docker-config branch)"
}

#
# Purpose: prompts for a yes/no (or equivalent) answer
# Output: none
# Return Code: 0 for yes, 1 for no
# Usage: askConfirm prompt
#
function askConfirm
{
	ask_prompt="$1"
	while :
	do
		echo -n "$ask_prompt" >> /dev/tty
		read ask_reply

		ask_reply=${ask_reply##+([[:space:]])};
		ask_reply=${ask_reply%%+([[:space:]])}

		case "$ask_reply" in
		y | yes | Y | YES)
			return 0
			;;
		n | no | N | NO)
			return 1
			;;
		esac
	done
}

#
# Purpose: performs a literal string replacement (no regexs)
# Output: none, but modifies the specified file
# Return Code: 0 for success, 1 for failure
# Usage: replace source replacement file
#
function replace
{
	local src=$1
	local rpl=$2
	local file=$3

	if ! type xxd > /dev/null 2>&1
	then
		echo "xxd: command not found" 1>&2
		return 1
	fi

	local xsrc=$(echo -n "$src" | xxd -p | tr -d '\n')
	local xrpl=$(echo -n "$rpl" | xxd -p | tr -d '\n')

	xxd -p $file | tr -d '\n' | sed "s/$xsrc/$xrpl/g" | xxd -p -r > $file.replace || return 1
	mv $file.replace $file || return 1
	return 0
}

#
# Purpose: converts a camel-case variable name to snake (upper) case
#          openStackUserName -> OPEN_STACK_USER_NAME
# Output: the converted variable name
# Usage: toSnake name
#
function toSnake
{
	echo "$1" | sed -r 's/([A-Z])/_\L\1/g' | sed 's/^_//' | tr '[a-z]' '[A-Z]'
}

#
# Purpose: lists all the environment variables in the specified docker
#          compose yaml for the specified container, e.g.:
#          VAR1=VALUE1
#          VAR2=VALUE2
#          ...
# Output: the list of variable mappings
# Usage: listEnv composeFile containerName
#
function listEnv
{
	local composeFile=$1
	local container=$2

	local inContainer=FALSE
	local inEnvironment=FALSE

	while read line
	do
		if [[ $line == "$container:" ]]
		then
			inContainer=TRUE
		elif [[ $inContainer == TRUE && $line == "environment:" ]]
		then
			inEnvironment=TRUE
		else
			if [[ $inEnvironment == TRUE ]]
			then
				if [[ ${line:0:1} == "-" ]]
				then
					echo "$line"
				else
					break
				fi
			fi
		fi
	done < $composeFile | sed -e "s/^- '//" -e "s/'$//"
}

#
# Purpose: tests if the specified environment variable is defined in the
#          docker compose yaml for the specified container.
# Output: none
# Return Code: 0 if the variable exists, 1 if it doesn't
# Usage: varExists composeFile containerName variableName
#
function varExists
{
	local composeFile=$1
	local container=$2
	local var=$3

	listEnv $composeFile $container | grep "^$var=" > /dev/null
	return $?
}

#
# Purpose: returns the value of the specified environment variable
#          from the compose yaml for the specified container.
# Output: the variable value (empty if it isn't defined)
# Usage: varValue composeFile containerName variableName
#
function varValue
{
	local composeFile=$1
	local container=$2
	local var=$3

	listEnv $composeFile $container | grep "^$var=" | cut -d= -f2
}

### MAIN CODE STARTS HERE

if [[ ! -d volumes/so ]]
then
	echo "You must run this command in the docker-config directory" 1>&2
	exit 1
fi

ENV=local
INIT=FALSE
GITUSER=$(id -un)
GITBRANCH=$(git rev-parse --abbrev-ref HEAD)

while getopts :e:iu:b: c
do
	case "$c" in
	e)
		ENV=$OPTARG
		;;
	i)
		INIT=TRUE
		;;
	u)
		GITUSER=$OPTARG
		;;
	b)
		GITBRANCH=$OPTARG
		;;
	*)
		usage 1>&2
		exit 1
		;;
	esac
done

shift $(($OPTIND - 1))

if [[ $# != 0 ]]
then
	usage 1>&2
	exit 1
fi

if [[ ! -f docker-compose-$ENV.yml ]]
then
	echo "No such file: docker-compose-$ENV.yml" 1>&2
	exit 1
fi

mkdir -p staging

if [[ -d staging && $INIT == TRUE ]]
then
	if ! askConfirm "Delete existing staging directory? "
	then
		exit 1
	fi

	rm -fr staging || exit 1
fi

mkdir -p staging || exit 1

# Get the oom repository from gerrit.

if [[ -d staging/oom ]]
then
	cd staging/oom || exit 1

	branch=$(git rev-parse --abbrev-ref HEAD)

	if [[ $branch != $GITBRANCH ]]
	then
		echo "staging/oom is not on branch '$GITBRANCH'" 1>&2
		exit 1
	fi

	cd ../.. || exit 1
else
	cd staging || exit 1
	echo "Cloning into staging/oom"
	git clone https://$GITUSER@gerrit.onap.org/r/a/oom || exit 1
	cd oom || exit 1

	branch=$(git rev-parse --abbrev-ref HEAD)

	if [[ $branch != $GITBRANCH ]]
	then
		if [[ $(git ls-remote origin $GITBRANCH | wc -l) == 0 ]]
		then
			echo "staging/oom has no '$GITBRANCH' branch" 1>&2
			exit 1
		fi

		echo "Switching staging/oom to '$GITBRANCH' branch"
		git checkout -b $GITBRANCH remotes/origin/$GITBRANCH || exit 1
	fi

	cd ../.. || exit 1
fi

kso=staging/oom/kubernetes/so

if [[ ! -d $kso ]]
then
	echo "No such directory: $kso" 1>&2
	exit 1
fi

if [[ ! -d staging/volumes/so/config ]]
then
	mkdir -p staging/volumes/so/config
fi

stagedTargets=

for override in $(cd $kso && find * -name 'override.yaml')
do
	subdir=${override%%/*}

	if [[ $subdir == resources ]]
	then
		container=so-api-handler-infra
	elif [[ $subdir == charts ]]
	then
		container=${override#charts/}
		container=${container%%/*}
	fi

	if [[ $container != so-monitoring ]]
	then
		container=${container#so-}
	fi

	target=staging/volumes/so/config/$container/$ENV/override.yaml

	if [[ ! -f $target ]]
	then
		mkdir -p $(dirname $target) || exit 1
		cp $kso/$override $target.tmp || exit 1

		if ! varExists docker-compose-$ENV.yml $container COMMON_NAMESPACE
		then
			echo "ERROR: no COMMON_NAMESPACE variable is defined in docker-compose-$ENV.yml for container $container" 1>&2
			exit 1
		fi

		replace '{{ include "common.namespace" . }}' '${COMMON_NAMESPACE}' $target.tmp || exit 1

		if ! varExists docker-compose-$ENV.yml $container CONTAINER_PORT
		then
			echo "ERROR: no CONTAINER_PORT variable is defined in docker-compose-$ENV.yml for container $container" 1>&2
			exit 1
		fi

		replace '{{ index .Values.containerPort }}' '${CONTAINER_PORT}' $target.tmp || exit 1

		for configValue in $(grep "{{ \.Values\.config\..*}}" $target.tmp | cut -d'{' -f3 | cut -d'}' -f1 | tr -d ' ' | sed 's/.Values.config.//' | sort -u)
		do
			var=$(toSnake $configValue)

			if ! varExists docker-compose-$ENV.yml $container $var
			then
				echo "ERROR: no $var variable is defined in docker-compose-$ENV.yml for container $container" 1>&2
				exit 1
			fi

			if [[ ${var:0:11} == "OPEN_STACK_" ]]
			then
				# Workaround for variables in the openstack
				# adapter cloud configuration. The override
				# yaml is read by a migration program that
				# doesn't expand variables, so we need to
				# substitute the variable values here.

				value=$(varValue docker-compose-$ENV.yml $container $var)
				replace "{{ .Values.config.$configValue }}" "$value" $target.tmp || exit 1
			else
				replace "{{ .Values.config.$configValue }}" '${'$var'}' $target.tmp || exit 1
			fi
		done

		if grep "{{" $target.tmp > /dev/null
		then
			echo "ERROR: Unresolved placeholders in $kso/$override:" 1>&2
			grep "{{.*}}" $target.tmp | cut -d'{' -f3 | cut -d'}' -f1 | sed -e 's/^/    {{/' -e 's/$/}}/' | sort -u 1>&2
			exit 1
		fi

		mv $target.tmp $target || exit 1
		echo "Created $target"

		stagedTargets="$stagedTargets target"
	fi
done

for override in $(cd staging && find volumes -name 'override.yaml')
do
	dir=$(dirname $override)
	mkdir -p $dir || exit 1
	cp staging/$override $override || exit 1
	echo "Installed $override" 
done

echo "SUCCESS"
