#!groovy
@Library('Infrastructure') _

try {
  node {
    env.PATH = "$env.PATH:/usr/local/bin"

    stage('Checkout') {
      deleteDir()
      checkout scm
    }

    stage('Terraform init') {
      sh 'terraform init'
    }

    stage('Terraform Linting Checks') {
      sh "terraform validate -var 'product=product' -var 'location=location' -var 'env=env' -var 'postgresql_user=user'"
    }
  }
}
catch (err) {
  throw err
}
