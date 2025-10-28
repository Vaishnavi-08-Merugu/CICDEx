pipeline {
  agent { label 'docker' } // a node with Docker installed; change label to match your agent
  tools {
    maven 'Maven3'    // name in Global Tool Configuration
    jdk 'OpenJDK11'
  }
  environment {
    APP_NAME = "myapp1"                        // change app name
    DOCKER_IMAGE = "vaishnavi873/${APP_NAME}:${env.BUILD_NUMBER}"
    MAVEN_OPTS = "-Dmaven.repo.local=${env.WORKSPACE}/.m2"
  }
  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '10'))
    skipDefaultCheckout(false)
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build (Maven)') {
      steps {
        // Run mvn clean package (runs tests). Change or add -DskipTests if you only want package.
        sh 'mvn -B -V clean package'
      }
      post {
        always {
          junit '**/target/surefire-reports/*.xml' // collects test results if any
        }
      }
    }

    stage('Build Docker image') {
      steps {
        // build docker image using docker CLI; tag includes build number
        sh "docker --version || true"
        sh "docker build -t ${DOCKER_IMAGE} ."
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          // use Jenkins credentials id 'dockerhub-creds' (Username/Password)
          withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
            // login, push, and logout
            sh 'echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin'
            sh "docker push ${DOCKER_IMAGE}"
            sh 'docker logout'
          }
        }
      }
    }

    stage('Cleanup local images') {
      steps {
        // optional - free space on agent
        sh "docker rmi ${DOCKER_IMAGE} || true"
      }
    }

    stage('Archive artifact') {
      steps {
        archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
      }
    }
  }

  post {
    success { echo "Pipeline succeeded — image pushed: ${DOCKER_IMAGE}" }
    failure { echo "Pipeline failed" }
    always {
      // prints helpful link for audit
      echo "Docker Image (if pushed): ${DOCKER_IMAGE}"
    }
  }
}
