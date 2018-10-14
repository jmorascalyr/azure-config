clear
echo -e '   ___|                |
 \___ \    __|   _` |  |  |   |   __|
       |  (     (   |  |  |   |  |
 _____/  \___| \__,_| _| \__, | _|    
                         ____/        '

# Change these four parameters as needed
ACI_RANDOM=$RANDOM &>/dev/null
ACI_APPNAME=testContainer$ACI_RANDOM &>/dev/null
ACI_SUBSCRIPTION=Sandbox &>/dev/null
ACI_PERS_RESOURCE_GROUP=$ACI_APPNAME &>/dev/null
ACI_PERS_STORAGE_ACCOUNT_NAME=$ACI_PERS_RESOURCE_GROUP$ACI_APPNAME &>/dev/null
ACI_PERS_LOCATION=eastus &>/dev/null
ACI_PERS_SHARE_NAME=source &>/dev/null
ACI_APP_SERVICE_PLAN=$ACI_APPNAME &>/dev/null
ACI_SQL=database$ACI_APPNAME &>/dev/null
ACI_FIREWALL=firewallrule$ACI_RANDOM &>/dev/null
WORDPRESS_DB_NAME=wordpress &>/dev/null
WORDPRESS_DB_HOST=$ACI_SQL.mysql.database.azure.com &>/dev/null
WORDPRESS_DB_PASSWORD=My5up3rStr0ngPaSw0rd! &>/dev/null
WORDPRESS_DB_USER=$WORDPRESS_DB_NAME@$ACI_SQL &>/dev/null
cd ~ &>/dev/null
rm -rf container &>/dev/null
mkdir container &>/dev/null
cd container &>/dev/null
git clone https://github.com/jmorascalyr/azure-config &>/dev/null
cd azure-config &>/dev/null
echo Code pulled from Github

#Create APP SERVICE ELEMENTS
az group create --name $ACI_PERS_RESOURCE_GROUP --location "$ACI_PERS_LOCATION" &>/dev/null

echo Resource Group Created - $ACI_PERS_RESOURCE_GROUP

az appservice plan create --name $ACI_APP_SERVICE_PLAN --resource-group $ACI_PERS_RESOURCE_GROUP --sku S1 --is-linux &>/dev/null

echo Service Plan Created in the Resource Group 


az webapp create --resource-group $ACI_PERS_RESOURCE_GROUP --plan $ACI_APP_SERVICE_PLAN --name $ACI_APPNAME --multicontainer-config-type kube --multicontainer-config-file docker-compose-scalyr.yml &>/dev/null

echo webapp created

#PERSISTENT STORAGE
az webapp config appsettings set  --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=TRUE &>/dev/null

echo persistent storage has been setup
az webapp log config --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --docker-container-logging filesystem
echo logging has been enabled 
# az extension add -n webapp
# az extension update -n webapp
# az webapp remote-connection create -g $ACI_PERS_RESOURCE_GROUP -n $ACI_PERS_RESOURCE_GROUP -p 9000


#UPDATE WEBAPP
az webapp config container set --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-scalyr.yml &>/dev/null
echo Deploying YAML file 

echo Opening app....
open -a "Google Chrome" https://$ACI_APPNAME.azurewebsites.net
open -a "Google Chrome" https://portal.azure.com/#@jmorascalyr.onmicrosoft.com/resource/subscriptions/b4838979-2175-4154-84cf-177b9a7d43db/resourceGroups/$ACI_PERS_RESOURCE_GROUP/providers/Microsoft.Web/sites/$ACI_PERS_RESOURCE_GROUP/appServices
echo app created. Would you like to tear it down? Y or N
read yn

if [ "$yn" = "Y" ]; then
  az group delete --name $ACI_PERS_RESOURCE_GROUP
fi

