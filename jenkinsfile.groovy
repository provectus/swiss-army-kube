pipeline {
    agent any

  stages {  
    stage('Prepare') {
      steps {
        git 'https://github.com/provectus/swiss-army-kube.git'
        sh """
        wget https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip
        unzip terraform_0.12.18_linux_amd64.zip
        rm terraform_0.12.18_linux_amd64.zip
        sudo mv terraform /usr/local/bin/
        terraform --version
        curl -L "$(curl -Ls https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" -o tflint.zip
        unzip tflint.zip
        rm tflint.zip       
        """
      }
    }
    
    stage('Run test') {
      steps {
        sh """
          TFLINT_LOG=info tflint --deep --force --module --format=checkstyle --var-file dev.tfvars .      
        """
      }
    }    
  }
}
