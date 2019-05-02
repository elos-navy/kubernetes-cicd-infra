#!groovy

def source_git_repo      = 'https://github.com/elos-tech/kubernetes-cicd-infra.git'
def name_prefix          = 'cicd-'
def prefix_label         = 'PREFIX' // Helper variable for prefix substitution with double sed-ed templates.
def jenkins_namespace    = "${name_prefix}jenkins"
def components_namespace = "${name_prefix}components"
def app_dev_namespace    = "${name_prefix}tasks-dev"
def app_prod_namespace   = "${name_prefix}tasks-prod"

node {
  stage('Cleanup') {
    delete_namespace(components_namespace)
    delete_namespace(app_dev_namespace)
    delete_namespace(app_prod_namespace)
  }

  stage('Checkout Source') {
    git source_git_repo
  }
  
  stage('Create Components namespace') {
    create_from_template 'default', "templates/components-namespace.yaml _${prefix_label}_ $name_prefix"
  }
  
  stage('Create Nexus') {
    create_from_template components_namespace, "templates/nexus.yaml _${prefix_label}_ $name_prefix"
    wait_for_deployment_ready(components_namespace, "${name_prefix}nexus3")
    
    // Initialize Nexus
    def pod_name = get_pod_name(components_namespace, "${name_prefix}nexus3")
    sh """
      kubectl --namespace cicd-components cp artefacts/setup_nexus3.sh $pod_name:/tmp/
      
      FAILED=0
      while true
      do
        kubectl --namespace cicd-components exec $pod_name -- /bin/bash /tmp/setup_nexus3.sh admin admin123 http://localhost:8081 || FAILED=1
        [ \$FAILED -eq 0 ] && break
        FAILED=0
        sleep 10
      done
    """
  }
  
  stage('Create Sonarqube') {
    create_from_template components_namespace, """templates/postgresql-persistent.yaml \
      _${prefix_label}_ ${name_prefix}sonar- \
      _POSTGRES_DB_ sonar \
      _POSTGRES_USER_ sonar \
      _POSTGRES_PASSWORD_ sonar \
      _DATABASE_SERVICE_NAME_ postgresql-sonarqube
    """
    
    // Wait for deployment of sonarqube until postgres is ready to handle requests.
    wait_for_deployment_ready(components_namespace, "${name_prefix}sonar-postgres")
    
    create_from_template components_namespace, "templates/sonarqube.yaml _${prefix_label}_ ${name_prefix}"
  }
  
  stage('Create DEV namespace') {
    create_from_template components_namespace, "templates/tasks-dev-namespace.yaml _${prefix_label}_ $name_prefix"
  }
  
  stage('Create PROD namespace') {
    create_from_template components_namespace, "templates/tasks-prod-namespace.yaml _${prefix_label}_ $name_prefix"
  }
}

def delete_namespace(namespace_name) {
  sh """
    kubectl delete namespace $namespace_name || echo
    while true;
    do
      kubectl get namespaces $namespace_name || break
      sleep 2
    done
  """
}

def get_pod_name(namespace, app_name) {
  return sh (
    script: "kubectl --namespace $namespace get pod | grep '^$app_name' | awk '{ print \$1 }'",
    returnStdout: true
  ).trim()
}

def create_from_template(namespace, request) {
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

      kubectl --namespace $namespace create -f "\${TMP_DIR}/\$(basename \$FILE)"
      set +x
    }
    
    create_from_template $request

    rm -rf \$TMP_DIR
  """
}

def wait_for_deployment_ready(namespace, deployment) {
  sh """
    while true;
    do
      READY=\$(kubectl --namespace $namespace get deployment $deployment --no-headers | awk '{ print \$5}')
      echo \$READY
      if [ \$READY -ge 1 ]; then
        break
      fi
      
      sleep 10
    done
  """
}
