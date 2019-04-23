#!groovy

def source_git_repo       = 'https://github.com/elos-tech/kubernetes-cicd-infra.git'
def app_pipeline_git_repo = 'https://github.com/elos-tech/openshift-cicd-app.git'
def name_prefix        = 'cicd-'
def app_domain         = 'apps.oslab.elostech.cz'
def jenkins_project    = "${name_prefix}jenkins"
def components_project = "${name_prefix}components"
def app_project_dev    = "${name_prefix}tasks-dev"
def app_project_prod   = "${name_prefix}tasks-prod"

node {
  stage('Cleanup') {
    sh """
      kubectl --namespace=${components_project} get all
      kubectl --namespace=${components_project} delete all,pvc,cm --selector=app=${name_prefix}nexus3
      kubectl --namespace=${components_project} delete all,pvc,cm --selector=app=${name_prefix}sonar-postgres
      kubectl --namespace=${components_project} delete all,pvc,cm --selector=app=${name_prefix}sonarqube
    """
  }

  stage('Checkout Source') {
    git source_git_repo
  }
  
  stage('Create Nexus') {
    sh 'ls -la'
  }
}

def create_from_template(request) {
  sh """
    TMP_DIR=\$(mktemp -d)

    function create_from_template {
      FILE=\$1; shift

      if [ ! -f "\$FILE" ]; then
        echo "ERROR: File '\$FILE' doesn't exist!"
        exit 1
      fi

      set -x
      cp \$FILE "\${TMP_DIR}/\$(basename \$FILE)"

      while (( "\$#" )); do
        #echo "Replacing parameter: \$1 -> \$2"
        sed -i 's@'\$1'@'\$2'@g' "\${TMP_DIR}/\$(basename \$FILE)"
        shift
        shift
      done

      kubectl create -f "\${TMP_DIR}/\$(basename \$FILE)"
      set +x
    }

    rm -rf \$TMP_DIR
  """
}
