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

    stage('Terraform Linting Checks') {
      sh "terraform lint"
    }
  }
}
catch (err) {
  throw err
}
