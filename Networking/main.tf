resource "azurerm_resource_group" "VNETHUB" {
  name     = "vnethub"
  location = "Elsast US"

  tags = {
    environment = "Production"
  }
}