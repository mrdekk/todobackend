#!/bin/bash

cwd=$(pwd)/..

# NOTE: we are supposing to run at /opt in container

docker stop swifter
docker rm swifter
docker run \
	-dt \
	--name swifter \
	-p 8000:8000 \
	-v ${cwd}:/opt \
	--privileged \
	swift:5.5.1-xenial

