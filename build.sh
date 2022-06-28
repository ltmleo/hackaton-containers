#!/bin/bash

REGISTRY="registryolq8408.azurecr.io"

cd .azdevops
docker-compose build

for image in poi trips user-java userprofile tripviewer; do
    docker tag tripinsights/${image}:1.0 ${REGISTRY}/tripinsights/${image}:1.0
    docker push ${REGISTRY}/tripinsights/${image}:1.0
done

echo "FINISHED"
