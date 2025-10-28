pipeline {
  agent { label 'linux' }  // change to a node that has docker and mvn on PATH
  environment {
    APP_NAME = "myapp"                            // change to your app name
    DOCKERHUB_REPO = "your-dockerhub-username/${APP_NAME}" // change username
    DOCKER_IMAGE = "${DOCKERHUB_REPO}:${env.BUILD_NUMBER}"
    MAVEN_OPTS = "-Dmaven.repo.local=${env.WORKSPACE}/.m2"
  }
  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Maven build') {
      steps {
        // Assumes 'mvn' available on agent path
        sh 'mvn -B -V clean package'
      }
      post {
        always {
          junit '**/target/surefire-reports/*.xml' // if tests produce JUnit xml
        }
      }
    }

    stage('Build Docker image') {
      steps {
        sh "docker --version || true"
        sh "docker build -t ${DOCKER_IMAGE} ."
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                            usernameVariable: 'DOCKERHUB_USER',
                                            passwordVariable: 'DOCKERHUB_PASS')]) {
            sh 'echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin'
            sh "docker push ${DOCKER_IMAGE}"
            sh 'docker logout'
          }
        }
      }
    }

    stage('Cleanup') {
      steps {
        sh "docker rmi ${DOCKER_IMAGE} || true"
      }
    }

    stage('Archive artifact') {
      steps {
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true, allowEmptyArchive: true
      }
    }
  }

  post {
    success { echo "Success: pushed ${DOCKER_IMAGE}" }
    failure { echo "Build failed" }
  }
}
