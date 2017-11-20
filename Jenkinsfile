#!/usr/vin/env groovy

pipeline {
  agent { label 'executor-v2'}
  options { timestamps() }

  stages {
    stage('Build Policy Generator container image') {
      steps {
        sh './build.sh'
      }
    }

    stage('Test Policy Generator') {
      steps {
        sh './test.sh'
      }
    }

    stage('Push Policy Generator container image to internal registry') {
      steps {
        sh './push-image.sh'
      }
    }
  }

  post {
    always {
      cleanupAndNotify(currentBuild.currentResult)
    }
  }
}
