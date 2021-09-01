# User Management
In this article, I explained how to automate the processes of creating users, added public keys to the servers, assigning users to groups and removing them on servers through ansible in the jenkins pipeline.

This scenario will be explained in 2 articles. I have described the first and second steps in this article.
- Step1: Create ssh-keygen
- Step2: Ansible configuration
- Step3: Create a Jenkins pipeline

Tools to be used in this article are ubuntu 20.04, git/github, ansible, jenkins.

## Step 1: Creating SSH-KEYGEN

Ssh-keygen is a tool for creating new authentication key pairs for SSH. Such key pairs are used for automating logins, single sign-on, and for authenticating hosts. The SSH protocol uses public key cryptography for authenticating hosts and users. The authentication keys, called SSH keys, are created using the keygen program.

First I created ssh-keygen. If there is not, create a new `.ssh` folder under your home folder:
`$ mkdir ~/.ssh`

Go to `.ssh` folder:
`$ cd ~/.ssh`

Create a new ssh asymmetric key pair:
`$ ssh-keygen`

Now the inside the `.ssh` folder should be like this:
`serdem@ubuntu: ~/.ssh$ ls
config  id_rsa  id_rsa.pub  known_hosts`

Enter the following command to start the agent:
``$ eval `ssh-agent```

Add the private SSH key:
`$ ssh-add ~/.ssh/id_rsa`

## Step2: Ansible Configuration

Ansible is a radically simple IT automation engine that automates cloud provisioning, configuration management, application deployment, intra-service orchestration, and many other IT needs.

Update and Upgrade OS:
`$ sudo apt update -y`
`$ sudo apt upgrade -y`

You can find different ansible installation methods in the resources section at the bottom of the article.
Install ansible:
`$ sudo apt install ansible`

Check the installation:
`$ ansible --version`

Hostfile is the default file that the ansible control node needs to keep its information in order to connect to the managed nodes. The control node provides access to the managed nodes by accessing the information here.

Go to the hosts file:
`$ sudo vim /etc/ansible/hosts`

Configure ansible hosts file like this:
`[server1]
server_name_1 ansible_host=<IP_Address> ansible_connection=ssh ansible_ssh_user=user_name ansible_ssh_pass=<Password>

[server2]
server_name_2 ansible_host=<IP_Address> ansible_connection=ssh ansible_ssh_user=user_name ansible_ssh_pass=<Password>
`

Another way of connecting is the connection with ssh-keygen. If you have added the public key of your control node to a managed node, you no longer need to keep your password in your hostfile. This is the preferred method in the production environment. The hosts file created in this way is as follows:
`
[server1]
server_name_1 ansible_host=<IP_Address> ansible_connection=ssh ansible_ssh_user=user_name ansible_ssh_private_key_file=~/.ssh/id_rsa

[server2]
server_name_2 ansible_host=<IP_Address> ansible_connection=ssh ansible_ssh_user=user_name ansible_ssh_pass=<Password>`

To confirm that all our hosts are located by Ansible, we will run the command below.

`$ ansible all --list-hosts`

To make sure that all our hosts are reachable, we will run various ad-hoc commands that use the ping module.

`$ ansible all -m ping`

NOTE_1: If you get an error message like this:

`server_1 | FAILED! => {
    "msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"
}`

    Install sshpass:
    `$ apt-get install sshpass`

NOTE_2: If you get an error message like this:
`server_1 | FAILED! => {
    "msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."
}`

    Open ansible.cfg file and `host_key_checking = False` line:
    `$ sudo nano /etc/ansible/ansible.cfg`

If your ping command is working after all these configurations, you should see the following output.

`$ server_1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}

$ server_1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}`

At this stage, I created 2 playbooks named `playbook_add_user.yml` and `playbook_remove_user`.yml.

In `playbook_add_user.yml` I defined its name as `Create Group, User and Deploy the Public Key`. I have assigned the variables `var_server_name` to hosts in Jenkins, which I will receive from the user I want the playbook to run from. I created the group names under `vars`. I used three modules in this playbook. The module named `Create groups` will create my group names that I have assigned as `group_name` var variables. The module named `Add User` creates a user named `var_add_user` that I will assign as a variable in Jenkins and adds it to the group(s) named `var_group_name` that I will assign as a variable in Jenkins. `Set authorize keys taken from file` places the public key that I will take as the `user_public_key.pub` variable in the jenk of the module named `~/.ssh` of the user I created into the `authorized_key` file. If there is no such file, it creates it.

`$ vim playbook_add_user.yml`
`- name: Create Group, User and Deploy the Public Key
  hosts: [var_server_name]
  become: true

  vars:
    group_name:
    - name: backend
    - name: devops
    - name: security
    - name: ai
    - name: uxui
    - name: mobile
    - name: frontend
    - name: qa
  
  tasks:

# Creating groups
  - name: Create Groups
    group:
      name: "{{ item.name }}"
    with_items: "{{ group_name }}"

# Create users and add to group 
  - name: Add Users
    user:
      name: var_add_user
      groups: [var_group_name]

# Set authorized key from file
  - name: Set authorize keys taken from file
    authorized_key:
      user: var_add_user
      state: present
      key: "{{ lookup('file', './user_public_key.pub') }}"
`

This playbook was created for user remove. It will be assigned to the `var_server_name` variable, which will be obtained from Jenkins in the hosts section. With the `Remove User` module, the user will be removed with the `var_remove_user` variable that will be taken from Jenkins. In addition, the user's home folder and the files in this folder will be removed together with the user.

`$ vim playbook_add_user.yml`
`- name: Create Group, User and Deploy the Public Key
  hosts: [var_server_name]
  become: true

  tasks:
# Removing user
  - name: Remove User
    user:
      name: var_remove_user
      state: absent
      remove: yes
      force: yes`

After I made my git/github configurations, I pushed playbooks to my repository.

`$ git add .`
`$ git commit -m "added playbooks"`
`$ git push https://github.com/sezginerdem/playbook_user_management.git`

In my second article, I will explain the jenkins configuration and pipeline creation stages.

# Resources

https://www.ssh.com/academy/ssh/keygen
https://www.ansible.com/