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

Because the production systems are most important they are divided in two separate groups to decrease the risk of failure and service downtime due to advisory installation.

A Bash script is used to trigger the playbook which runs the Patch-Management at the due date.

The process still needs some manual work to do by a Sysadmin. But a more automated version will follow soon. Please feel free to use the issue tracker to ask questions about the usage of the role or the role itself and report bugs you may find.

How to get the advisory information?
------------------------------------

You could subscribe to the Red Hat Advisory Notifications from Customer Portal or use the `yum updateinfo list` command to get the advisory information.

Requirements
------------

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

At first I like to explain the variables to set with an example from `vars/main.yml`. A more detailed description will follow:

```
---
  a_2016_10_11: RHSA-2016:2046,RHSA-2016:2047
  a_2016_10_19: RHSA-2016:2079
  a_2016_10_24: RHSA-2016:2098
  #
  Set_2016_11: "{{ a_2016_10_11 }},{{ a_2016_10_19 }},{{ a_2016_10_24 }}"
  #
  a_2016_11_03: RHSA-2016:2573,RHSA-2016:2574,RHSA-2016:2575,RHSA-2016:2577,RHSA-2016:2580,RHSA-2016:2581,RHSA-2016:2582,RHSA-2016:2583,RHSA-2016:2585,RHSA-2016:2586,RHSA-2016:2587,RHSA-2016:2588,RHSA-2016:2588,RHSA-2016:2591,RHSA-2016:2592,RHSA-2016:2593,RHSA-2016:2595,RHSA-2016:2597,RHSA-2016:2599,RHSA-2016:2601,RHSA-2016:2603,RHSA-2016:2605,RHSA-2016:2610,RHSA-2016:2615
  #
  a_2016_11_08: RHSA-2016:2674
  a_2016_11_14: RHSA-2016:2702
  a_2016_11_16: RHSA-2016:2779
  a_2016_11_28: RHSA-2016:2824
  #
  a_2016_12_06: RHSA-2016:2872
  #
  Set_2016_12: "{{ a_2016_11_03 }},{{ a_2016_11_08 }},{{ a_2016_11_14 }},{{ a_2016_11_16 }},{{ a_2016_11_28 }},{{ a_2016_12_06 }}"
  #
  rhsa_to_install: "{{ Set_2016_12 }}"
```

The variables **a_<Year>_<Month>_<Day>** includes the ids of the advisories which should be installed. The date in the variable name matches the date of the Red Hat Advisory Notification email. This will change in a future version of this role. A Patch-Set is defined by summarizing the variables in **Set_<Year>_<Month>**. As a value for <Month> the month is chosen in which the Patch-Set should be installed. And the variable **rhsa_to_install** defines which Patch-Sets will be installed in the next patch cycle. Usually only one Patch-Set will be defined here but it is possible to run older Patch-Sets again, for example if hosts were not reachable during the last patch cycle.


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
    - patch_rhel

License
-------

MIT

Author Information
------------------

 * Original: Joerg Kastning
