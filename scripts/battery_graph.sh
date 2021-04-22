#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

charge_color_map=(d70000 ff5f00 ff8700 ffaf00 ffd700 ffff00 d7ff00 afff00 87ff00 5fff00 )
charge_icon_val=""

generate_charge_icon ()
{
	local charge_util_full="◼"
	local charge_util_inuse="◻"
	local charge_util_empty="-"
	local charge_icon_param=$1

	if [[ ${charge_icon_param}"" == "" ]]; then
		charge_icon_param=0
	fi
	charge_icon_val=""

	icon_count=0;
	while [[ ${icon_count} -le 9 ]]; do
		charge_icon_val=${charge_icon_val}"#[fg=#${charge_color_map[$icon_count]}]"
		if [[ ${icon_count} -lt $charge_icon_param ]]; then
			charge_icon_val=${charge_icon_val}${charge_util_full}
		elif [[ ${icon_count} -eq $charge_icon_param ]]; then
			charge_icon_val=${charge_icon_val}${charge_util_inuse}
		else
			charge_icon_val=${charge_icon_val}${charge_util_empty}
		fi
		icon_count=$((icon_count + 1))
	done

	charge_icon_val=${charge_icon_val}"#[fg=#${charge_color_map[$charge_icon_param]}]"
}	# ----------  end of function generate_charge_icon  ----------

charged_icon="❇ "
charging_icon="⚡️"
attached_icon="|!!|"


print_graph() {
	graph_param=$1

	local status=$(battery_status)
	if [[ $status =~ (charged) ]]; then
		printf "$charged_icon"
	elif [[ $status =~ (^charging) ]]; then
		printf "$charging_icon"
	elif [[ $status =~ (attached) ]]; then
		printf "$attached_icon"
	fi

	charge_icon_param=$((${graph_param}/10))
	printf "#[fg=#${charge_color_map[$charge_icon_param]}]"
	if [ -z "$1" ]; then
		printf ""
	elif [ "$1" -lt "20" ]; then
		printf "▁"
	elif [ "$1" -lt "40" ]; then
		printf "▂"
	elif [ "$1" -lt "60" ]; then
		printf "▃"
	elif [ "$1" -lt "80" ]; then
		printf "▅"
	else
		printf "▇"
	fi
}

main() {
	local percentage=$($CURRENT_DIR/battery_percentage.sh)
	percentage=${percentage%\%*}
	if [[ $percentage"" == "" ]]; then
		percentage=0
	elif [[ $percentage -gt 100 ]]; then
		percentage=0
	elif [[ $percentage -lt 0 ]]; then
		percentage=0
	fi
	print_graph ${percentage}
}
main
