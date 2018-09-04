#!/bin/bash
##############################################################################

source /absolute/path/to/variables.txt

# Functions ##################################################################
get_advisories() {
  yum updateinfo list all 2>/dev/null | awk '/RHSA-[0-9]{4}:[0-9]{4}/ {print $(NF-2)}' | sort -u
}

create_patch_set() {
  if [ ! -f "${BASELINE}" ]
  then
    get_advisories >"${BASELINE}" 2>/dev/null
    cp "${BASELINE}" "${CURRENT_PATCH_SET}" 2>/dev/null
  else
    if [ -f "${ADVISORIES}" ] && [ -s "${ADVISORIES}" ]
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
zu den unten genannten Stichtagen erfolgt die zentral gesteuerte Installation der Red Hat Advisories.
  
Es gelten folgende Stichtage fuer die Installation:

  * ${DATE1} Installation Phase 1
  * ${DATE2} Installation Phase 2
  * ${DATE3} Installation Phase 3
  * ${DATE4} Installation Phase 4

Die von den Advisories betroffenen Pakete werden nur dann aktualisiert, falls die Advisories nicht bereits vor dem jeweiligen Stichtag durch den Systembetreiber eingespielt wurden. Der folgende Befehl kann direkt per Copy & Paste zur Installation genutzt werden.

~~~
yum -y update-minimal --advisory ${ADVISORY_LIST}
~~~

Informationen zu den genannten Advisories findet man unter der URL: https://access.redhat.com/errata/#/

Sollte die Installation der genannten Advisories erforderlich sein, werden die betroffenen Systeme nach der Installation automatisch neugestartet.
EOF
}

send_mail() {
  /usr/bin/mailx -s 'Ankündigung der Installation von Red Hat Advisories' "${MAIL_RCP}" <"${MAIL_TEXT}"
}

# Main #######################################################################
create_patch_set
create_vars
create_mail
send_mail
