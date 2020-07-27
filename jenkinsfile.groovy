pipeline {
  agent any

  stages {
    stage('Prepare') {
      steps {
        sh """
        wget https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip
        unzip terraform_0.12.18_linux_amd64.zip
        rm terraform_0.12.18_linux_amd64.zip
        mv terraform /usr/local/bin/
        terraform --version
        """
      }
    }

    stage('Run test') {
      steps {
        sh """
          cd example
          terraform init
          TFLINT_LOG=info tflint --deep --force --module --format=checkstyle --var-file example.tfvars .
        """
      }
    }
  }
}
