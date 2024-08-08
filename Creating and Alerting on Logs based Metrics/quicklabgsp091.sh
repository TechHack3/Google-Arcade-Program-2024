



gcloud config set compute/zone $ZONE

export PROJECT_ID=$(gcloud info --format='value(config.project)')


gcloud container clusters create gmp-cluster --num-nodes=1 --zone $ZONE

gcloud logging metrics create stopped-vm \
    --description="Metric for stopped VMs" \
    --log-filter='resource.type="gce_instance" protoPayload.methodName="v1.compute.instances.stop"'




# Create a Pub/Sub notification channel
cat > pubsub-channel.json <<EOF_END
{
  "type": "pubsub",
  "displayName": "quicklab",
  "description": "Subscribe to quicklab",
  "labels": {
    "topic": "projects/$DEVSHELL_PROJECT_ID/topics/notificationTopic"
  }
}
EOF_END

# Create the Pub/Sub notification channel
gcloud beta monitoring channels create --channel-content-from-file=pubsub-channel.json

# Get the channel ID
email_channel_info=$(gcloud beta monitoring channels list)
email_channel_id=$(echo "$email_channel_info" | grep -oP 'name: \K[^ ]+' | head -n 1)

# Create an email notification channel

# Create the alert policy
cat > stopped-vm-alert-policy.json <<EOF_END
{
  "displayName": "stopped vm",
  "documentation": {
    "content": "Documentation content for the stopped vm alert policy",
    "mime_type": "text/markdown"
  },
  "userLabels": {},
  "conditions": [
    {
      "displayName": "Log match condition",
      "conditionMatchedLog": {
        "filter": "resource.type=\"gce_instance\" protoPayload.methodName=\"v1.compute.instances.stop\""
      }
    }
  ],
  "alertStrategy": {
    "notificationRateLimit": {
      "period": "300s"
    },
    "autoClose": "3600s"
  },
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [
    "$email_channel_id"
  ]
}


EOF_END

# Create the alert policy
gcloud alpha monitoring policies create --policy-from-file=stopped-vm-alert-policy.json


gcloud compute instances stop instance1 --zone=us-central1-a --quiet

sleep 30

gcloud container clusters get-credentials gmp-cluster

kubectl create ns gmp-test

kubectl -n gmp-test apply -f https://storage.googleapis.com/spls/gsp091/gmp_flask_deployment.yaml

kubectl -n gmp-test apply -f https://storage.googleapis.com/spls/gsp091/gmp_flask_service.yaml

kubectl get services -n gmp-test


gcloud logging metrics create hello-app-error \
    --description="Metric for hello-app errors" \
    --log-filter='severity=ERROR
resource.labels.container_name="hello-app"
textPayload: "ERROR: 404 Error page not found"' 





# Create the alert policy
cat > quicklab.json <<'EOF_END'
{
  "displayName": "log based metric alert",
  "userLabels": {},
  "conditions": [
    {
      "displayName": "New condition",
      "conditionThreshold": {
        "filter": 'metric.type="logging.googleapis.com/user/hello-app-error" AND resource.type="global"',
        "aggregations": [
          {
            "alignmentPeriod": "120s",
            "crossSeriesReducer": "REDUCE_SUM",
            "perSeriesAligner": "ALIGN_DELTA"
          }
        ],
        "comparison": "COMPARISON_GT",
        "duration": "0s",
        "trigger": {
          "count": 1
        }
      }
    }
  ],
  "alertStrategy": {
    "autoClose": "604800s"
  },
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [],
  "severity": "SEVERITY_UNSPECIFIED"
}

EOF_END

# Create the alert policy
gcloud alpha monitoring policies create --policy-from-file=quicklab.json



timeout 120 bash -c -- 'while true; do curl $(kubectl get services -n gmp-test -o jsonpath='{.items[*].status.loadBalancer.ingress[0].ip}')/error; sleep $((RANDOM % 4)) ; done'
