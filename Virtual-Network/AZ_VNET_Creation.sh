#!/bin/bash

RESOURCE_GROUP=$(az group list --query "[].name" --output tsv)
LOCATION=eastus
VNET_NAME=TutorialVNet1
SUBNET1_NAME=TutorialSubnet1
SUBNET2_NAME=TutorialSubnet2
VNET_ADDRESS_PREFIX=10.0.0.0/16
SUBNET_ADDRESS_PREFIX=10.0.0.0/24

#Function : VNET Creation 
AZ_VNET_CREATION() {
echo "======================================"
echo "VNET Creation"

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
  --resource-group $RESOURCE_GROUP \
  --name ${SUBNET1_NAME} \
  --vnet-name $VNET_NAME \
  --address-prefixes 10.0.0.0/24

az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --name ${SUBNET2_NAME} \
  --vnet-name $VNET_NAME \
  --address-prefixes 10.0.1.0/24

}

#Function : VNET Check 
VNET_CHECK() {
echo "======================================"
echo "<----- VNET Status ----->"
az network vnet show -g ODL-azure-1088701 -n TutorialVNet1 --query "{Name:name,ProvisioningState:provisioningState}" --output table
az network vnet show -g ODL-azure-1088701 -n TutorialVNet1 --query "subnets[].{Name:name, ProvisioningState:provisioningState}" --output table
echo "======================================"
}


#Function Calling 

echo "======================================="
echo "Current Resource Group : ${RESOURCE_GROUP}"
echo "======================================="

echo "======================================="
echo "VNET Creation With Below Variables"
echo "VNET LOCATION : ${LOCATION} "
echo "SUBNET 1 NAME : ${SUBNET1_NAME} "
echo "SUBNET 2 NAME : ${SUBNET2_NAME} "
echo "======================================="

AZ_VNET_CREATION
AZ_SUBNET_CREATION
sleep 5
VNET_CHECK