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
