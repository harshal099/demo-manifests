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
        bat '''
        echo Running update script...
    "C:\\Program Files\\Git\\bin\\bash.exe" scripts/update-manifests.sh %NAMESPACE% %APP_NAME% %IMAGE_TAG%
    '''
      }
    }


    stage('Show changes') {
      steps {
        bat '''
        echo ===== GIT DIFF =====
        git diff
        '''
      }
    }
    
    stage('Commit changes') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'github-https',
          usernameVariable: 'GIT_USER',
          passwordVariable: 'GIT_TOKEN'
        )]) {
          bat '''
          echo Configuring git identity...
          git config user.name "jenkins-bot"
          git config user.email "jenkins-bot@local"

          echo Checking out main branch...
          git checkout -B main

          echo Adding changes...
          git add manifests

          echo Committing changes...
          git commit -m "POC: update %APP_NAME% to %IMAGE_TAG% in %NAMESPACE%" || echo Nothing to commit

          echo Pushing changes (non-interactive)...
          git push https://%GIT_USER%:%GIT_TOKEN%@github.com/harshal099/demo-manifests.git main
          '''
        }
      }
    }

  }
}

