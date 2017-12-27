#!/usr/bin/env bash
function amas_refresh {
	root=${1}
	pre_message="#amas refresh autogenerated begin /${root}"
	post_message="#amas refresh autogenerate end /${root}"
	git_ignore="${pre_message}"
	git_ignore="${git_ignore}"$'\n'".gitignore"
	find "${root}" -type f | grep "\-ama$" | sed "s/\(^.*\)-ama$/\1/" | {
		while read ama; do
			git_ignore="${git_ignore}"$'\n'"${ama#${root}}"
			if [ ! -f "${ama}" ]; then
				echo "/${root}: diving ${ama}..."
				cat "${ama}-ama" | ama > "${ama}"
			else
				echo "/${root}: cached ${ama}"
			fi
		done;
		git_ignore="${git_ignore}"$'\n'"${post_message}"

		echo "/${root}: writing gitignore..."
		_git_ignore=$(cat "${1}"/.gitignore 2> /dev/null)
		start_marks=$(echo "${_git_ignore}" | grep -n "${pre_message}" | sed 's/\(.*\):.*/\1/g')
		end_marks=$(echo "${_git_ignore}" | grep -n "${post_message}" | sed 's/\(.*\):.*/\1/g')
		region_start="$( echo "${start_marks}" | head -1 )"
		region_end="$end_marks"
		while [ ! -z "${region_start}" ] && [ ! -z "${region_end}" ] && [ "$( echo "${region_end}" | head -1 )" -lt "${region_start}" ]; do
			#echo "iterate: ${region_start} ${region_end}"
			region_end="$( echo "${region_end}" | tail -n +2 )"
		done;
		region_end="$( echo "${region_end}" | head -1 )"
		
		#echo; echo "region_start: ${region_start}"; echo "region_end: ${region_end}"
		if [ -z "${region_start}" ] || [ -z "${region_end}" ]; then
			#echo "append"
			if [ ! -z "${_git_ignore}" ]; then
				git_ignore=$(cat <(echo "${_git_ignore}") <(echo "${git_ignore}"))
			fi;
		else
			#echo "replace ${region_start} to ${region_end}"
			git_ignore=$(cat <(echo "${_git_ignore}" | head -n $((region_start-1))) <(echo "${git_ignore}") <(echo "${_git_ignore}" | tail -n +$((region_end+1))))
		fi;
		echo "${git_ignore}" > "${1}"/.gitignore
	}
}







