pipeline {
  agent { label 'win-or-linux' } // use a label that matches your agents; or 'any'
  environment {
    APP_NAME = "myapp"                                // change
    DOCKERHUB_REPO = "your-dockerhub-username/${APP_NAME}"
    DOCKER_IMAGE = "${DOCKERHUB_REPO}:${env.BUILD_NUMBER}"
    MAVEN_OPTS = "-Dmaven.repo.local=${env.WORKSPACE}\\.m2"
  }
  options { timestamps(); buildDiscarder(logRotator(numToKeepStr: '10')) }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Maven build') {
      steps {
        script {
          if (isUnix()) {
            sh 'mvn -B -V clean package'
          } else {
            // Windows: use cmd/batch
            bat 'mvn -B -V clean package'
          }
        }
      }
      post {
        always {
          junit '**/target/surefire-reports/*.xml'
        }
      }
    }

    stage('Build Docker image (if docker present)') {
      steps {
        script {
          def dockerAvailable = false
          if (isUnix()) {
            dockerAvailable = sh(script: 'which docker >/dev/null 2>&1 && echo OK || true', returnStdout: true).trim() == 'OK'
          } else {
            // On Windows check docker.exe existence in PATH
            def out = bat(script: 'where docker || echo NOTFOUND', returnStdout: true).trim()
            dockerAvailable = !out.contains('NOTFOUND') && out.size() > 0
          }

          if (!dockerAvailable) {
            echo "Docker CLI not found on agent — skipping Docker build/push."
          } else {
            if (isUnix()) {
              sh "docker build -t ${DOCKER_IMAGE} ."
            } else {
              bat "docker build -t ${DOCKER_IMAGE} ."
            }
          }
        }
      }
    }

    stage('Push to Docker Hub (if built)') {
      when {
        expression {
          // only push if docker image was built AND docker available
          return fileExists('Dockerfile') // keep simple; we already checked docker availability in prior stage
        }
      }
      steps {
        script {
          // Check docker present again
          def hasDocker = isUnix() ? (sh(script: 'which docker >/dev/null 2>&1 && echo OK || true', returnStdout: true).trim() == 'OK') : (bat(script: 'where docker || echo NOTFOUND', returnStdout: true).trim().contains('docker'))
          if (!hasDocker) {
            echo "Docker not available on this agent; skipping push."
          } else {
            withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
              if (isUnix()) {
                sh 'echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin'
                sh "docker push ${DOCKER_IMAGE}"
                sh 'docker logout'
              } else {
                bat 'echo %DOCKERHUB_PASS% | docker login -u %DOCKERHUB_USER% --password-stdin'
                bat "docker push ${DOCKER_IMAGE}"
                bat 'docker logout'
              }
            }
          }
        }
      }
    }

    stage('Archive artifact') {
      steps {
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true, allowEmptyArchive: true
      }
    }
  } // stages
  post {
    success { echo "Pipeline succeeded" }
    failure { echo "Build failed — check console output" }
  }
}
