pipeline {
	agent any
	stages {
		stage('Git Clone') {
			steps {
				git ([url: "https://github.com/samodev/Jenkins_terraform.git", branch: 'master' ])
			}
		}
		stage('checkout') {
			steps { 
				 sh "git checkout master"
			}
		}
		stage('Terraform init') {
			steps {
				sh "terraform init"
			}
		}
		stage('terraform apply') {
			steps {
				sh "terraform apply -var-file=env-vars.tfvars -auto-approve"
			}
		}	
	}
}
