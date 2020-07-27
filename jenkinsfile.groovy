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
