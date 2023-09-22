#!/bin/bash

RESOURCE_GROUP=$(az group list --query "[].name" --output tsv)

VM1_IMAGE=Ubuntu2204
VM1_NAME=Frontend_VM
VM1_USERNAME=frontend_user
VM1_PASSWORD_ENC=TGVjTWF4IzIwMjQxCg==
VM1_PASSWORD_DEC=$(echo ${VM1_PASSWORD_ENC} | base64 --d)
VM1_STORAGE=Standard_LRS
VM1_PUBLIC_SKU=Standard
VM1_SIZE=Standard_B1s

VM2_IMAGE=Ubuntu2204
VM2_NAME=Backend_VM
VM2_USERNAME=backend_user
VM2_PASSWORD_ENC=TGVjTWF4IzIwMjQxCg==
VM2_PASSWORD_DEC=$(echo ${VM2_PASSWORD_ENC} | base64 --d)
VM2_STORAGE=Standard_LRS
VM2_PUBLIC_SKU=Standard
VM2_SIZE=Standard_B1s

LOCATION=westus
VNET_NAME=Project_VNet
SUBNET1_NAME=Frontend_Subnet
SUBNET2_NAME=Backend_Subnet

#Function : VNET Creation 
AZ_VNET_CREATION() {

echo "======================================="
echo "Current Resource Group : ${RESOURCE_GROUP}"
echo "======================================="

echo "======================================="
echo "VNET Creation With Below Variables"
echo "VNET LOCATION : ${LOCATION} "
echo "SUBNET 1 NAME : ${SUBNET1_NAME} "
echo "SUBNET 2 NAME : ${SUBNET2_NAME} "
echo "======================================="

az network vnet create \
  -g ${RESOURCE_GROUP} \
  --location ${LOCATION} \
  --name $VNET_NAME \
  --address-prefix "10.0.0.0/16"
}

#Function : SUBNET Creation 
AZ_SUBNET_CREATION() {
echo "======================================"
echo "Subnet Creation"

az network vnet subnet create \
  --resource-group ${RESOURCE_GROUP} \
  --name ${SUBNET1_NAME} \
  --vnet-name ${VNET_NAME} \
  --address-prefixes 10.0.1.0/24

az network vnet subnet create \
  --resource-group ${RESOURCE_GROUP} \
  --name ${SUBNET2_NAME} \
  --vnet-name ${VNET_NAME} \
  --address-prefixes 10.0.2.0/24
}

#Function : VNET Check 
VNET_CHECK() {
echo "======================================"
echo "<----- VNET Status ----->"
az network vnet show -g ${RESOURCE_GROUP} -n ${VNET_NAME} --query "{Name:name,ProvisioningState:provisioningState}" --output table
az network vnet show -g ${RESOURCE_GROUP} -n ${VNET_NAME} --query "subnets[].{Name:name, ProvisioningState:provisioningState}" --output table
echo "<----- VNET Status ----->"
echo "======================================"
}

#Function : VM Creation
AZ_VM_Creation() {
echo "======================================" 
echo "VM 1 Creation" 

az vm create \
-g ${RESOURCE_GROUP} \
--image ${VM1_IMAGE}  \
--name ${VM1_NAME} \
--admin-username ${VM1_USERNAME} \
--admin-password ${VM1_PASSWORD_DEC} \
--storage-sku ${VM1_STORAGE} \
--public-ip-sku ${VM1_PUBLIC_SKU} \
--size ${VM1_SIZE} \
--vnet-name ${VNET_NAME} \
--subnet ${SUBNET1_NAME} \
--verbose

echo "======================================" 
echo "VM 2 Creation" 

az vm create \
-g ${RESOURCE_GROUP} \
--image ${VM2_IMAGE}  \
--name ${VM2_NAME} \
--admin-username ${VM2_USERNAME} \
--admin-password ${VM2_PASSWORD_DEC} \
--storage-sku ${VM2_STORAGE} \
--public-ip-sku ${VM2_PUBLIC_SKU} \
--size ${VM2_SIZE} \
--vnet-name ${VNET_NAME} \
--subnet ${SUBNET2_NAME} \
--verbose
}


#Function : Credentials for VM
VM_Credential(){
VM1_PUBLIC_IP=$(az vm show --show-details -g ${RESOURCE_GROUP} --name ${VM1_NAME} --query publicIps --output tsv)

echo "======================================="
echo "Public IP of ${VM1_NAME} ${VM1_PUBLIC_IP}"
echo "ssh ${VM1_USERNAME}@${VM1_PUBLIC_IP}"
echo "======================================="

VM2_PUBLIC_IP=$(az vm show --show-details -g ${RESOURCE_GROUP} --name ${VM2_NAME} --query publicIps --output tsv)

echo "======================================="
echo "Public IP of ${VM2_NAME} ${VM2_PUBLIC_IP}"
echo "ssh ${VM2_USERNAME}@${VM2_PUBLIC_IP}"
echo "======================================="

}

#Function : VM Status after creation
VM_Stats(){
VM1_STATUS=$(az vm show -g ${RESOURCE_GROUP} -n ${VM1_NAME} -d --query "powerState" --output tsv)
VM1_PRO_STATE=$(az vm show -g ${RESOURCE_GROUP} -n ${VM1_NAME} -d --query "provisioningState" --output tsv)

VM2_STATUS=$(az vm show -g ${RESOURCE_GROUP} -n ${VM2_NAME} -d --query "powerState" --output tsv)
VM2_PRO_STATE=$(az vm show -g ${RESOURCE_GROUP} -n ${VM2_NAME} -d --query "provisioningState" --output tsv)

echo "======================================"
echo "<----- VM Status ----->"
echo "VM 1 Provisioning State : ${VM1_PRO_STATE}"
echo "VM Status : ${VM1_STATUS}"
echo "VM 2 Provisioning State : ${VM2_PRO_STATE}"
echo "VM Status : ${VM2_STATUS}"
echo "======================================"
}

#Function Calling 
start_time=$(date +%s)
AZ_VNET_CREATION
AZ_SUBNET_CREATION
sleep 5
VNET_CHECK
AZ_VM_Creation
sleep 5
VM_Stats
VM_Credential
end_time=$(date +%s)

# Calculate the execution time
execution_time=$((end_time - start_time))

# Print the execution time
echo "Script executed in ${execution_time} seconds"
