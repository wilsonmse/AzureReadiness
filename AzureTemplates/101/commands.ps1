add-azurermaccount


$rg = "myResourceGroup"
$tmp = ".\azuredeploy.json"

New-AzurermResourceGroupDeployment `
  -Name addtags `
  -ResourceGroupName $rg `
  -TemplateFile $tmp `
  -storagePrefix "store" `
  -storageSKU Standard_LRS `
  -webAppName demoapp



  new-azurermresou