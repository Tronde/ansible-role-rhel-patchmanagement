RHEL-Patchmanagement
====================

Patchmanagement for Red Hat Enterprise Linux.

Use Case
--------

In our environment we deploy RHEL-Servers for our operating departments to run their applications.

This role was written to provide a mechanism to install Red Hat Advisories on target nodes once a month. The Sysadmin could choose which Advisories should be installed, e.g. RHSA, RHBA and/or RHEA.

In our special use case only RHSA are installed to ensure a minimum limit of security. The installation is enforced once a month. The advisories are summarized in "Patch-Sets". This way it is ensured that the same advisories are used for all stages during a patch cycle.

In the Ansible Inventory nodes are summarized in one of the following groups which define when a node is scheduled for the patch installation:

 * testing - on the second Tuesday of a month
 * quality - on the third Tuesday of a month
 * production - on the fourth Tuesday and Wednesday of a month

In case packages were updated on target nodes the hosts will reboot afterwards.

Because the production systems are most important, they are divided into two separate groups to decrease the risk of failure and service downtime due to advisory installation.

A Bash script is used to trigger the playbook which runs the Patch-Management at the due date.

The process still needs some manual work to do by a Sysadmin. Please feel free to use the issue tracker to ask questions about the usage of the role or the role itself and report bugs you may find.

How to get the advisory information?
------------------------------------

You could subscribe to the Red Hat Advisory Notifications from Customer Portal or use the `yum updateinfo list all` command to get the advisory information.

Role Variables
--------------

To get the RHEL-Patchmanagement to work it is required to set `vars/main.yml`. This is done by running the script `create_vars.sh`.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

---
- hosts: all

  tasks:
    - name: Group by OS
      group_by: key=os_{{ ansible_distribution }}
      changed_when: False

- hosts: os_RedHat
  roles:
    - rhel_patchmanagement

How to use this role
--------------------

Please be aware that the following howto is considered to work with the use case described above. You may have to adjust some sort of things if you have a differen use case. I assume that you have already cloned this repo or downloaded all the necessary files. After that you have to do the following steps to geht the RHEL-Patchmanagement to work.

 1. Edit `run_rhel_patch_mgmt.sh` and insert the sshkey which is used to connect to your nodes.
 1. Create a cronjob which runs `run_rhel_patch_mgmt.sh` on every Tuesday and Wednesday at a chosen time. The script will trigger the ansible playbook at the times mentioned in the above use case. You could adjust it to your needs.
 1. You may have to edit `patch_rhel.yml` to fit your needs. By default this playbook runs on all hosts of your inventory which have a Red Hat operating system installed.
 1. Before the next patch cycle starts you have to run `create_vars.sh` to create a new `/vars/main.yml` file with a current patch set.
 1. You may use the content of `mail_text.txt` to notify your users which advisories are going to be installed.

License
-------

MIT

Author Information
------------------

 * Original: Joerg Kastning
