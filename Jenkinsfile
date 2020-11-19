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
      dir('example') {
        sh '''
        tfenv install
        terraform --version
        terraform init
      '''
      }
    }

    stage('Terraform Linting Checks') {
      sh 'terraform fmt -recursive'
      
      dir('example') {
        sh 'terraform validate  -no-color'
      }
    }
  }
} catch (err) {
  throw err
} finally {
  deleteDir()
}
