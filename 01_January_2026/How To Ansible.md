----- Ansible Restart 12/19/2025 -----

--- Is this simple way to install Ansible on local for WSL >? ---
apt update && apt upgrade -y
apt install pipx -y
pipx ensurepath
pipx install ansible
pipx install --include-deps ansible --force
source ~/.bashrc
which ansible-playbook
pipx list
ansible --version
---

mkdir /path/to/project/ansible-project/
cd /path/to/project/ansible-project/

# Don't forget that to use SSH keys, they should be (chmod 600)
chmod 600 /root/.ssh/id_rsa_scusnir

#Create Inventory list
vim hosts_lab.yaml >> 
all:
  hosts:
    prx01:
      ansible_host: 10.100.93.3
    prx02:
      ansible_host: 10.100.93.4
    app01:
      ansible_host: 10.100.93.5
    app02:
      ansible_host: 10.100.93.6
    app03:
      ansible_host: 10.100.93.7
    db01:
      ansible_host: 10.100.93.8
  vars:
    ansible_user: scusnir
    ansible_ssh_private_key_file: ~/.ssh/id_rsa_scusnir
    ansible_python_interpreter: /usr/bin/python3

ansible-inventory -i hosts_lab.yaml --list

#Create a simple playbook

>> vim playbook_1.yaml >>
---
- name: Connection Test
  hosts: all
  tasks:
    - name: Try to ping
      ansible.builtin.ping:

ansible-playbook -i hosts_lab.yaml playbook_1.yaml

ansible all -i hosts_lab.yaml -m setup

-- Collect info from servers --
vim collec_info.yaml
>>
---
- name: Hardware Report
  hosts: all
  gather_facts: yes
  tasks:
    - name: Display specific server specs
      debug:
        msg: 
          - "Hostname: {{ ansible_facts['hostname'] }}"
          - "OS:       {{ ansible_facts['distribution'] }} {{ ansible_facts['distribution_version'] }}"
          - "CPU:      {{ ansible_facts['processor_vcpus'] }} cores"
          - "RAM Total: {{ ansible_facts['memtotal_mb'] }} MB"
          - "RAM Free:  {{ ansible_facts['memfree_mb'] }} MB"
----

ansible-playbook -i hosts_lab.yaml collect_info.yaml #will show info into terminal