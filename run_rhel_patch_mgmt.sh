#!/bin/sh

DOM=`date +%d`
DOW=`date +%w`
LOG="/var/log/ansible/patch_run_`date +%Y-%m-%d`.log"
SSH_KEY="PUT PATH TO PRIVATE KEY HERE"
PLAYBOOK="/path/to/patch_rhel.yml"

# Run Patch-Management ad-hoc in the specified stage
# Example: './run_rhel_patch_mgmt.sh NOW t-stage'
if [ "${1}" = "NOW" ] && [ -n "${2}" ]
then
  ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit="${2}" >> $LOG 2>&1
  exit
fi

if [ "${1}" = "NOW" ] && [ -z "${2}" ]
then
  echo "ERROR: Second argument is missing."
  echo "Example: './run_rhel_patch_mgmt.sh NOW t-stage'"
  exit
fi

# Patchcycle of the T-Stage on the second Tuesday of a month
if [ "$DOW" = "2" ] && [ "$DOM" -gt 7 ] && [ "$DOM" -lt 15 ]
then
    ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit=t-stage > $LOG 2>&1
fi

# Patchcycle of the Q-Stage on the third Tuesday of a month
if [ "$DOW" = "2" ] && [ "$DOM" -gt 14 ] && [ "$DOM" -lt 22 ]
then
    ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit=q-stage >> $LOG 2>&1
fi

# Patchcycle of the P-Stage-1 on the fourth Tuesday of a month
if [ "$DOW" = "2" ] && [ "$DOM" -gt 21 ] && [ "$DOM" -lt 29 ]
then
    ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit=p-stage1 > $LOG 2>&1
fi

# Patchcycle of the P-Stage-2 on the fourth Wednesday of a month
if [ "$DOW" = "3" ] && [ "$DOM" -gt 21 ] && [ "$DOM" -lt 30 ]
then
    ansible-playbook $PLAYBOOK --private-key=$SSH_KEY --limit=p-stage2 > $LOG 2>&1
fi
