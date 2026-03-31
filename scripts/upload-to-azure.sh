# upload-to-azure.sh

# Upload as a page blob (required for VHDs)
az storage blob upload \
  --account-name $STORAGE_ACCOUNT \
  --container-name $CONTAINER \
  --type page \
  --file "$VHD_NAME" \
  --name "$VHD_NAME"

VHD_URI="https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER}/${VHD_NAME}"

# Create a managed image from the VHD
az image create \
  --resource-group $RESOURCE_GROUP \
  --name "linuxmint-22-3" \
  --os-type Linux \
  --source "$VHD_URI" \
  --location $REGION \
  --hyper-v-generation V1