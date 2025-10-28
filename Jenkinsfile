pipeline {
  agent {
    docker { image 'maven:3.9.6-eclipse-temurin-17' args '-v /root/.m2:/root/.m2' }
  }
  environment {
    DOCKER_IMAGE = "your-dockerhub-username/myapp:${env.BUILD_NUMBER}"
  }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Build (Maven)') {
      steps {
        sh 'mvn -B -V clean package'
      }
    }
    stage('Build Docker image') {
      steps {
        sh "docker build -t ${DOCKER_IMAGE} ."
      }
    }
    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
          sh 'echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin'
          sh "docker push ${DOCKER_IMAGE}"
        }
      }
    }
  }
}
