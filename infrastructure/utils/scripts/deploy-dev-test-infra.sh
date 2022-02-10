#! /bin/bash

BASEDIR=$(dirname "$0")
pushd $BASEDIR
BASEDIR=$(pwd -P)
popd

export MODE=""
export SERVER_NFS_IP=$(hostname -I | awk '{print $1}')
export SHARED_STORAGE_TYPE="HostPath"
export ENV="onpremise"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
DRY_RUN="${DRY_RUN:-0}"

# Let shell functions inherit ERR trap.  Same as `set -E'.
set -o errtrace
# Trigger error when expanding unset variables.  Same as `set -u'.
set -o nounset
#  Trap non-normal exit signals: 1/HUP, 2/INT, 3/QUIT, 15/TERM, ERR
#  NOTE1: - 9/KILL cannot be trapped.
#+        - 0/EXIT isn't trapped because:
#+          - with ERR trap defined, trap would be called twice on error
#+          - with ERR trap defined, syntax errors exit with status 0, not 2
#  NOTE2: Setting ERR trap does implicit `set -o errexit' or `set -e'.

trap onexit 1 2 3 15 ERR

#--- onexit() -----------------------------------------------------
#  @param $1 integer  (optional) Exit status.  If not set, use `$?'

function onexit() {
  local exit_status=${1:-$?}
  if [[ $exit_status != 0 ]]; then
    echo -e "${RED}Exiting $0 with $exit_status${NC}"
    exit $exit_status
  fi

}

function execute() {
  echo -e "${GREEN}[EXEC] : $@${NC}"
  err=0
  if [[ $DRY_RUN == 0 ]]; then
    $@
    onexit
  fi
}

function isWSL() {
  if grep -qEi "(Microsoft|WSL)" /proc/version &>/dev/null; then
    return 0
  else
    return 1
  fi
}

function getHostName() {
  sed -nr '0,/127.0.0.1/ s/.*\s+(.*)/\1/p' /etc/hosts
}

# usage
usage() {
  echo "Usage: $0 [option...]" >&2
  echo
  echo "   -m, --mode <Possible options below>"
  cat <<-EOF
  Where --mode should be :
        destroy-all         : To destroy all storage and armonik in the same command
        destroy-armonik     : To destroy Armonik deployment only
        destroy-storage     : To destroy storage deployment only
        deploy-storage      : To deploy Storage independently on master machine. Available (Cluster or single node)
        deploy-armonik      : To deploy armonik
        deploy-all          : To deploy both Storage and Armonik
        redeploy-storage    : To REdeploy storage
        redeploy-armonik    : To REdeploy armonik
        redeploy-all        : To REdeploy both storage and armonik

EOF
  echo "   -ip, --nfs-server-ip <SERVER_NFS_IP>"
  echo
  echo "   -s, --shared-storage-type <SHARED_STORAGE_TYPE>"
  echo
  cat <<-EOF
  Where --shared-storage-type should be :
        HostPath            : Use in localhost
        NFS                 : Use a NFS server
        AWS_EBS             : Use an AWS Elastic Block Store
EOF
  echo
  echo "   -env, --environment <COMPUTE_ENVIRONMENT>"
  cat <<-EOF
  Where --mode should be :
        onpremise           : ArmoniK is deployed on localhost or onpremise cluster
        aws                 : ArmoniK is deployed on AWS cloud
EOF
  echo
  exit 1
}

# Clean
destroy_storage() {
  terraform_init_storage
  cd $BASEDIR/../../storage/onpremise
  execute terraform destroy -auto-approve
  execute make clean
  # execute kubectl delete namespace $ARMONIK_STORAGE_NAMESPACE
  cd -
}

destroy_armonik() {
  terraform_init_armonik
  cd $BASEDIR/../../armonik
  execute terraform destroy -auto-approve
  execute make clean
  # execute kubectl delete namespace $ARMONIK_NAMESPACE
  cd -
}

# deploy storage
deploy_storage() {
  terraform_init_storage
  cd $BASEDIR/../../storage/onpremise
  if [ $ENV == "onpremise" ]; then
    execute terraform apply -var-file=parameters.tfvars -auto-approve
  elif [ $ENV == "aws" ]; then
    execute terraform apply -var-file=aws-parameters.tfvars -auto-approve
  else
    echo "Environment $ENV is unknown ! Possible values: -env=<\"onpremise\" | \"aws\">."
    exit 1
  fi
  cd -
}

# storage endpoint urls
endpoint_urls() {
  pushd $BASEDIR/../../storage/onpremise >/dev/null 2>&1
  export ACTIVEMQ_HOST=$(terraform output -json activemq_endpoint_url | jq -r '.host')
  export ACTIVEMQ_PORT=$(terraform output -json activemq_endpoint_url | jq -r '.port')
  export MONGODB_HOST=$(terraform output -json mongodb_endpoint_url | jq -r '.host')
  export MONGODB_PORT=$(terraform output -json mongodb_endpoint_url | jq -r '.port')
  export REDIS_URL=$(terraform output -json redis_endpoint_url | jq -r '.url')
  export SHARED_STORAGE_HOST=${1:-""}
  execute echo "Get Hostname for Shared Storage: \"${SHARED_STORAGE_HOST}\""
  popd >/dev/null 2>&1
}

# create configuration file
storage_configuration_file (){
  python $BASEDIR/../../../tools/modify_parameters.py \
    -kv storage.object=Redis \
    -kv storage.table=MongoDB \
    -kv storage.queue=Amqp \
    -kv storage.shared=$SHARED_STORAGE_TYPE \
    -kv storage_endpoint_url.mongodb.host=$MONGODB_HOST \
    -kv storage_endpoint_url.mongodb.port=$MONGODB_PORT \
    -kv storage_endpoint_url.activemq.host=$ACTIVEMQ_HOST \
    -kv storage_endpoint_url.activemq.port=$ACTIVEMQ_PORT \
    -kv storage_endpoint_url.redis.url=$REDIS_URL \
    -kv storage_endpoint_url.shared.host=$SHARED_STORAGE_HOST \
    $BASEDIR/../../armonik/parameters/storage-parameters.tfvars \
    $BASEDIR/storage-parameters.tfvars.json
}

armonik_configuration_file (){
  FILE=$BASEDIR/../../armonik/parameters/armonik-parameters.tfvars
  if [ $ENV == "aws" ]; then
    FILE=$BASEDIR/../../armonik/parameters/aws-armonik-parameters.tfvars
  fi
  python $BASEDIR/../../../tools/modify_parameters.py \
    $FILE \
    $BASEDIR/armonik-parameters.tfvars.json
}

monitoring_configuration_file (){
  FILE=$BASEDIR/../../armonik/parameters/monitoring-parameters.tfvars
  if [ $ENV == "aws" ]; then
    FILE=$BASEDIR/../../armonik/parameters/aws-monitoring-parameters.tfvars
  fi
  python $BASEDIR/../../../tools/modify_parameters.py \
    $FILE \
    $BASEDIR/monitoring-parameters.tfvars.json
}

configuration_file() {
  storage_configuration_file
  armonik_configuration_file
  monitoring_configuration_file
}

# deploy armonik
deploy_armonik() {
  terraform_init_armonik
  # install hcl2
  execute pip install python-hcl2
  execute echo "Get Optional IP for Shared Storage: \"${SERVER_NFS_IP}\""
  endpoint_urls $SERVER_NFS_IP

  configuration_file ${SHARED_STORAGE_TYPE}

  cd $BASEDIR/../../armonik
  execute terraform apply \
      -var-file $BASEDIR/storage-parameters.tfvars.json \
      -var-file $BASEDIR/armonik-parameters.tfvars.json \
      -var-file $BASEDIR/monitoring-parameters.tfvars.json \
      -auto-approve
  cd -
}

function terraform_init_storage() {
  pushd $BASEDIR/../../storage/onpremise >/dev/null 2>&1
  execute echo "change to directory : $(pwd -P)"
  execute terraform init
  popd >/dev/null 2>&1
}

function terraform_init_armonik() {
  pushd $BASEDIR/../../armonik >/dev/null 2>&1
  execute echo "change to directory : $(pwd -P)"
  execute terraform init
  popd >/dev/null 2>&1
}

create_kube_secrets() {
  cd $BASEDIR/../../../tools/install
  bash init_kube.sh
  cd -
}

# Main
function main() {
  for i in "$@"; do
    case $i in
    -h | --help)
      usage
      exit
      shift
      ;;
    -m)
      MODE="$2"
      shift
      shift
      ;;
    --mode)
      MODE="$2"
      shift
      shift
      ;;
    -ip)
      SERVER_NFS_IP="$2"
      SHARED_STORAGE_TYPE="NFS"
      shift
      shift
      ;;
    --nfs-server-ip)
      SERVER_NFS_IP="$2"
      SHARED_STORAGE_TYPE="NFS"
      shift
      shift
      ;;
    -s)
      SHARED_STORAGE_TYPE="$2"
      shift
      shift
      ;;
    --shared-storage-type)
      SHARED_STORAGE_TYPE="$2"
      shift
      shift
      ;;
    -env)
      ENV="$2"
      shift
      shift
      ;;
    --envirnment)
      ENV="$2"
      shift
      shift
      ;;
    --default)
      DEFAULT=YES
      shift # past argument with no value
      ;;
    *)
      # unknown option
      ;;
    esac
  done

  # source envvars
  source $BASEDIR/envvars-storage.sh
  source $BASEDIR/envvars-monitoring.sh
  source $BASEDIR/envvars-armonik.sh

  # Create Kubernetes secrets
  create_kube_secrets

  # Manage infra
  if [ -z $MODE ]; then
    usage
    exit
  elif [ $MODE == "destroy-armonik" ]; then
    destroy_armonik
  elif [ $MODE == "destroy-storage" ]; then
    destroy_storage
  elif [ $MODE == "destroy-all" ]; then
    destroy_storage
    destroy_armonik
  elif [ $MODE == "deploy-storage" ]; then
    deploy_storage
  elif [ $MODE == "deploy-armonik" ]; then
    deploy_armonik
  elif [ $MODE == "deploy-all" ]; then
    deploy_storage
    deploy_armonik
  elif [[ $MODE == "redeploy-storage" ]]; then
    destroy_storage
    deploy_storage
  elif [[ $MODE == "redeploy-armonik" ]]; then
    destroy_armonik
    deploy_armonik
  elif [[ $MODE == "redeploy-all" ]]; then
    destroy_storage
    destroy_armonik
    deploy_storage
    deploy_armonik
  else
    echo -e "\n${RED}$0 $@ where [ $MODE ] is not a correct Mode${NC}\n"
    usage
    exit
  fi
}

main $@
