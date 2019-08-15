#!/bin/bash -x

CONNECTION_CHECK=0

while [[ $# > 0 ]]
do
  KEY="$1"
  shift
  case "$KEY" in
    --user|-p)
      NEXUS_USER="$1"
      shift
      ;;
    --password|-u)
      NEXUS_PASSWORD="$1"
      shift
      ;;
    --url|-l)
      NEXUS_URL="$1"
      shift
      ;;
    --connection_check|-c)
      CONNECTION_CHECK=1
      ;;
    --new_admin_password)
      NEW_ADMIN_PASSWORD="$1"
      shift
      ;;
    *)
      echo "ERROR: Unknown argument '$KEY' to script '$0'" 1>&2
      exit -1
  esac
done


function add_api_script {
  PAYLOAD=$@

  curl -v \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "${PAYLOAD}" \
    -u "${NEXUS_USER}:${NEXUS_PASSWORD}" \
    "${NEXUS_URL}/service/rest/v1/script/"
}

function run_api_script {
  SCRIPT_NAME=$1

  curl -v \
    -X POST \
    -H "Content-Type: text/plain" \
    -u "${NEXUS_USER}:${NEXUS_PASSWORD}" \
    "${NEXUS_URL}/service/rest/v1/script/${SCRIPT_NAME}/run"
}

function connection_check {
  curl -v \
    -X GET \
    "${NEXUS_URL}" > /dev/null
  exit $?
}

function execute_api_script {
  add_api_script "$1"
  run_api_script "$2"
}

function change_admin_password {
  NAME='change_admin_password'
  NEW_ADMIN_PASSWORD="$1"

  read -r -d '' PAYLOAD <<- EOM
{
  "name": "$NAME",
  "type": "groovy",
  "content": "security.securitySystem.changePassword('admin', args)"
}
EOM

  add_api_script "$PAYLOAD"

  CHECK_RUN_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" \
    -H "Content-Type: text/plain" \
    -u "${NEXUS_USER}:${NEXUS_PASSWORD}" \
    -d "${NEW_ADMIN_PASSWORD}" \
    "${NEXUS_URL}/service/rest/v1/script/${NAME}/run")

  if [ "${CHECK_RUN_STATUS}" == "200" ];then
    NEXUS_PASSWORD="$NEW_ADMIN_PASSWORD"
  else
    echo "Error occured on admin password change: ${CHECK_RUN_STATUS}"
  fi
}

function create_docker_repo {
  NAME=$1
  PORT=$2

  read -r -d '' PAYLOAD <<- EOM
{
  "name": "$NAME",
  "type": "groovy",
  "content": "repository.createDockerHosted('$NAME', $PORT, null)"
}
EOM

  execute_api_script "$PAYLOAD" "$NAME"
}

function create_npm_proxy {
  NAME=$1
  URL=$2

  read -r -d '' PAYLOAD <<- EOM
{
  "name": "$NAME",
  "type": "groovy",
  "content": "repository.createNpmProxy('$NAME', '$URL')"
}
EOM

  execute_api_script "$PAYLOAD" "$NAME"
}

function create_maven_proxy {
  NAME=$1
  URL=$2

  read -r -d '' PAYLOAD <<- EOM
{
  "name": "$NAME",
  "type": "groovy",
  "content": "repository.createMavenProxy('$NAME', '$URL')"
}
EOM

  execute_api_script "$PAYLOAD" "$NAME"
}

function create_maven_group {
  NAME=$1
  REPOS=$2

  read -r -d '' PAYLOAD <<- EOM
{
  "name": "$NAME",
  "type": "groovy",
  "content": "repository.createMavenGroup('$NAME', '$REPOS'.split(',').toList())"
}
EOM

  execute_api_script "$PAYLOAD" "$NAME"
}

function create_release_repo {
  NAME=$1

  read -r -d '' PAYLOAD <<- EOM
{
  "name": "$NAME",
  "type": "groovy",
  "content": "import org.sonatype.nexus.blobstore.api.BlobStoreManager\nimport org.sonatype.nexus.repository.storage.WritePolicy\nimport org.sonatype.nexus.repository.maven.VersionPolicy\nimport org.sonatype.nexus.repository.maven.LayoutPolicy\nrepository.createMavenHosted('$NAME',BlobStoreManager.DEFAULT_BLOBSTORE_NAME, false, VersionPolicy.RELEASE, WritePolicy.ALLOW, LayoutPolicy.PERMISSIVE)"
}
EOM

  execute_api_script "$PAYLOAD" "$NAME"
}

if [ "$CONNECTION_CHECK" -eq 1 ]; then
  connection_check
fi

if [ ! -z "$NEW_ADMIN_PASSWORD" ]; then
  echo "Changing admin password..."
  change_admin_password "$NEW_ADMIN_PASSWORD"
  exit 0
fi

#create_docker_repo docker 5000
create_maven_proxy redhat-ga https://maven.repository.redhat.com/ga/
create_maven_group maven-all-public redhat-ga,maven-central,maven-releases,maven-snapshots
create_npm_proxy npm https://registry.npmjs.org/
create_release_repo releases

