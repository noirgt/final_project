#!/usr/bin/python3
import json
import os
import sys

yc_instance_table = os.popen("~/yandex-cloud/bin/yc compute instance list").read().strip().split("\n")[3:-1]
yc_instance_map = {
    "all": {"vars": {"all_cloud_instances": {}}}
}

for yc_instance in yc_instance_table:
    yc_instance_list = yc_instance.split(" | ")
    group = yc_instance_list[1].split("-")[-1].strip()
    hostname = yc_instance_list[1].strip()
    address = yc_instance_list[4].strip()

    if not yc_instance_map.get(group, False):
        yc_instance_map[group] = {"hosts": []}

    yc_instance_map[group]["hosts"].append(address)
    yc_instance_map["all"]["vars"]["all_cloud_instances"][hostname] = address


json_yc_instance_map = json.dumps(yc_instance_map)

print(json_yc_instance_map)
