#
In the second article of my user management scenario, I explained the Jenkins configuration and the stages of running the playbook, I created in the previous article, in the Jenkins pipeline.

## Step 1: Jenkin installation and configuration

I have installed Jenkins on my Ubuntu server.

First, add the repository key to the system:
`$ wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -`
After the key is added the system will return with `OK`.

Next, let’s append the Debian package repository address to the server’s sources.list:
`$ sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'`

After both commands have been entered, we’ll run update so that `apt` will use the new repository.
`$ sudo apt-get update`

Finally, we’ll install Jenkins and its dependencies.
`$ sudo apt-get install jenkins`

Let’s start Jenkins by using systemctl:
`$ sudo systemctl start jenkins`

Since systemctl doesn’t display status output, we’ll use the status command to verify that Jenkins started successfully:
`$ sudo systemctl status jenkins`

If everything went well, the beginning of the status output shows that the service is active and configured to start at boot:

Output
`● jenkins.service - LSB: Start Jenkins at boot time
   Loaded: loaded (/etc/init.d/jenkins; generated)
   Active: active (exited) since Fri 2020-06-05 21:21:46 UTC; 45s ago
     Docs: man:systemd-sysv-generator(8)
    Tasks: 0 (limit: 1137)
   CGroup: /system.slice/jenkins.service`

Go to http://localhost:8080 (8080 is the default port for Jenkins server unless you haven’t provided any specific port by yourself) or http://myServer:8080.

Copy password:
`$ sudo cat /var/lib/jenkins/secrets/initialAdminPassword`

Paste it the Jenkins. Then click on the `Install suggested plugins` button. 

Install Plugins:
I installed `Ansible Plugin` to build Ansible tasks in Jenkins pipeline.
Click `Manage Jenkins` > `Manage Plugins` > `Available` > `Search` > `Ansible Plugin` > Install without restart.

I have installed the `Extended Choice Parameter Plug-In` for multi server and group variable selection.
Click `Manage Jenkins` > `Manage Plugins` > `Available` > `Search` > `Extended Choice Parameter Plug-In` > Install without restart.

For Ansible commands to run in Jenkins:
`Manage Jenkins` > `Global Tool Configuration` > `Ansible installations...` > `Add Ansible`. 
I wrote `ansible` to the `Name` space, and `/usr/bin/` to the `Path to ansible executables directory` space. Then click `Save` button.

## Create Jenkins Pipeline

Click `Dashboard` > `New Item` > `Enter an item name` > `Pipeline` > Ok.

In the `Description` field, I wrote the description and function of my job. This field is optional.

In this pipeline, I received the ADD_USER, GROUP_NAME, SERVER_NAME, USER_PUBLIC_KEY and REMOVE USER variables from the user with Jenkins as input and placed these variables in the pipeline and used them in my playbooks.

For this, I marked this `This project is parameterised` field. Here I have defined these variables.

I got the name of the user I want to create with the variable ADD_USER. For this:
Click `String Parameter` > `Name`: ADD_USER.

I got the username of the user I want to create with the GROUP_NAME variable. I used `Extended Choice Parameter` to assign/remove a user to more than one group. For this:
Click `Add Parameter` > `Extended Choice Parameter` > `Name`: `GROUP_NAME`. Mark `Basic Parameter Types` > `Check Boxes` > `Number of Visible Items: 8` > Mark `Value`: backend, devops, security, ai, uxui, mobile, frontend, qa.
Here, the values written in the value section must be the same as the values in the `group_name` defined in `playbook_add_user.yml`.

I got the username of the user I want to create with the SERVER_NAME variable. I used `Extended Choice Parameter` to assign/remove a user to more than one server. For this:
Click `Add Parameter` > `Extended Choice Parameter` > `Name`: `SERVER_NAME`. Mark `Basic Parameter Types` > `Check Boxes` > `Number of Visible Items: 2` > Mark `Value`: server_name_1, server_name_2.
Here, the values written in the value section must be the same as the values in the defined in `/ect/ansible/hosts` file.

I assigned the public key to the variable named `USER_PUBLIC_KEY` in order to create the public key of the user in the authorized_key on the servers.For this:
Click `String Parameter` > `Name`: USER_PUBLIC_KEY.

I got the name of the user I want to remove with the variable REMOVE_USER. For this:
Click `String Parameter` > `Name`: REMOVE_USER.

Click Pipeline > Pipeline Script.

Jenkins pipeline consists of 4 stages:
- Pull Playbook from SCM
- Assign Variables into the Playbook
- Run Playbook
- Cleaning Workspace

In the first stage, I pulled my playbooks from github.
`pipeline {
    agent any
    stages {
        stage("Pull Playbook from SCM") {
            steps {
                git 'https://github.com/sezginerdem/playbook_user_management.git'
            }
        }
`

The second stage consists of two steps. In the first step, if a value is entered in the ADD_USER variable, the actions to be taken are seen. If a user will be deleted, that is, the ADD_USER field will be left blank, this stage will be skipped. This script `sed -i 's/var_server_name/${SERVER_NAME}/' playbook_add_user.yml` is a linux command. Its function, on the other hand, replaces all fields with `var_server_name` in the `playbook_add_user.yml` file with the variable `${SERVER_NAME}` and saves the file again. So I assigned my variables that I got with Jenkins to `playbook_add_user.yml`. I wrote this command to assign all the variables I received with Jenkins to `playbook_add_user.yml`. With `"""cat > user_public_key.pub <<EOF ${USER_PUBLIC_KEY} """` command I created a file named user_public_key.pub and placed the public key I received from the user. Because I defined the module in the playbook to get the public key from this file.

`
stage("Assign Variables into the Playbook") {
            steps {
                script {
                    if (params.ADD_USER != ""){
                        sh """sed -i 's/var_server_name/${SERVER_NAME}/' playbook_add_user.yml"""
                        sh """sed -i 's/var_add_user/${ADD_USER}/' playbook_add_user.yml"""
                        sh """sed -i 's/var_group_name/${GROUP_NAME}/' playbook_add_user.yml"""
                        sh """cat > user_public_key.pub <<EOF
                        ${USER_PUBLIC_KEY}
                        """
                    }
`

The second step will run if a value is entered in the REMOVE_USER field, otherwise it will be skipped. In other words, it will only work when the user is wanted to delete. This script `sed -i 's/var_remove_user/${REMOVE_USER}/' playbook_remove_user.yml` is a linux command. Its function, replaces all fields with `var_remove_user` in the `playbook_remove_user.yml` file with the variable `${REMOVE_USER}` and saves the file again. So I assigned my variables that I got with Jenkins to `playbook_remove_user.yml`. I wrote this command to assign all the variables I received with Jenkins to `playbook_remove_user.yml`.

`
                    if(params.REMOVE_USER != ""){
                        sh """sed -i 's/var_server_name/${SERVER_NAME}/' playbook_remove_user.yml"""
                        sh """sed -i 's/var_remove_user/${REMOVE_USER}/' playbook_remove_user.yml"""
                    }
                }
            }
        }
`
In this stage, if a value is entered to ADD_USER, `playbook_add_user.yml` will be executed. If a value is entered to REMOVE_USER, `playbook_remove_user.yml` will be executed.

`
stage("Run Playbook") {
            steps {
                script {
                    if (params.ADD_USER != ""){
                    ansiblePlaybook disableHostKeyChecking: true, installation: 'ansible', playbook: './playbook_add_user.yml'
                    }
                    if(params.REMOVE_USER != ""){
                    ansiblePlaybook disableHostKeyChecking: true, installation: 'ansible', playbook: './playbook_remove_user.yml'
                    }
                }
            }
        }
`

At this stage, I cleaned the workspace so that the files downloaded and created from github do not take up unnecessary space on disk space.

`
stage("Cleaning Workspace") {
            steps {
                sh 'rm -rf ./*'
            }
        }
    }
}
`

The entire Jenkins pipeline is as follows.

`
pipeline {
    agent any
    stages {
        stage("Pull Playbook from SCM") {
            steps {
                git 'https://github.com/sezginerdem/playbook_user_management.git'
            }
        }
        
        stage("Assign Variables into the Playbook") {
            steps {
                script {
                    if (params.ADD_USER != ""){
                        sh """sed -i 's/var_server_name/${SERVER_NAME}/' playbook_add_user.yml"""
                        sh """sed -i 's/var_add_user/${ADD_USER}/' playbook_add_user.yml"""
                        sh """sed -i 's/var_group_name/${GROUP_NAME}/' playbook_add_user.yml"""
                        sh """cat > user_public_key.pub <<EOF
                        ${USER_PUBLIC_KEY}
                        """
                    }
                    if(params.REMOVE_USER != ""){
                        sh """sed -i 's/var_server_name/${SERVER_NAME}/' playbook_remove_user.yml"""
                        sh """sed -i 's/var_remove_user/${REMOVE_USER}/' playbook_remove_user.yml"""
                    }
                }
            }
        }

        stage("Run Playbook") {
            steps {
                script {
                    if (params.ADD_USER != ""){
                    ansiblePlaybook disableHostKeyChecking: true, installation: 'ansible', playbook: './playbook_add_user.yml'
                    }
                    if(params.REMOVE_USER != ""){
                    ansiblePlaybook disableHostKeyChecking: true, installation: 'ansible', playbook: './playbook_remove_user.yml'
                    }
                }
            
            }
        }
        
        stage("Cleaning Workspace") {
            steps {
                sh 'rm -rf ./*'
            }
        }
    }
}
`
Click on the `SAVE` button.
