#!groovy
@Library('Infrastructure') _

node {
    env.PATH = "$env.PATH:/usr/local/bin"

    stage('Checkout') {
        deleteDir()
        checkout scm
    }

    stage('Terraform init') {
        sh '''
      tfenv install
      terraform --version
      mv provider-ci-only.tf.txt provider.tf
      terraform init
      '''
    }

    stage('Terraform Linting Checks') {
        sh 'terraform validate'
    }
}