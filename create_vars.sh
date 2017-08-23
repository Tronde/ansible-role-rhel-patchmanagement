#!/bin/bash
##############################################################################
# Variables ##################################################################
BASELINE='/data/jka_dev/rhel-patchmanagement/patch_baseline.txt'
ADVISORIES='/data/jka_dev/rhel-patchmanagement/new_advisories.txt'
CURRENT_PATCH_SET="/data/jka_dev/rhel-patchmanagement/patch_set_`date +%Y-%m-%d.txt`"
VARS='/data/jka_dev/rhel-patchmanagement/vars/main.yml'
MAIL_TEXT='/data/jka_dev/rhel-patchmanagement/mail_text.txt'
DATE1="Date1"
DATE2="Date2"
DATE3="Date3"
DATE4="Date4"

# Functions ##################################################################
get_advisories() {
  yum updateinfo list all 2>/dev/null | awk '/RHSA-[0-9]{4}:[0-9]{4}/ {print $(NF-2)}' | sort | uniq
}

create_patch_set() {
  if [ ! -f "${BASELINE}" ]
  then
    get_advisories >"${BASELINE}" 2>/dev/null
    cp "${BASELINE}" "${CURRENT_PATCH_SET}" 2>/dev/null
  else
    if [ -f ${ADVISORIES}" ] && [ -s ${ADVISORIES}" ]
    then
      mv "${ADVISORIES}" "${BASELINE}"
    fi
    get_advisories >"${ADVISORIES}"
    comm -13 "${BASELINE}" "${ADVISORIES}" >"${CURRENT_PATCH_SET}"
  fi
}

create_vars() {
  if [ -f "${VARS}" ]
  then
    mv "${VARS}" "${VARS}.bak_`date +%Y-%m-%d`"
  fi
  ADVISORY_LIST=""
  while read NAME
  do
    if [[ -z $ADVISORY_LIST ]]
    then
      ADVISORY_LIST="${NAME}"
    else
      ADVISORY_LIST="${ADVISORY_LIST},${NAME}"
    fi
  done < "${CURRENT_PATCH_SET}"

  cat >"${VARS}" <<EOF
---
  Set_`date +%Y_%m`: ${ADVISORY_LIST}
  ###################################################
  rhsa_to_install: "{{ Set_`date +%Y_%m` }}"
EOF
}

create_mail() {
  cat >"${MAIL_TEXT}" <<EOF
Hallo,
zu den unten genannten Stichtagen erfolgt die zentral gesteuerte Installation der folgenden Red Hat Advisories: ${ADVISORY_LIST}.

Informationen zu den genannten Advisory findet man unter der URL: https://access.redhat.com/downloads/content/69/ver=/rhel---7/7.3%20Beta/x86_64/product-errata

Die von den Advisory betroffenen Pakete werden nur dann aktualisiert, falls die Advisory nicht bereits vor dem jeweiligen Stichtag durch den Systembetreiber eingespielt wurden.
  
Es gelten folgende Stichtage fuer die Installation:

  * ${DATE1} Installation in der E-Stage
  * ${DATE2} Installation in der Q-Stage
  * ${DATE3} Installation in der P-Stage-1
  * ${DATE4} Installation in der P-Stage-2

Sollte die Installation der genannten Advisory erforderlich sein, werden die betroffenen Systeme nach der Installation automatisch neugestartet.
EOF
}

# Main #######################################################################
create_patch_set
create_vars
create_mail
