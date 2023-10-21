pipeline {
agent { label 'awsDeploy' }
stages {
stage ('Build') {
steps {
sh '''#!/bin/bash
python3.7 -m venv test
source test/bin/activate
pip install pip --upgrade
pip install -r requirements.txt
'''
}
}
stage ('test') {
steps {
sh '''#!/bin/bash
source test/bin/activate
pip install pytest
py.test --verbose --junit-xml test-reports/results.xml
'''
}
post{
always {
junit 'test-reports/results.xml'
}
}
}
stage ('Clean') {
agent {label 'awsDeploy'}
steps {
sh '''#!/bin/bash
if [[ $(ps aux | grep -i "gunicorn" | tr -s " " | head -n 1 | cut -d " " -f 2) != 0 ]]
then
ps aux | grep -i "gunicorn" | tr -s " " | head -n 1 | cut -d " " -f 2 > pid.txt
kill $(cat pid.txt)
exit 0
fi
'''
}
}
stage('Deploy') {
    agent { label 'awsDeploy' }
    steps {
        script {
            def remoteServer = 'YourServerConfigName'
            def remoteDirectory = '~/'


            def githubRepoURL = 'https://github.com/elmorenox/webapp-on-vpc-with-terraform-and-jenkins.git'

            sshPublisher(
                configName: remoteServer,
                verbose: true,
                transfers: [
                    sshTransfer(
                        execCommand: """
                            git clone ${githubRepoURL} ${remoteDirectory}/banking &&
                            cd ${remoteDirectory}/banking &&
                            python3.7 -m venv test &&
                            source test/bin/activate &&
                            pip install pip --upgrade &&
                            pip install -r requirements.txt &&
                            pip install gunicorn &&
                            python database.py &&
                            sleep 1 &&
                            python load_data.py &&
                            sleep 1 &&
                            python -m gunicorn app:app -b 0.0.0.0 -D
                        """
                    )
                ]
            )
        }
    }
}
stage ('Reminder') {
steps {
sh '''#!/bin/bash
##############################################################
# The Application should be running on your other instance!! #
##############################################################
'''
}
}
}
}
