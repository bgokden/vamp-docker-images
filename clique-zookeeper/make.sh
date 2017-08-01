#!/usr/bin/env bash

set -e

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

reset=`tput sgr0`
green=`tput setaf 2`
yellow=`tput setaf 3`

target=$1
mkdir -p ${target} && cd ${target}

echo "${green}building: ${yellow}zk-web${reset}"

build_server="magneticio/buildserver"
docker pull $build_server

if [[ -d ${target}/zk-web ]] ; then

  docker run \
    --interactive \
    --rm \
    --volume ${target}:/srv/src \
    --workdir=/srv/src \
    $build_server \
      rm -rf /srv/src/zk-web
fi

git clone --depth=1 https://github.com/qiuxiafei/zk-web.git
cd ${target}/zk-web

docker run \
  --interactive \
  --rm \
  --volume ${target}/zk-web:/srv/src \
  --workdir=/srv/src \
  $build_server \
    lein uberjar

cp $(find "${target}/zk-web/target" -name 'zk-web-*-standalone.jar' | sort | tail -1) ${target}/zk-web.jar

echo "${green}copying files...${reset}"
cd ${dir}
cp -f ${dir}/zk.sh ${target}/zk.sh
cp -f ${dir}/zk-web-conf.clj ${target}/zk-web-conf.clj
cp -f ${dir}/Dockerfile ${target}/Dockerfile
cp -f ${dir}/log4j.properties ${target}/log4j.properties
cp -f ${dir}/supervisord.conf ${target}/supervisord.conf
