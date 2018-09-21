pipeline {
	agent any
	stages {
		stage('Git Clone') {
			steps {
				git ([url: "https://github.com/samodev/terraform_ansible_apache.git", branch: 'master' ])
			}
		}
		stage('checkout') {
			steps { 
				 sh "git checkout master"
			}
		}
		stage('ansible-playbook') {
			steps {
				sh "sudo su && ansible-playbook installApache.yml"
			}
		}	
	}
}
