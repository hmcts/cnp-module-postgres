#!groovy
@Library('Infrastructure@further-improvememnts') _

properties(
    [[$class: 'GithubProjectProperty', projectUrlStr: 'https://www.github.com/contino/moj-module-postgres/'],
     pipelineTriggers([[$class: 'GitHubPushTrigger']])]
)
try {
  node {

    platformSetup {
      stage('Checkout') {
        deleteDir()
        checkout scm
      }

      terraform.ini(this)
      stage('Terraform Linting Checks') {
        terraform.lint()
      }

      testLib = new Testing(this)
      stage('Terraform Unit Testing') {
        testLib.unitTest()
      }

      stage('Terraform Integration Testing') {
        testLib.moduleIntegrationTests()
      }

      stage('Tagging') {
        def tag = new Tagging(this)
        printf tag.applyTag(tag.nextTag())
      }
    }
  }
}
catch (err) {
  throw err
}
