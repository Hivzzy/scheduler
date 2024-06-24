pipeline {
    agent any
    tools {
        maven 'jenkins-maven'
    }

    stages {
        stage('Git Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/Hivzzy/scheduler']])
                bat 'mvn clean install'
                echo 'Git Checkout Completed'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    bat 'mvn clean package'
                    bat ''' mvn clean verify sonar:sonar -Dsonar.projectKey=scheduler-info -Dsonar.projectName='scheduler-info' -Dsonar.host.url=http://172.29.48.1:9000 '''
                    echo 'SonarQube Analysis Completed'
                }
            }
        }
    }
    post {
        always {
            bat 'docker logout'
        }
    }
}
