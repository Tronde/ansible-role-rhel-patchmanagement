#!/usr/bin/python
# -*- encoding: utf-8 -*-
#
# Beschreibung:
# Dieses Skript gibt die Gruppen für das RHEL-Patchmanagement und
# die darin enthaltenen Hosts aus.

with open('/data/ansible/hosts', 'rt') as inventory:
  on_block = False
  for line in inventory.readlines():
    if line.startswith("## Gruppen fuer RHEL-Patchmanagement"):
      on_block = not on_block
    elif on_block:
      print(line.strip())
