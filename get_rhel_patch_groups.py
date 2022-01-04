#!/usr/bin/python
# -*- encoding: utf-8 -*-
#
# Description:
# This script prints the RHEL-Patch-Phases and the hosts within them
# from the inventory file and prints them to STDOUT.
from variables import ANSIBLE_INVENTORY
with open(ANSIBLE_INVENTORY, 'rt') as inventory:
  on_block = False
  for line in inventory.readlines():
    if line.startswith("## Gruppen fuer RHEL-Patchmanagement"):
      on_block = not on_block
    elif on_block:
      print(line.strip())
