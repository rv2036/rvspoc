#!/usr/bin/env python3
#

import re


with open('/Users/ryan/read_only.txt', 'r') as file:
    lengths = {}
    packets_count = 0

    for line in file:
        if re.match(r'^\|0\s', line):
            packet = line.split('|')
            packet = packet[2:-1]
            l = len(packet)
            if l not in lengths:
                lengths[l] = 1
            else:
                lengths[l] = lengths[l] + 1
            packets_count = packets_count + 1

    print(f"Total packets: {packets_count}")
    print(f"All packets' lengths: {lengths}")

    print()
    for key, value in lengths.items():
        if value >= packets_count * 0.02:
            percent = round(value / packets_count, 4)
            print(f"length: {key}, counts: {value}, percent: {percent}")
