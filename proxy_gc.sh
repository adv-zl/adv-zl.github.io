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
gcloud alpha billing accounts projects link $PROJECT_ID --account-id=$ACCOUNT_ID

gcloud service-management enable --project $PROJECT_ID cloudbilling.googleapis.com
gcloud service-management enable --project $PROJECT_ID cloudapis.googleapis.com
gcloud service-management enable --project $PROJECT_ID dns.googleapis.com
gcloud service-management enable --project $PROJECT_ID compute.googleapis.com
gcloud compute firewall-rules create socks --allow tcp:4444  --description="open_port_4444"

PROJECT_NUM=$(gcloud projects describe $PROJECT_ID --format=json | jq -r '.projectNumber')

gcloud beta compute --project $PROJECT_ID instance-templates create "instance-template-1" --machine-type "f1-micro" --network "default" --metadata "startup-script=sudo wget -O socks.sh https://raw.githubusercontent.com/adv-zl/adv-zl.github.io/master/dante.sh && sudo chmod +x socks.sh && ./socks.sh" --maintenance-policy "MIGRATE" --service-account "$PROJECT_NUM-compute@developer.gserviceaccount.com" --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --min-cpu-platform "Automatic" --image "debian-9-stretch-v20171025" --image-project "debian-cloud" --boot-disk-size "10" --boot-disk-type "pd-standard" --boot-disk-device-name "instance-template-1"

declare -a array=("us-central1-b" "us-east4-c" "us-west1-a" "europe-west2-b" "asia-southeast1-a" "australia-southeast1-a" "asia-east1-a" "europe-west3-a")
arraylength=${#array[@]}

for (( i=1; i<${arraylength}+1; i++ ));
do
  	( 
  		gcloud compute --project $PROJECT_ID instance-groups managed create "instance-group-$i" --zone ${array[$i-1]} --base-instance-name "instance-group-$i" --template "instance-template-1" --size "8"
	) &
done
wait
done





