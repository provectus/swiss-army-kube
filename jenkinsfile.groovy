pipeline {
  agent any
  tools {
    terraform 'terraform-12'
  }

  stages {
    stage('Prepare') {
      steps {
        sh """
        terraform --version
        curl -L "\$(curl -Ls https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" -o tflint.zip
        unzip tflint.zip -d /usr/local/bin
        rm tflint.zip
        tflint --version
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
