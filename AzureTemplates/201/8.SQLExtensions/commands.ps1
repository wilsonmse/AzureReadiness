#Add-AzAccount


$projectName = "armsql4"
$location = "eastus"

$resourceGroupName = "${projectName}rg"
$storageAccountName = "${projectName}store"
$containerName = "bacpacfiles"
$bacpacFileName = "SQLDatabaseExtension.bacpac"
$bacpacUrl = "https://github.com/Azure/azure-docs-json-samples/raw/master/tutorial-sql-extension/SQLDatabaseExtension.bacpac"

# Download the bacpac file
Invoke-WebRequest -Uri $bacpacUrl -OutFile "$HOME/$bacpacFileName"

# Create a resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create a storage account
$storageAccount = New-AzStorageAccount -ResourceGroupName $resourceGroupName `
                                       -Name $storageAccountName `
                                       -SkuName Standard_LRS `
                                       -Location $location

write-host "waiting for storageaccount to be created"
sleep 10
                     

$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName `
                                              -Name $storageAccountName).Value[0]

# Create a container
New-AzStorageContainer -Name $containerName -Context $storageAccount.Context

# Upload the BACPAC file to the container
Set-AzStorageBlobContent -File $HOME/$bacpacFileName `
                         -Container $containerName `
                         -Blob $bacpacFileName `
                         -Context $storageAccount.Context

$bacpacUrl = "https://$storageAccountName.blob.core.windows.net/$containerName/$bacpacFileName"

$tmp = ".\8.SQLExtensions\azuredeploy.json"
$tmppar = ".\8.SQLExtensions\azuredeployparameters.json"

New-AzResourceGroup -Name $resourceGroupName  -Location 'eastus'

New-AzResourceGroupDeployment `
  -Name LinkedTemplates `
  -ResourceGroupName $resourceGroupName `
  -TemplateFile $tmp `
  -TemplateParameterFile $tmppar `
  -bacpacurl $bacpacUrl `
  -storageAccountKey $storageAccountKey
  

