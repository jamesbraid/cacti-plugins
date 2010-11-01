#!/bin/bash
#
# bulk add switches to cacti
#

switches=$1
[ -z $switches ] && { echo "need a switch name as arg 1"; exit 1; }

cacti_path=/usr/share/cacti
add_graphs=${cacti_path}/cli/add_graphs.php
add_tree=${cacti_path}/cli/add_tree.php
add_device=${cacti_path}/cli/add_device.php

graph_template_id=2
query_id=1
query_type_id=14
snmp_field="ifName"

for switch in $switches; do

    hostid=`${add_device} --description=${switch} --ip=${switch} --template=1 --avail=snmp --version=2 --community=public | perl -ne '/\(([0-9]+)\)/ && print $1'`

#    hostid=`${add_graphs} --list-hosts | awk "\\$(NF) ~ /${switch}\\$/ {print \\$1}"`
    fields=`${add_graphs} --host-id=${hostid} --list-snmp-values --snmp-field=${snmp_field} | egrep -iv 'lo|vlan|known'`

    ${add_tree} --type=node --node-type=host --tree-id=12 --host-id=${hostid}

    for field in $fields; do
        ${add_graphs} --graph-type=ds --host-id=${hostid} --graph-template-id=${graph_template_id} --snmp-query-id=${query_id} --snmp-query-type-id=${query_type_id} --snmp-field=${snmp_field} --snmp-value=${field}
    done

done

