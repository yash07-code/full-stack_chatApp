pipeline {
  agent any

  environment {
    REGISTRY = "docker.io/yashsuryawanshi07"
    FRONTEND_IMAGE = "${REGISTRY}/fullstack-frontend"
    BACKEND_IMAGE = "${REGISTRY}/fullstack-backend"
  }

  stages {
    stage('Clean') {
      steps {
        cleanWs()
      }
    }

    stage('Checkout') {
      steps {
        git branch: 'master', url: 'https://github.com/yash07-code/full-stack_chatApp.git'
      }
    }

    stage('Build Frontend') {
      steps {
        sh 'docker build -t $FRONTEND_IMAGE:$BUILD_NUMBER ./frontend'
      }
    }

    stage('Build Backend') {
      steps {
        sh 'docker build -t $BACKEND_IMAGE:$BUILD_NUMBER ./backend'
      }
    }

    stage('Push Images') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

            # Push with build number tag
            docker push $FRONTEND_IMAGE:$BUILD_NUMBER
            docker push $BACKEND_IMAGE:$BUILD_NUMBER

            # Tag & push latest
            docker tag $FRONTEND_IMAGE:$BUILD_NUMBER $FRONTEND_IMAGE:latest
            docker tag $BACKEND_IMAGE:$BUILD_NUMBER $BACKEND_IMAGE:latest
            docker push $FRONTEND_IMAGE:latest
            docker push $BACKEND_IMAGE:latest
          '''
        }
      }
    }

    stage('Update Manifests') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'github-creds', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASS')]) {
          sh '''
            sed -i "s|image: .*/fullstack-frontend.*|image: $FRONTEND_IMAGE:$BUILD_NUMBER|" k8s/frontend.yaml
            sed -i "s|image: .*/fullstack-backend.*|image: $BACKEND_IMAGE:$BUILD_NUMBER|" k8s/backend.yaml

            git config user.email "jenkins@example.com"
            git config user.name "jenkins"
            git add k8s/
            git commit -m "Update images to build $BUILD_NUMBER" || echo "No changes to commit"
            git push https://$GIT_USER:$GIT_PASS@github.com/yash07-code/full-stack_chatApp.git master
          '''
        }
      }
    }
  }
}

