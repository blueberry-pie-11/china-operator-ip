#!/usr/bin/env bash

set -e
source common.sh
[[ $SKIP_DATA_PREPARATION != true ]] && prepare_data
mkdir -p result
for file in operator/*.conf; do
	operator=${file%.*}
	operator=${operator##*/}
	log_info "generating IP list of $operator ..."
	get_asn $file
	(
	    raw_result=$(mktemp)
		get_asn $file | xargs bgptools -b rib.txt > ${raw_result}
		cidr-merger -s < ${raw_result} | grep -Fv : | cat > result/${operator}.txt
		grep -v '^::/0$' < ${raw_result} | cidr-merger -s | grep -F  : | cat > result/${operator}6.txt
		rm -f "${raw_result}"
	) &
done

wait_exit
