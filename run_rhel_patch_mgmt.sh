#!/bin/sh

DOM=`date +%d`
DOW=`date +%w`
LOG="/var/log/ansible/patch_run_`date +%Y-%m-%d`.log"
SETUP_LOG="/var/log/ansible/setup_patch_run_`date +%Y-%m-%d`.log"
SSH_KEY="PUT PATH TO PRIVATE KEY HERE"
PLAYBOOK="/path/to/patch_rhel.yml"
CREATEVARS="/path/to/ansible/roles/rhel-patchmanagement/create_vars.sh"

# Run Patch-Management ad-hoc in the specified stage
# Example: './run_rhel_patch_mgmt.sh NOW rhel-patch-phase1'
if [ "${1}" = "NOW" ] && [ -n "${2}" ]
then
  ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit="${2}" >> $LOG 2>&1
  exit
fi

if [ "${1}" = "NOW" ] && [ -z "${2}" ]
then
  echo "ERROR: Second argument is missing."
  echo "Example: './run_rhel_patch_mgmt.sh NOW rhel-patch-phase1'"
  exit
fi

# Setup the next patchcycle
if [ "$DOW" = "2" ] && [ "$DOM" -gt 0 ] && [ "$DOM" -lt 8 ]
then
    $CREATEVARS > $SETUP_LOG 2>&1
fi

# Patchcycle of the rhel-patch-phase1 on the second Tuesday of a month
if [ "$DOW" = "2" ] && [ "$DOM" -gt 7 ] && [ "$DOM" -lt 15 ]
then
    ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit=rhel-patch-phase1 > $LOG 2>&1
fi

# Patchcycle of the rhel-patch-phase2 on the third Tuesday of a month
if [ "$DOW" = "2" ] && [ "$DOM" -gt 14 ] && [ "$DOM" -lt 22 ]
then
    ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit=rhel-patch-phase2 > $LOG 2>&1
fi

# Patchcycle of the rhel-patch-phase3 on the fourth Tuesday of a month
if [ "$DOW" = "2" ] && [ "$DOM" -gt 21 ] && [ "$DOM" -lt 29 ]
then
    ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit=rhel-patch-phase3 > $LOG 2>&1
fi

# Patchcycle of the rhel-patch-phase4 on the fourth Wednesday of a month
if [ "$DOW" = "3" ] && [ "$DOM" -gt 21 ] && [ "$DOM" -lt 30 ]
then
    ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit=rhel-patch-phase4 > $LOG 2>&1
fi
