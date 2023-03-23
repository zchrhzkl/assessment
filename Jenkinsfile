pipeline {
  agent any

  environment {
    BRANCH_NAME = "${GIT_BRANCH.replace('origin/', '')}"
    GOOGLE_APPLICATION_CREDENTIALS = credentials('GOOGLE_APPLICATION_CREDENTIALS')
    GCP_FE_PUB_KEY = credentials('GCP_FE_PUB_KEY')
    VPC_TF_VARS = credentials('VPC_TERRAFORM_TFVARS')
    CE_TF_VARS = credentials('CE_TERRAFORM_TFVARS')
    TF_WORKSPACE = "${BRANCH_NAME}"
    TF_BACKEND_BUCKET = "afe7495ab393d58b-bucket-tfstate"
    TF_BACKEND_PREFIX = "jenkins/vpc/state"
    REGISTRY_URL = "gcr.io/zachsawitprodevops/zchrhzkl"
  }

  stages{

    stage('Build Docker image') {
      steps {
          sh "docker build -t react:${BRANCH_NAME}-latest ./"
      }
    }

    stage('Tag Docker Image') {
      steps {
          sh "docker tag react:${BRANCH_NAME}-latest ${REGISTRY_URL}/react:${BRANCH_NAME}-latest"
      }
    }

    stage('Push Docker Image to Artifact Registry') {
      steps {
        withCredentials([
          file(credentialsId: 'GOOGLE_APPLICATION_CREDENTIALS', variable: 'GOOGLE_APPLICATION_CREDENTIALS'),
        ])
        {
          sh "gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS"
          sh "gcloud auth configure-docker --quiet"
          sh "docker push ${REGISTRY_URL}/react:${BRANCH_NAME}-latest"
        }
      }
    }

    stage('Terraform Provision VPC') {
      steps {
        dir('terraform/modules/vpc') {
          withCredentials([
            file(credentialsId: 'GOOGLE_APPLICATION_CREDENTIALS', variable: 'GOOGLE_APPLICATION_CREDENTIALS'),
            file(credentialsId: 'VPC_TERRAFORM_TFVARS', variable: 'VPC_TF_VARS'),
          ])
          {
            sh "echo Current Workspace $TF_WORKSPACE"
            sh "echo yes | terraform init -backend-config \"credentials=$GOOGLE_APPLICATION_CREDENTIALS\""
            sh "terraform apply -auto-approve -var GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS} -var-file=${VPC_TF_VARS}"
          }
        }
      }
    }

    stage('Terraform Provision Compute Engine') {
      steps {
        dir('terraform/compute/apps_ce') {
          withCredentials([
            file(credentialsId: 'GOOGLE_APPLICATION_CREDENTIALS', variable: 'GOOGLE_APPLICATION_CREDENTIALS'),
            file(credentialsId: 'CE_TERRAFORM_TFVARS', variable: 'CE_TF_VARS'),
          ])
          {
            sh "echo Current Workspace $TF_WORKSPACE"
            sh "echo yes | terraform init -backend-config \"credentials=$GOOGLE_APPLICATION_CREDENTIALS\""
            sh "terraform destroy -auto-approve  -var GOOGLE_APPLICATION_CREDENTIALS=\"${GOOGLE_APPLICATION_CREDENTIALS}\" -var GCP_FE_PUB_KEY=\"${GCP_FE_PUB_KEY}\" -var IMAGE_TAG=\"${BRANCH_NAME}\" -var-file=${CE_TF_VARS}"
            // sh "terraform apply -auto-approve -var GOOGLE_APPLICATION_CREDENTIALS=\"${GOOGLE_APPLICATION_CREDENTIALS}\" -var GCP_FE_PUB_KEY=\"${GCP_FE_PUB_KEY}\" -var IMAGE_TAG=\"${BRANCH_NAME}\" -var-file=${CE_TF_VARS}"
          }
        }
      }
    }

     stage('Watch for instances') {
        steps {
          script {
            def instances = sh(script: "gcloud compute instance-groups list-instances ${INSTANCE_GROUP_NAME} --format json --project ${PROJECT_ID} --quiet --service-account-file=${SERVICE_ACCOUNT_KEY} | jq -r '.[].instance' | tr '\n' ',' | sed 's/,$//'")
            sh "echo 'Instances: ${instances}'"
            sh "echo '${instances}' > instances.ini"
          }
        }
      }

      stage('Run Ansible playbook') {
        steps {
          ansiblePlaybook playbook: "${ANSIBLE_PLAYBOOK_PATH}", inventory: "instances.ini"
        }
      }
    }

  }
}