#!/bin/sh
# author Jan Van den Audenaerde
# date 2021-10-12
#
# usage: 
#       fw_reject_schedule [sterre|mirko|jan|playstation] [enable|disable]
#       fw_reject_schedule status

rule_sterre_workdays="iprange_sterre_reject_during_workdays"
rule_sterre_weekend="iprange_sterre_reject_during_weekend"
rule_mirko_workdays="iprange_mirko_and_co_reject_during_workdays"
rule_mirko_weekend="iprange_mirko_and_co_reject_during_weekend"
rule_jan="iphone_jan_reject_test_schedule"
rule_playstation="playstation_reject"
rule_not_applicable="not applicable"

enable="not defined"
if [ $# -eq 1 ]; then
   if [ $1 != "status" ]; then
      echo "ERROR: if only 1 parameter specified then it must be \"status\"!" >&2
      exit 1
   fi
elif [ $# -ne 2 ]; then
    echo "ERROR: you must specify 1 or 2 parameters !" >&2
    exit 1
else
  # check first parameter
  if [ "$1" = "sterre" ]; then
    rule1=$rule_sterre_workdays
    rule2=$rule_sterre_weekend
  elif [ "$1" = "mirko" ]; then
    rule1=$rule_mirko_workdays
    rule2=$rule_mirko_weekend 
  elif [ "$1" = "jan" ]; then
    rule1=$rule_jan
    rule2=$rule_not_applicable
  elif [ "$1" = "playstation" ]; then
    rule1=$rule_playstation
    rule2=$rule_not_applicable
  else
    echo "ERROR: parameter 1 must be status, mirko, sterre, jan or playstation" >&2
    exit 1
  fi

  # check 2nd parameter
  if [ "$2" = "enable" ]; then
     enable=1
  elif [ "$2" = "disable" ]; then
     enable=0
  else
     echo "ERROR: 2nd parameter must be enable or disable " >&2
    exit 1
  fi
fi

# function saves the firewall rule index in $rule_idx
# for the rule with name specified as first parameter
rule_idx="becomes set by below function"
set_rule_idx_for_rule_with_name()
{
  if [ "$#" -ne 1 ]; then
    echo "ERROR: set_rule_idx_for_rule_with_name() requires exactly one parameter !" >&2
    exit 1
  fi
  index=0
  rule_idx="undefined"
  while true; do
          name=$(uci get firewall.@rule[$index].name 2>/dev/null) || break
          echo "$name"| (grep -q "$1") && {
              rule_idx=$index
              break
          }
          index=$((index+1))
  done

  if [ "$rule_idx" = "undefined" ]; then                         
    echo "ERROR: set_rule_idx_for_rule_with_name() couldn't find firewall rule with name:$1" >&2
  fi
}

# function sets the enabled flag to 2nd parameter
# for the firewall rule with index specified by 1st parameter
set_fw_rule_enabled()
{
  if [ "$#" -ne 2 ]; then
    echo "ERROR: set_fw_rule_enabled() requires exactly two parameters !" >&2
    exit 1
  fi
  if [ "$2" != "0" ] && [ "$2" != "1" ]; then
    echo "ERROR: set_fw_rule_enabled() 2nd parameter must be 0 or 1 for function set_fw_rule_enabled()!" >&2
    exit 1
  fi
  set_rule_idx_for_rule_with_name $1
  if [ "$rule_idx" != "undefined" ]; then
    echo "set enabled=$2 for firewall rule $rule_idx (name=$1)"
    uci set firewall.@rule[$rule_idx].enabled=$2
  fi
}

get_fw_rule_status()
{
  if [ "$#" -ne 1 ]; then
    echo "ERROR: get_fw_rule_status() requires exactly one parameter !" >&2
    exit 1
  fi
  set_rule_idx_for_rule_with_name $1
  if [ "$rule_idx" != "undefined" ]; then
    status=$(uci get firewall.@rule[$rule_idx].enabled)
    if [ "$status" = "0" ]; then
       status_txt="IS DISABLED !"
    elif [ "$status" = "1" ]; then
       status_txt="is enabled";
    else
       status_txt="HAS UNKNOWN STATUS (enabled=$status)";
    fi

    echo "rule[$rule_idx]=$1 => $status_txt"
  fi
}

if [ "$1" = "status" ]; then
   get_fw_rule_status $rule_sterre_workdays
   get_fw_rule_status $rule_sterre_weekend
   get_fw_rule_status $rule_mirko_workdays
   get_fw_rule_status $rule_mirko_weekend
   get_fw_rule_status $rule_jan
   get_fw_rule_status $rule_playstation
else
   set_fw_rule_enabled $rule1 $enable
   if [ "$rule2" != "$rule_not_applicable" ]; then
     set_fw_rule_enabled $rule2 $enable
   fi
   uci commit                                                            
   /etc/init.d/firewall restart
fi
