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
        unzip tflint.zip -d /home/jenkins/tools/org.jenkinsci.plugins.terraform.TerraformInstallation/terraform-12
        rm tflint.zip
        tflint --version
        """
      }
    }

    stage('Run test') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'education', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh """
            cd example
            terraform init
            TFLINT_LOG=info tflint --deep --force --module --var-file example.tfvars .
          """
        }
      }
    }
  }
}
