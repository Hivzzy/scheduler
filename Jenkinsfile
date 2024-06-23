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
        stage('Test SonarQube Connectivity') {
            steps {
                script {
                    def sonarUrl = 'http://<sonarqube-server-url>'
                    def response = sh(script: "curl -s -o /dev/null -w '%{http_code}' ${sonarUrl}", returnStdout: true).trim()
                    if (response == '200') {
                        echo "Successfully connected to SonarQube server."
                    } else {
                        error "Failed to connect to SonarQube server. HTTP response code: ${response}"
                    }
                }
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    bat 'mvn clean package'
                    bat ''' mvn clean verify sonar:sonar -Dsonar.projectKey=scheduler-info -Dsonar.projectName='scheduler-info' -Dsonar.host.url=http://localhost:9000 '''
                    echo 'SonarQube Analysis Completed'
                }
            }
        }
        stage("Quality Gate") {
            steps {
                waitForQualityGate abortPipeline: true
                echo 'Quality Gate Completed'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    bat 'docker build -t hivzzy/scheduler-info .'
                    echo 'Build Docker Image Completed'
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    withCredentials([string(credentialsId: 'hub', variable: 'dockerhub-password')]) {
                        bat ''' docker login -u hivzzy -p "%dockerhub-password%" '''
                    }
                    bat 'docker push hivzzy/scheduler-info'
                }
            }
        }

        stage ('Docker Run') {
            steps {
                script {
                    bat 'docker run -d --name scheduler-info -p 8099:8080 hivzzy/scheduler-info'
                    echo 'Docker Run Completed'
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