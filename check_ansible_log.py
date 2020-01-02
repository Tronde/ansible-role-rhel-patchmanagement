#!/usr/bin/env python
# -*- encoding: utf-8 -*-
#
# Description:
# This script searches the current Ansible log for unreachable
# hosts and failed tasks.
#
# Please adjust function 'send_log' matching your environment.
#
# Author: Joerg Kastning -- joerg(PUNKT)kastning(AT)uni-bielefeld(PUNKT)de
# License: MIT

import glob
import os
import smtplib
from email.mime.text import MIMEText

def send_log(log):
  f = open(log, 'rb')
  msg = MIMEText(f.read())
  f.close()
  
  msg['Subject'] = 'Content of %s' % log
  msg['From'] = 'root@example.com'
  msg['To'] = 'receiver@example.com'
  
  s = smtplib.SMTP('localhost')
  s.sendmail('root@example.com', ['receiver@example.com'], msg.as_string())
  s.quit()

def main():
  list_of_files = glob.glob('/var/log/ansible/*.log')
  latest_file = max(list_of_files, key=os.path.getctime)
  theFile = open(latest_file, 'r')
  FILE = theFile.readlines()
  theFile.close()
  eventlist = []
  
  for line in FILE:
    if ('unreachable' or 'failed') in line:
      if not ('unreachable=0' and 'failed=0') in line:
        send_log(latest_file)
        break

if __name__ == "__main__":
  main()
