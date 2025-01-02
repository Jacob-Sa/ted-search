pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                    sh """cd app
                      mvn verify""" // Adjust for your build tool                }
        }
    }
        stage('Test') {
            steps {
                sh 'mvn test' // Run unit tests
            }
        }
        stage('Push Docker Image') {
            steps {
                sh 'docker tag ted_search:1.1-SNAPSHOT us-central1-docker.pkg.dev/rapid-digit-439413-d7/ted-search-repo/ted_search:1.1-SNAPSHOT'
                sh 'docker push us-central1-docker.pkg.dev/rapid-digit-439413-d7/ted-search-repo/ted_search:1.1-SNAPSHOT'
            }
        }
}
}
