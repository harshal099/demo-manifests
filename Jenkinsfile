pipeline {
  agent any

  parameters {
    choice(
      name: 'NAMESPACE',
      choices: ['ns-one', 'ns-two'],
      description: 'Target namespace'
    )
    string(
      name: 'APP_NAME',
      description: 'Application name (folder name)'
    )
    string(
      name: 'IMAGE_TAG',
      description: 'Docker image tag / build number'
    )
  }

  stages {

    stage('Checkout repo') {
      steps {
        checkout scm
      }
    }

    stage('Update manifest') {
      steps {
        sh '''
        echo "Running update script..."
        chmod +x scripts/update-manifests.sh
        scripts/update-manifests.sh ${NAMESPACE} ${APP_NAME} ${IMAGE_TAG}
        '''
      }
    }

    stage('Show changes') {
      steps {
        sh '''
        echo "========= GIT DIFF ========="
        git diff || true
        '''
      }
    }

    stage('Commit changes') {
      steps {
        sh '''
        git status
        git commit -am "POC: update ${APP_NAME} to ${IMAGE_TAG} in ${NAMESPACE}" || echo "Nothing to commit"
        git push origin HEAD
        '''
      }
    }
  }
}

