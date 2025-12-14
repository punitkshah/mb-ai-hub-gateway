param logicAppName string

param tags object = {}
param azdserviceName string

param storageAccountName string
param fileShareName string

// param applicationInsightsName string

param location string = resourceGroup().location

param skuName string
param skuFamily string
param skuSize string
param skuCapaicty int
param skuTier string
param isReserved bool

param cosmosDbAccountName string

param functionAppSubnetId string

param dotnetFrameworkVersion string = 'v6.0'

var docDbAccNativeContributorRoleDefinitionId = '00000000-0000-0000-0000-000000000002'
var eventHubsDataOwnerRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'f526a384-b230-433a-b45c-95f59c4a2dec')
var azureMonitorLogsRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '43d0d8ad-25c7-4714-9337-8ba259a9fe05')
var storageBlobDataOwnerRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')

resource logicAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${logicAppName}-identity'
  location: location
  tags: tags
}

param eventHubNamespaceName string
param eventHubName string
param eventHubPIIName string

param cosmosDBDatabaseName string
param cosmosDBContainerConfigName string
param cosmosDBContainerUsageName string
param cosmosDBContainerPIIName string

param apimAppInsightsName string

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' existing = {
  name: cosmosDbAccountName
}

// resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
//   name: applicationInsightsName
// }

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

//var storageAccountConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'

resource hostingPlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'hosting-plan-${logicAppName}'
  tags: union(tags, { 'azd-service-name': 'hosting-plan-${logicAppName}' })
  location: location
  sku: {
    name: skuName
    tier: skuTier
    family: skuFamily
    size: skuSize
    capacity: skuCapaicty
  }
  kind: 'elastic'
  properties: {
    maximumElasticWorkerCount: 20
    reserved: isReserved
  }
}

resource logicApp 'Microsoft.Web/sites@2024-04-01' = {
  name: logicAppName
  location: location
  kind: 'functionapp,workflowapp'
  tags: union(tags, { 'azd-service-name': azdserviceName })
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${logicAppIdentity.id}': {}
    }
  }
  properties: {
    enabled: true
    serverFarmId: hostingPlan.id
    reserved: isReserved
    virtualNetworkSubnetId: functionAppSubnetId
  }
}

resource networkConfig 'Microsoft.Web/sites/networkConfig@2024-04-01' = {
  parent: logicApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: functionAppSubnetId
    swiftSupported: true
  }
}

resource functionAppSiteConfig 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: logicApp
  name: 'web'
  properties: {
    detailedErrorLoggingEnabled: true
    vnetRouteAllEnabled: true
    ftpsState: 'FtpsOnly'
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    minimumElasticInstanceCount: 1
    publicNetworkAccess: 'Enabled'
    functionsRuntimeScaleMonitoringEnabled: true
    netFrameworkVersion: dotnetFrameworkVersion
    preWarmedInstanceCount: 1
    keyVaultReferenceIdentity: logicAppIdentity.id
    cors: {
      allowedOrigins: [
        'https://portal.azure.com'
        'https://ms.portal.azure.com'
      ]
      supportCredentials: false
    }
  }
  // dependsOn: [
  //   applicationInsights
  // ]
}

module azureMonitorConnection 'api-connection.json' = {
  name: 'azuremonitorlogs-conn'
  params: {
    connection_name: 'azuremonitorlogs'
    display_name: 'conn-azure-monitor'
    location: location
  }
}

resource functionAppSettings 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: logicApp
  name: 'appsettings'
  properties: {
    // APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString
    AzureWebJobsStorage__accountName: storageAccount.name
    AzureWebJobsStorage__credential: 'managedidentity'
    AzureWebJobsStorage__clientId: logicAppIdentity.properties.clientId
    FUNCTIONS_EXTENSION_VERSION: '~4'
    FUNCTIONS_WORKER_RUNTIME: 'node'
    WEBSITE_NODE_DEFAULT_VERSION: '~20'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING__accountName: storageAccount.name
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING__credential: 'managedidentity'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING__clientId: logicAppIdentity.properties.clientId
    WEBSITE_VNET_ROUTE_ALL: '1'
    WEBSITE_CONTENTOVERVNET: '1'
    WEBSITE_RUN_FROM_PACKAGE: '0'
    
    // Azure Functions uses this to determine which MI to use for storage/blobs
    AZURE_CLIENT_ID: logicAppIdentity.properties.clientId

    eventHub_fullyQualifiedNamespace: '${eventHubNamespaceName}.servicebus.windows.net'
    eventHub_name: eventHubName
    eventHub_pii_name: eventHubPIIName

    APP_KIND: 'workflowapp'
    AzureFunctionsJobHost_extensionBundle: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'

    CosmosDBAccount: cosmosDbAccount.name
    CosmosDBDatabase: cosmosDBDatabaseName
    CosmosDBContainerConfig: cosmosDBContainerConfigName
    CosmosDBContainerUsage: cosmosDBContainerUsageName
    CosmosDBContainerPII: cosmosDBContainerPIIName

    // NOTE: You are still using a Cosmos connection string here.
    // If you want MI-only, we can remove this and switch runtime bindings/auth accordingly.
    AzureCosmosDB_connectionString: cosmosDbAccount.listConnectionStrings().connectionStrings[0].connectionString

    AppInsights_SubscriptionId: subscription().subscriptionId
    AppInsights_ResourceGroup: resourceGroup().name
    AppInsights_Name: apimAppInsightsName

    AzureMonitor_Resource_Id: azureMonitorConnection.outputs.resourceId
    AzureMonitor_Api_Id: azureMonitorConnection.outputs.apiId
    AzureMonitor_ConnectRuntime_Url: azureMonitorConnection.outputs.connectRuntimeUrl
  }
  dependsOn: [
    storageAccount
    azureMonitorConnection
  ]
}

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-04-15' = {
  name: guid(cosmosDbAccount.id, logicApp.id, 'system-identity', docDbAccNativeContributorRoleDefinitionId)
  parent: cosmosDbAccount
  properties: {
    principalId: logicApp.identity.principalId
    roleDefinitionId: '/${cosmosDbAccount.id}/sqlRoleDefinitions/${docDbAccNativeContributorRoleDefinitionId}'
    scope: cosmosDbAccount.id
  }
}

// Storage Blob Data Owner for Logic App user-assigned identity
resource storageBlobDataOwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, logicAppIdentity.id, 'user-identity', storageBlobDataOwnerRoleDefinitionId)
  scope: storageAccount
  properties: {
    roleDefinitionId: storageBlobDataOwnerRoleDefinitionId
    principalId: logicAppIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Event Hubs Data Owner for Logic App system identity
resource eventHubsDataOwnerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, logicApp.id, 'eventhub-system', eventHubsDataOwnerRoleDefinitionId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: eventHubsDataOwnerRoleDefinitionId
    principalId: logicApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    logicApp
  ]
}

resource azureMonitorReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, logicApp.id, azureMonitorLogsRoleDefinitionId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: azureMonitorLogsRoleDefinitionId
    principalId: logicApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
  dependsOn: [
    logicApp
  ]
}



// Commented out: This module frequently fails with InternalServerError
// The access policy can be created manually or after initial deployment succeeds
module azureMonitorConnectionAccess 'api-connection-access.bicep' = {
  name: 'azuremonitorlogs-access'
  params: {
    connectionName: 'azuremonitorlogs'
    accessPolicyName: 'azuremonitorlogs-access'
    identityPrincipalId: logicApp.identity.principalId
    location: location
  }
  dependsOn: [
    azureMonitorConnection
    logicApp
  ]
}



@description('Logic App name')
output logicAppName string = logicApp.name

@description('Logic App resource id')
output logicAppId string = logicApp.id

@description('System-assigned managed identity principalId (use this for RBAC from main.bicep)')
output logicAppPrincipalId string = logicApp.identity.principalId
