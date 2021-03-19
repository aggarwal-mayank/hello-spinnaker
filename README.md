Tutorial: https://codeburst.io/spinnaker-by-example-part-1-c4de9180d689

Get K8s Versions available for installation

`gcloud container get-server-config --zone europe-west3-a`

Get k8s credentials

`gcloud container clusters get-credentials my-cluster --region europe-west3`

extract the authentication token for this spinnaker service account

`kubectl get secret \
  $(kubectl get serviceaccount spinnaker-service-account \
    -n spinnaker \
    -o jsonpath='{.secrets[0].name}') \
 -n spinnaker \
 -o jsonpath='{.data.token}' | base64 --decode`

Generate CA crt file
echo [REPLACE] | base64 -d > ca.crt

Copy CA crt file
gcloud compute scp ca.crt halyard:/home/mayank/ca.crt

Create User(spinnaker-SA) and Context Manually in k8s

kubectl config set-cluster my-cluster \
  --server=https://34.107.41.107 \
  --certificate-authority=ca.crt \
  --embed-certs=true

kubectl config set-credentials spinnaker-service-account \
  --token=[REPLACE]  

kubectl config set-context spinnaker-service-account@my-cluster \
  --user=spinnaker-service-account \
  --cluster=my-cluster

kubectl config use-context spinnaker-service-account@my-cluster  

Enable K8s Provider in Halyard

`hal config provider kubernetes enable`

Add spinnaker-SA to halyard enabling it to deploy to the GKE cluster

hal config provider kubernetes account add spinnaker-service-account@my-cluster \
  --context spinnaker-service-account@my-cluster

We have not installed Spinnaker yet; we have been configuring Halyard.
Now we move on to installing spinnaker,
For k8s we choose a `distributed` installation

hal config deploy edit \
  --type distributed \
  --account-name spinnaker-service-account@my-cluster

We also need to configure GCS (storage that spinnaker will use)
So we have created a GCP SA with storage admin role in gcp/tf project now we just get the key which we would pass on to Halyard

gcloud iam service-accounts keys create account.json --iam-account spinnaker@spinnaker-step-by-step.iam.gserviceaccount.com

Copy it over to Halyard
gcloud compute scp account.json halyard:/home/mayank/account.json

SSH to halyard
Test the activation goes fine
gcloud auth activate-service-account spinnaker@spinnaker-step-by-step.iam.gserviceaccount.com \
  --key-file=account.json

Configure Halyard to use this Storage option, this command creates a GCS bucket 

hal config storage gcs edit \
  --project $(gcloud config get-value project) \
  --bucket-location eu \
  --json-path account.json

Get available versions

`hal config storage edit --type gcs`

Finally install Spinnaker

hal config version edit \
  --version 1.25.2

`hal deploy apply`


Reconnect with port mapping

gcloud compute ssh halyard \
  -- -L 9000:localhost:9000 -L 8084:localhost:8084

`hal deploy connect`

open spinnaker on localhost:9000

Part2 : https://codeburst.io/spinnaker-by-example-part-2-6f92a1fdaedf

We change the spin-deck and spin-gate services from clusterIP to LoadBalancer to make them accessible 
over internet, this can be done by k8s service edit commands only

kubectl edit service spin-gate -n spinnaker

kubectl edit service spin-deck -n spinnaker

But these internally talk to each other on localhost endpoints, so to fix that we need to configure HAL

for spin-deck
`hal config security ui edit --override-base-url http://35.242.251.50:9000`  
for spin-gate
`hal config security api edit --override-base-url http://35.242.209.93:8084`

Run the deploy again
`hal deploy apply`

Part 3: https://codeburst.io/spinnaker-by-example-part-3-c6ed9ac5f8ce

