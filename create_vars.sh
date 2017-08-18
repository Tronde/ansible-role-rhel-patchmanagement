#!/bin/bash
# Requirements ###############################################################
# - tee from coreutils
##############################################################################
# Variables ##################################################################
BASELINE='/data/jka_dev/patch_baseline.txt'
ADVISORIES='/data/jka_dev/new_advisories.txt'
CURRENT_PATCH_SET="/data/jka_dev/patch_set_`date +%Y-%m-%d.txt`"
VARS='/data/jka_dev/rhel-patchmanagement/vars/main.yml'
MAIL_TEXT='/data/jka_dev/mail_text.txt'
DATE1=""
DATE2=""
DATE3=""
DATE4=""

# Functions ##################################################################
get_advisories() {
  yum updateinfo list all | grep RHSA | sed 's/^i//g' | sed 's/^\s//g' | cut -d' ' -f1 | sort | uniq
}

create_patch_set() {
  if [ ! -f "${BASELINE}" ]
  then
    get_advisories | tee "${BASELINE}" "${CURRENT_PATCH_SET}"
  else
    if [ -f ${ADVISORIES}" ] && [ -s ${ADVISORIES}" ]
    then
      mv "${ADVISORIES}" "${BASELINE}"
    fi
    get_advisories >"${ADVISORIES}"
    diff "${BASELINE}" "${ADVISORIES}" | grep RHSA | sed 's/^>//g' | sed 's/^\s*//g' >"${CURRENT_PATCH_SET}"
  fi
}

create_vars() {
  ADVISORY_LIST=""
  while read NAME
  do
    if [[ -z $ADVISORY_LIST ]]
    then
      $ADVISORY_LIST="${NAME}"
    else
      $ADVISORY_LIST="${ADVISORY_LIST},${NAME}"
    fi
  done < "${CURRENT_PATCH_SET}"

  echo "---" >"${VARS}"
  echo "  Set_`date +%Y_%m`: ${ADVISORY_LIST}" >>"${VARS}"
  echo "  ###################################################" >>"${VARS}"
  echo "  rhsa_to_install: \"{{ Set_`date +%Y_%m` }}\"" >>"${VARS}"
}

create_mail() {
  echo "Hallo," >"${MAIL_TEXT}"
  echo "zu den unten genannten Stichtagen erfolgt die zentral gesteuerte Installation der folgenden Red Hat Advisories: ${ADVISORY_LIST}." >>"${MAIL_TEXT}"
  echo "" >>"${MAIL_TEXT}"
  echo "Informationen zu den genannten Advisory findet man unter der URL: https://access.redhat.com/downloads/content/69/ver=/rhel---7/7.3%20Beta/x86_64/product-errata" >>"${MAIL_TEXT}"
  echo "" >>"${MAIL_TEXT}"
  echo "Die von den Advisory betroffenen Pakete werden nur dann aktualisiert, falls die Advisory nicht bereits vor dem jeweiligen Stichtag durch den Systembetreiber eingespielt wurden." >>"${MAIL_TEXT}"
  echo "" >>"${MAIL_TEXT}"
  echo "Es gelten folgende Stichtage fuer die Installation:" >>"${MAIL_TEXT}"
  echo "" >>"${MAIL_TEXT}"
  echo "  * ${DATE1} Installation in der E-Stage" >>"${MAIL_TEXT}"
  echo "  * ${DATE2} Installation in der Q-Stage" >>"${MAIL_TEXT}"
  echo "  * ${DATE3} Installation in der P-Stage-1" >>"${MAIL_TEXT}"
  echo "  * ${DATE4} Installation in der P-Stage-2" >>"${MAIL_TEXT}"
  echo "" >>"${MAIL_TEXT}"
  echo "Sollte die Installation der genannten Advisory erforderlich sein, werden die betroffenen Systeme nach der Installation automatisch neugestartet." >>"${MAIL_TEXT}"
}

# Main #######################################################################
if [ ! yum list installed coreutils ] >/dev/null 2>&1
then
  echo "ERROR: Package 'coreutils' needs to be installed."
  exit 1
fi
get_advisories
create_vars
create_mail
