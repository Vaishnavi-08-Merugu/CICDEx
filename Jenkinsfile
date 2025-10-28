pipeline {
  agent any

  environment {
    DOCKER_REGISTRY = "docker.io"
    DOCKER_REPO     = "vaishnavi873/project0"   // change if needed
    IMAGE_TAG       = "${env.BUILD_NUMBER}"
    FULL_TAG        = "${DOCKER_REPO}:${IMAGE_TAG}"
    LATEST_TAG      = "${DOCKER_REPO}:latest"
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '20'))
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('List workspace') {
      steps {
        script {
          if (isUnix()) { sh 'ls -la' } else { bat 'dir' }
        }
      }
    }
    stage('Build with Maven') {
  steps {
    script {
      if (isUnix()) {
        sh 'mvn -B clean package -DskipTests'
      } else {
        bat 'mvn -B clean package -DskipTests'
      }
    }
  }
}


    stage('Build Docker image') {
      steps {
        script {
          if (isUnix()) {
            sh "docker build -t ${FULL_TAG} ."
            sh "docker tag ${FULL_TAG} ${LATEST_TAG}"
          } else {
            bat "docker build -t ${FULL_TAG} ."
            bat "docker tag ${FULL_TAG} ${LATEST_TAG}"
          }
        }
      }
    }

    stage('Login & Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
          script {
            if (isUnix()) {
              sh 'echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin'
              sh "docker push ${FULL_TAG}"
              sh "docker push ${LATEST_TAG}"
              sh 'docker logout'
            } else {
              bat 'echo %DOCKERHUB_PASS% | docker login -u %DOCKERHUB_USER% --password-stdin'
              bat "docker push ${FULL_TAG}"
              bat "docker push ${LATEST_TAG}"
              bat 'docker logout'
            }
          }
        }
      }
    }

    stage('Cleanup local images') {
      steps {
        script {
          if (isUnix()) {
            sh "docker rmi ${FULL_TAG} || true"
            sh "docker rmi ${LATEST_TAG} || true"
          } else {
            bat "docker rmi ${FULL_TAG} || exit /b 0"
            bat "docker rmi ${LATEST_TAG} || exit /b 0"
          }
        }
      }
    }
  }

  post {
    success { echo "✅ Docker pushed: ${FULL_TAG} and ${LATEST_TAG}" }
    failure { echo "❌ Pipeline failed — check console log" }
    always {
      script {
        if (isUnix()) { sh "docker images | head -n 50 || true" } else { bat "docker images | more" }
      }
    }
  }
}
