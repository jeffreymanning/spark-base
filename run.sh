#!/bin/bash 


# Reference: https://docs.docker.com/engine/userguide/containers/dockerimages/

echo "Usage: "
echo "  ${0} <repo-name/repo-tag>"
echo
accntTag=jeffreymanning
projectTag=spark-base
imageTag=${1:-${accntTag}/${projectTag}}

#instanceName=my-${2:-${imageTag%/*}}_$RANDOM
instanceName=${2:-${imageTag##*/}}
echo "instanceName ${instanceName}"

echo "(example)"
echo "docker run -d --name some-${imageTag##*/} -t ${imageTag}"
docker run -d --name ${instanceName} -t ${imageTag}

echo ">>> Docker Status"
docker ps -a
echo "-----------------------------------------------"
echo ">>> Docker Shell into Container `docker ps -lq`"
docker exec -it ${instanceName} /bin/bash

