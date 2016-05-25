#!/bin/bash


#### INSTALL GENERAL DEPENDENCIES ####

# for son-cli
sudo apt-get install -y build-essential python3-dev python3-pip libyaml-dev

# needed to build son-monitor (zerorpc to son-emu)
sudo apt-get install -y python2.7 python-dev python-pip python-zmq libffi-dev libssl-dev

# needed to extract project templates
sudo apt-get install unzip




#### BUILD AND INSTALL SON-CLI (son-{workspace,package,publish,push})####

echo "\n\n======= Build and install SON-CLI (son-{workspace,package,publish,push}) =======\n\n"

git checkout cli/master

python3 bootstrap.py
bin/buildout
bin/py.test

sudo pip3 install .
sudo python3 setup.py develop



#### BUILD AND INSTALL SON-CLI (son-monitor) ####

echo "\n\n======= Build and install SON-CLI (son-monitor) [Python2] =======\n\n"

git checkout cli/master

# need recent version of setuptools
sudo pip2 install setuptools
sudo pip2 install --upgrade setuptools

sudo python2 setup_son-monitor.py develop



#### DEPLOY SON-CATALOGUE

echo "\n\n======= Deploy SON-CATALOGUE =======\n\n"

echo DOCKER_OPTS=\"--insecure-registry registry.sonata-nfv.eu:5000 -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375\" | sudo tee /etc/default/docker
sudo service docker restart
docker login -u sonata-nfv -p s0n@t@ registry.sonata-nfv.eu:5000
sudo pip3 install docker-compose

# Install and run the containers for the catalogue components
docker pull registry.sonata-nfv.eu:5000/sdk-catalogue
cd son-sdk-catalogue
docker-compose down
docker-compose up -d



#### DEPLOY SON-EMU ####

echo "\n\n======= Deploy SON-EMU =======\n\n"

set -xe

# Work on emu master
git checkout emu/master

export DOCKER_HOST="unix:///var/run/docker.sock"

# prepare environment
sudo apt-get install -o Dpkg::Options::="--force-confold" --force-yes -y build-essential python-dev python-pip docker-engine
# not sure why flask always makes trouble when installed from setup.py
sudo pip install flask

#### VM to registry access fix
echo DOCKER_OPTS=\"--insecure-registry registry.sonata-nfv.eu:5000 -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375\" | sudo tee /etc/default/docker
sudo service docker restart

sudo docker login -u sonata-nfv -p s0n@t@ registry.sonata-nfv.eu:5000

#### get latest son-emu container image (generated by son-emu Jenkins job)
sudo docker pull registry.sonata-nfv.eu:5000/son-emu

# run son-emu in a docker container in the background, expose fake GK and management API
sudo docker run -d -i --name 'son-emu-int-test' --net='host' --pid='host' --privileged='true' \
    -v '/var/run/docker.sock:/var/run/docker.sock' \
    -p 5000:5000 \
    -p 4242:4242 \
    registry.sonata-nfv.eu:5000/son-emu 'python src/emuvim/examples/sonata_y1_demo_topology_1.py'

# give the emulator time to start and configure
echo "Wait for emulator"
sleep 60

# check that son-emu-cli works
sudo docker exec son-emu-int-test son-emu-cli compute -h | grep "son-emu compute"



#### DEPLOY WEB TERMINAL ####

echo "\n\n======= Deploy a WEB TERMINAL =======\n\n"

curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
sudo apt-get install -y nodejs

mkdir webterm
cd webterm

git clone https://github.com/krishnasrinivas/wetty.git
cd wetty

#Wetty as a unix service
sudo npm install wetty -g
sudo cp /usr/lib/node_modules/wetty/bin/wetty.conf /etc/init
sudo start wetty

export PROXY_PASS=$(ip address show dev eth0 scope global | grep inet | tr "/" "\t" | awk '{print $2}')
export DOCKER_HOST="tcp://192.168.60.25:2375"
docker pull registry.sonata-nfv.eu:5000/son-sdk-nginx-dynamic
if ! [[ "$(docker inspect -f {{.State.Running}} son-sdk-nginx-dynamic 2> /dev/null)" == "" ]]; then docker rm -f son-sdk-nginx-dynamic ; fi
docker run -d -p 8000:80 --name son-sdk-nginx-dynamic -e PROXY_PASS=$PROXY_PASS registry.sonata-nfv.eu:5000/son-sdk-nginx-dynamic
export DOCKER_HOST="unix:///var/run/docker.sock"



