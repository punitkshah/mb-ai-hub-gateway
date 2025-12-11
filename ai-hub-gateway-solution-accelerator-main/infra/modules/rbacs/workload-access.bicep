param tags object = {}

@description('Resource ID of the workload that owns the system-assigned identity (e.g., APIM, Logic App, Function App). Used only to generate deterministic roleAssignment names.')
param principalResourceId string

@description('Principal (object) ID of the workload system-assigned identity.')
param principalId string

@description('Cosmos DB account name that the workload needs SQL RBAC on.')
param cosmosDbAccountName string

@description('Assign Cosmos DB built-in Data Contributor (SQL role definition 000...002).')
param assignCosmosSqlContributor bool = true

@description('Assign Event Hubs Data Owner at resourceGroup scope.')
param assignEventHubsDataOwner bool = true

@description('Name of the Storage Account')
param storageAccountName string 

// https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#storage-blob-data-owner
var storageBlobDataOwnerRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')

var docDbAccNativeContributorRoleDefinitionId = '00000000-0000-0000-0000-000000000002'
var eventHubsDataOwnerRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'f526a384-b230-433a-b45c-95f59c4a2dec')

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' existing = {
  name: cosmosDbAccountName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// Cosmos SQL RBAC role assignment (under the Cosmos account)
resource cosmosSqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-04-15' = if (assignCosmosSqlContributor) {
  name: guid(cosmosDbAccount.id, principalResourceId, docDbAccNativeContributorRoleDefinitionId)
  parent: cosmosDbAccount
  properties: {
    principalId: principalId
    roleDefinitionId: '/${cosmosDbAccount.id}/sqlRoleDefinitions/${docDbAccNativeContributorRoleDefinitionId}'
    scope: cosmosDbAccount.id
  }
}

// Event Hubs Data Owner (resourceGroup scope)
resource eventHubsDataOwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (assignEventHubsDataOwner) {
  name: guid(resourceGroup().id, principalResourceId, eventHubsDataOwnerRoleDefinitionId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: eventHubsDataOwnerRoleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}


//storage blob data owner 
resource storageAccountFunctionAppRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, principalResourceId, storageBlobDataOwnerRoleId)
  properties: {
    principalId: principalId 
    roleDefinitionId: storageBlobDataOwnerRoleId
  }
  scope: storageAccount
}
