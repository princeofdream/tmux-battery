#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

# script global variables
charged_icon=""
charging_icon=""
attached_icon=""
# discharging_icon=""
full_charge_icon=""
high_charge_icon=""
medium_charge_icon=""
low_charge_icon=""

charged_default="❇ "
charged_default_osx="🔋 "
charging_default="⚡️"
# charging_default="|..|"
# attached_default="⚠️ "
attached_default="|!!|"
full_charge_icon_default="◼◼◼◼◼◼◼◼◼◼"
high_charge_icon_default="◼◼◼◼◼◼◼◻◻◻"
medium_charge_icon_default="◼◼◼◼◼◻◻◻◻◻"
low_charge_icon_default="◼◻◻◻◻◻◻◻◻◻"

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


charged_default() {
	if is_osx; then
		echo "$charged_default_osx"
	else
		echo "$charged_default"
	fi
}

# icons are set as script global variables
get_icon_settings() {
	charged_icon=$(get_tmux_option "@batt_charged_icon" "$(charged_default)")
	charging_icon=$(get_tmux_option "@batt_charging_icon" "$charging_default")
	attached_icon=$(get_tmux_option "@batt_attached_icon" "$attached_default")
	full_charge_icon=$(get_tmux_option "@batt_full_charge_icon" "$full_charge_icon_default")
	high_charge_icon=$(get_tmux_option "@batt_high_charge_icon" "$high_charge_icon_default")
	medium_charge_icon=$(get_tmux_option "@batt_medium_charge_icon" "$medium_charge_icon_default")
	low_charge_icon=$(get_tmux_option "@batt_low_charge_icon" "$low_charge_icon_default")
}

print_icon() {
	local status=$1
	percentage=$($CURRENT_DIR/battery_percentage.sh | sed -e 's/%//')
	if [[ $status =~ (charged) ]]; then
		generate_charge_icon $((percentage/10))
		printf "$charged_icon"
		printf "${charge_icon_val}"
	elif [[ $status =~ (^charging) ]]; then
		generate_charge_icon $((percentage/10))
		printf "#[fg=#eeee00]$charging_icon"
		printf "${charge_icon_val}"
	elif [[ $status =~ (^discharging) ]]; then
        # use code from the bg color
        if [ $percentage -eq 100 ]; then
			generate_charge_icon $((percentage/10))
            printf "$full_charge_icon"
			printf "${charge_icon_val}"
        elif [ $percentage -le 99 -a $percentage -ge 0 ];then
            # printf "$charge_90s_icon_default"
			generate_charge_icon $((percentage/10))
			printf "${charge_icon_val}"
            # printf "$charge_40s_icon_default"
        elif [ "$percentage" == "" ];then
            printf "$full_charge_icon_default"  # assume it's a desktop
        else
			generate_charge_icon $((percentage/10))
            printf "$low_charge_icon"
			printf "${charge_icon_val}"
        fi
	elif [[ $status =~ (attached) ]]; then
		printf "$attached_icon"
	fi
}

main() {
	get_icon_settings
	local status=$(battery_status)
	print_icon "$status"
}
main
