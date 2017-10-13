seq 1 20 | parallel "docker-machine create -d digitalocean --digitalocean-access-token ${DO_TOKEN} --digitalocean-region "fra1" --digitalocean-size "512mb" --digitalocean-image="ubuntu-16-04-x64" --digitalocean-ssh-key-fingerprint ${DO_FINGERPRINT} monero{}"
seq 1 20 | parallel "docker-machine ssh monero{} 'sudo sysctl -w vm.nr_hugepages=128 && ulimit -l 262144'"
seq 1 20 | parallel "docker-machine ssh monero{} 'curl -sSL https://agent.digitalocean.com/install.sh | sh'"
seq 1 20 | parallel --j 1 "eval $(docker-machine env monero{}) && docker-compose pull && docker-compose up -d"
seq 1 20 | parallel --j 1 "eval $(docker-machine env monero{}) && docker ps && echo"

docker-machine ssh hmonero1 sudo sysctl -w vm.nr_hugepages=128 && ulimit -l 262144 
docker-machine ssh hmonero1 docker pull valentinvieriu/docker-xmr-stack-cpu:v1.3.0-1.5.0

seq 1 11 | parallel "heroku apps:rename --app bookdepositoryapi-{} hmonero{}"
seq 0 19 | parallel "heroku ps:scale web=0 -a hmonero{}"
seq 0 19 | parallel "heroku config:set -a hmonero{} AUTO_THREAD_CONFIG=true POOL_ADDRESS='pool.minexmr.com:5555' POOL_PASSWORD=x WALLET_ADDRESS='42vVt8DmDS5i47Dop7Q8MiVZmwx67oh7QPXtfEsMWGxoCUymMtZVfAPdCmx2X7V9eGdhNVz2KLrEKE5Wn3fiUaeDE6zmSDa.hmonero{}+10000' SELF=hmonero{}"
seq 1 19 | parallel "docker tag registry.heroku.com/hmonero0/web registry.heroku.com/hmonero{}/web"
seq 0 19 | parallel "docker push registry.heroku.com/hmonero{}/web"
seq 0 19 | parallel "heroku open -a hmonero{}"