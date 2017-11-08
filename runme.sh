#!/bin/bash
set -e -u


export memsize="1gb"
export machinename="test-machine"
export nodename=$machinename-$memsize
export DIGITAL_OCEAN_TOKEN=3fe19a1344e94125039c9ab7c4b3bf1dd8dce207246fa9da65186d76379db027

#docker-machine create \
#  --driver generic \
#  --generic-ip-address=misp.dfir.tech \
#    $nodename


#eval "$(docker-machine env $nodename)"
set +e
docker stop crits
docker rm crits
rm -rf /Users/jbeley/crits-data/*
#git clone -b stable_4  https://github.com/crits/crits
#git clone  -b stable_4 https://github.com/crits/crits_services
docker rmi crits
set -e
docker build --rm  -t crits .


docker run -d --name crits -it  -v /Users/jbeley/crits-data:/data/db -p 8080:443 crits
docker exec -ti crits /bin/bash


