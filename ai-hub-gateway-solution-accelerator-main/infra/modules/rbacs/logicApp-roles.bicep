param tags object = {}

@description('Resource ID of the workload that owns the system-assigned identity (e.g., APIM, Logic App, Function App). Used only to generate deterministic roleAssignment names.')
param principalResourceId string

@description('Principal (object) ID of the workload system-assigned identity.')
param principalId string

@description('Cosmos DB account name that the workload needs SQL RBAC on.')
param cosmosDbAccountName string

@description('Name of the Storage Account')
param storageAccountName string 

// https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#storage-blob-data-owner
var storageBlobDataOwnerRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')

var docDbAccNativeContributorRoleDefinitionId = '00000000-0000-0000-0000-000000000002'
var eventHubsDataOwnerRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'f526a384-b230-433a-b45c-95f59c4a2dec')
var eventHubsDataSenderRoleDefinitionId         = resourceId('Microsoft.Authorization/roleDefinitions', '2b629674-e913-4c01-ae53-ef4638d8f975')

// App Insights Component Contributor (RG scope)
// https://learn.microsoft.com/azure/role-based-access-control/built-in-roles/monitor#application-insights-component-contributor
var appInsightsComponentContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions','ae349356-3a1b-4a5e-921d-050484c6347e')


resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' existing = {
  name: cosmosDbAccountName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// Cosmos SQL RBAC role assignment (under the Cosmos account)
resource cosmosSqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-04-15' = {
  name: guid(cosmosDbAccount.id, principalResourceId, docDbAccNativeContributorRoleDefinitionId)
  parent: cosmosDbAccount
  properties: {
    principalId: principalId
    roleDefinitionId: '/${cosmosDbAccount.id}/sqlRoleDefinitions/${docDbAccNativeContributorRoleDefinitionId}'
    scope: cosmosDbAccount.id
  }
}

// Event Hubs Data Owner (resourceGroup scope)
resource eventHubsDataOwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' ={
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



resource eventHubsDataSenderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalResourceId, eventHubsDataSenderRoleDefinitionId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: eventHubsDataSenderRoleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}



resource appInsightsComponentContributorAtRg 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalResourceId, appInsightsComponentContributorRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: appInsightsComponentContributorRoleId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
