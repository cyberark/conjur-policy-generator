#!/usr/vin/env groovy

pipeline {
  agent { label 'executor-v2'}
  options { timestamps() }

  stages {
    stage('Build Policy Generator container image') {
      steps {
        sh 'bin/build'
      }
    }

    stage('Test Policy Generator') {
      steps {
        sh 'bin/test'
      }
    }

    stage('Push Policy Generator container image to internal registry') {
      steps {
        sh 'bin/push-image'
      }
    }
  }

  post {
    always {
      cleanupAndNotify(currentBuild.currentResult)
    }
  }
}
