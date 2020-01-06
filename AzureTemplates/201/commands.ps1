add-azurermaccount


$projectName = "armsql"
$location = "eastus"

$resourceGroupName = "${projectName}rg"
$storageAccountName = "${projectName}store"
$containerName = "bacpacfiles"
$bacpacFileName = "SQLDatabaseExtension.bacpac"
$bacpacUrl = "https://github.com/Azure/azure-docs-json-samples/raw/master/tutorial-sql-extension/SQLDatabaseExtension.bacpac"

# Download the bacpac file
Invoke-WebRequest -Uri $bacpacUrl -OutFile "$HOME/$bacpacFileName"

# Create a resource group
New-AzurermResourceGroup -Name $resourceGroupName -Location $location

# Create a storage account
$storageAccount = New-AzurermStorageAccount -ResourceGroupName $resourceGroupName `
                                       -Name $storageAccountName `
                                       -SkuName Standard_LRS `
                                       -Location $location
$storageAccountKey = (Get-AzurermStorageAccountKey -ResourceGroupName $resourceGroupName `
                                              -Name $storageAccountName).Value[0]

# Create a container
New-AzurermStorageContainer -Name $containerName -Context $storageAccount.Context

# Upload the BACPAC file to the container
Set-AzurermStorageBlobContent -File $HOME/$bacpacFileName `
                         -Container $containerName `
                         -Blob $bacpacFileName `
                         -Context $storageAccount.Context

$bacpacUrl = "https://$storageAccountName.blob.core.windows.net/$containerName/$bacpacFileName"

$tmp = ".\8.SQLExtensions\azuredeploy.json"
$tmppar = ".\8.SQLExtensions\azuredeployparameters.json"

New-AzureRmResourceGroup -Name $rg -Location 'eastus'

New-AzurermResourceGroupDeployment `
  -Name LinkedTemplates `
  -ResourceGroupName $rg `
  -TemplateFile $tmp `
  -TemplateParameterFile $tmppar
  -bacpacurl $bacpacUrl
  -storageAccountKey $storageAccountKey
  

