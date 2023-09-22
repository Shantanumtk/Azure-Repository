#!/bin/bash

RESOURCE_GROUP=$(az group list --query "[].name" --output tsv)
VM_IMAGE=Ubuntu2204
VM_NAME=UbuntuVM
VM_USERNAME=jumpserveruser
VM_PASSWORD_ENC=[Encrypted_Pass]
VM_PASSWORD_DEC=$(echo ${VM_PASSWORD_ENC} | base64 --d)
STORAGE=Standard_LRS
PUBLIC_SKU=Standard
VM_SIZE=Standard_B1s

#Function : VM Creation with Variables
VM_Variable_Creation(){
echo "======================================="
echo "Current Resource Group : ${RESOURCE_GROUP}"
echo "======================================="

echo "======================================="
echo "VM Creation With Below Variables"
echo "VM IMAGE : ${VM_IMAGE} "
echo "VM NAME : ${VM_NAME} "
echo "VM USERNAME : ${VM_USERNAME} "
echo "VM STORAGE : ${STORAGE} "
echo "VM PUBLIC_SKU : ${PUBLIC_SKU} "
echo "VM SIZE : ${VM_SIZE} "
echo "======================================="
}

#Function : VM Creation with az vm
AZ_VM_Creation(){

echo "VM : ${VM_NAME} Creation " 

az vm create \
-g ${RESOURCE_GROUP} \
--image ${VM_IMAGE}  \
--name ${VM_NAME} \
--admin-username ${VM_USERNAME} \
--admin-password ${VM_PASSWORD_DEC} \
--storage-sku ${STORAGE} \
--public-ip-sku ${PUBLIC_SKU} \
--size ${VM_SIZE}
}

#Function : Credentials for VM
VM_Credential(){
PUBLIC_IP=$(az vm show --show-details -g ${RESOURCE_GROUP} --name ${VM_NAME} --query publicIps --output tsv)

echo "======================================="
echo "Public IP of ${VM_NAME} ${PUBLIC_IP}"
echo "ssh ${VM_USERNAME}@${PUBLIC_IP}"
echo "======================================="
}

#Function : VM Status after creation
VM_Stats(){
VM_STATUS=$(az vm show -g ${RESOURCE_GROUP} -n ${VM_NAME} -d --query "powerState" --output tsv)
VM_PRO_STATE=$(az vm show -g ${RESOURCE_GROUP} -n ${VM_NAME} -d --query "provisioningState" --output tsv)

echo "======================================="
echo "<----- VM Status ----->"
echo "VM Provisioning State : ${VM_PRO_STATE}"
echo "VM Status : ${VM_STATUS}"
echo "======================================="
}


#Function Call
start_time=$(date +%s)
VM_Variable_Creation
AZ_VM_Creation
sleep 5
VM_Credential
VM_Stats
end_time=$(date +%s)

# Calculate the execution time
execution_time=$((end_time - start_time))

# Print the execution time
echo "Script executed in ${execution_time} seconds"