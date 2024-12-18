pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package' // Adjust for your build tool
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test' // Run unit tests
            }
        }
    }
}
