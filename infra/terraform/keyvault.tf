resource "azurerm_key_vault" "example" {
  name                        = "akv-${local.name}"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enable_rbac_authorization   = true
}

resource "azurerm_role_assignment" "example_akv_rbac" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Administrator"
  scope                = azurerm_key_vault.example.id
}

resource "azurerm_key_vault_secret" "openai_key" {
  count        = local.deploy_azure_openai ? 1 : 0
  name         = "AZURE-OPENAI-KEY"
  value        = azurerm_cognitive_account.example[0].primary_access_key
  key_vault_id = azurerm_key_vault.example.id
  depends_on   = [azurerm_role_assignment.example_akv_rbac]
}

resource "azurerm_key_vault_secret" "cosmosdb_key" {
  count        = local.deploy_azure_cosmosdb ? 1 : 0
  name         = "AZURE-COSMOS-KEY"
  value        = azurerm_cosmosdb_account.example[0].primary_key
  key_vault_id = azurerm_key_vault.example.id
  depends_on   = [azurerm_role_assignment.example_akv_rbac]
}

resource "azurerm_key_vault_secret" "listener_key" {
  count        = local.deploy_azure_servicebus ? 1 : 0
  name         = "AZURE-SERVICE-BUS-LISTENER-KEY"
  value        = azurerm_servicebus_namespace_authorization_rule.example[0].primary_key
  key_vault_id = azurerm_key_vault.example.id
  depends_on   = [azurerm_role_assignment.example_akv_rbac]
}

resource "azurerm_key_vault_secret" "sender_key" {
  count        = local.deploy_azure_servicebus ? 1 : 0
  name         = "AZURE-SERVICE-BUS-SENDER-KEY"
  value        = azurerm_servicebus_queue_authorization_rule.example[0].primary_key
  key_vault_id = azurerm_key_vault.example.id
  depends_on   = [azurerm_role_assignment.example_akv_rbac]
}
