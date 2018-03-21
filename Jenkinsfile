#!groovy
@Library('Infrastructure') _

try {
  node {
    stage('Checkout') {
      deleteDir()
      checkout scm
    }

    stage('Terraform init') {
      sh 'terraform init'
    }

    stage('Terraform Linting Checks') {
      sh 'terraform validate'
    }
  }
}
catch (err) {
  throw err
}
