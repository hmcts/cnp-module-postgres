#!groovy
@Library('Infrastructure') _
import uk.gov.hmcts.contino.Testing
import uk.gov.hmcts.contino.Tagging

try {
  node {
    stage('Checkout') {
      deleteDir()
      checkout scm
    }

    terraform.ini(this)
    stage('Terraform Linting Checks') {
      terraform.lint()
    }
  }
}
catch (err) {
  throw err
}
