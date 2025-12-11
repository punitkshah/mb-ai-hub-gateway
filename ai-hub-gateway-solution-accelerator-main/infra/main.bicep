targetScope = 'subscription'

//
// BASIC PARAMETERS
//
@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources (filtered on available regions for Azure Open AI Service).')
@allowed([ 'uaenorth', 'southafricanorth', 'westeurope', 'southcentralus', 'australiaeast', 'canadaeast', 'eastus', 'eastus2', 'francecentral', 'japaneast', 'northcentralus', 'swedencentral', 'switzerlandnorth', 'uksouth' ])
param location string

@description('Tags to be applied to resources.')
param tags object

//
// RESOURCE NAMES - Assign custom names to different provisioned services
//
@description('Name of the resource group. Leave blank to use default naming conventions.')
param resourceGroupName string

@description('Name of the API Management service. Leave blank to use default naming conventions.')
param apimServiceName string


@description('Name of the Application Insights dashboard for APIM. Leave blank to use default naming conventions.')
param applicationInsightsDashboardName string

// @description('Name of the Application Insights dashboard for Function/Logic App. Leave blank to use default naming conventions.')
// param funcAplicationInsightsDashboardName string

@description('Name of the Application Insights for APIM resource. Leave blank to use default naming conventions.')
param applicationInsightsName string

// @description('Name of the Application Insights for Function/Logic App resource. Leave blank to use default naming conventions.')
// param funcApplicationInsightsName string

@description('Name of the Event Hub Namespace resource. Leave blank to use default naming conventions.')
param eventHubNamespaceName string

@description('Name of the Cosmos DB account resource. Leave blank to use default naming conventions.')
param cosmosDbAccountName string

@description('Name of the Logic App resource for usage processing. Leave blank to use default naming conventions.')
param usageProcessingLogicAppName string

@description('Name of the Storage Account. Leave blank to use default naming conventions.')
param storageAccountName string

@description('Name of the Azure Language service. Leave blank to use default naming conventions.')
param languageServiceName string

@description('Name of the Azure Content Safety service. Leave blank to use default naming conventions.')
param aiContentSafetyName string

//
// NETWORKING PARAMETERS - Network configuration and access controls
//
@description('Name of the Virtual Network. Leave blank to use default naming conventions.')
param vnetName string

@description('Use an existing Virtual Network instead of creating a new one.')
param useExistingVnet bool

@description('Resource group containing the existing VNet (only used when useExistingVnet is true).')
param existingVnetRG string

// SUBNETS
param apimSubnetName string
param logicAppSubnetName string

param redisPrivateEndpointSubnetName string
param cosmosPrivateEndpointSubnetName string
param eventHubPrivateEndpointSubnetName string
param contentSafetyPrivateEndpointSubnetName string
param languageApiPrivateEndpointSubnetName string
param storageAccountPrivateEndpointSubnetName string
param othersPrivateEndpointSubnetName string

// NSG NAMES
param apimNsgName string
param logicAppNsgName string

param cosmosPrivateEndpointNsgName string
param redisPrivateEndpointNsgName string
param eventhubPrivateEndpointNsgName string
param contentSafetyPrivateEndpointNsgName string
param languageApiPrivateEndpointNsgName string
param storageAccountPrivateEndpointNsgName string
param othersPrivateEndpointNsgName string

@description('Route Table name for API Management subnet. Leave blank to use default naming conventions.')
param apimRouteTableName string





// DNS ZONE PARAMETERS - DNS zone configuration for private endpoints (for use with existing VNet)
@description('Resource group containing the DNS zones (only used with existing VNet).')
param dnsZoneRG string

@description('Subscription ID containing the DNS zones (only used with existing VNet).')
param dnsSubscriptionId string

// PRIVATE ENDPOINTS - Names for private endpoints for various services
@description('Storage Blob private endpoint name. Leave blank to use default naming conventions.')
param storageBlobPrivateEndpointName string

@description('Storage File private endpoint name. Leave blank to use default naming conventions.')
param storageFilePrivateEndpointName string

@description('Storage Table private endpoint name. Leave blank to use default naming conventions.')
param storageTablePrivateEndpointName string

@description('Storage Queue private endpoint name. Leave blank to use default naming conventions.')
param storageQueuePrivateEndpointName string

@description('Cosmos DB private endpoint name. Leave blank to use default naming conventions.')
param cosmosDbPrivateEndpointName string

@description('Event Hub private endpoint name. Leave blank to use default naming conventions.')
param eventHubPrivateEndpointName string

// @description('Azure OpenAI private endpoint name. Leave blank to use default naming conventions.')
// param openAiPrivateEndpointName string

@description('Name of the Azure Language service private endpoint. Leave blank to use default naming conventions.')
param languageServicePrivateEndpointName string

@description('Name of the Azure Content Safety service private endpoint. Leave blank to use default naming conventions.')
param aiContentSafetyPrivateEndpointName string

// @description('API Management V2 private endpoint name. Leave blank to use default naming conventions.')
// param apimV2PrivateEndpointName string

// Services network access configuration
@description('Network type for API Management service. Applies only to Premium and Developer SKUs.')
@allowed([ 'External', 'Internal' ])
param apimNetworkType string

// @description('Use private endpoint for API Management service. Applies only to StandardV2 and PremiumV2 SKUs.')
// param apimV2UsePrivateEndpoint bool

@description('API Management service external network access. When false, APIM must have private endpoint.')
param apimV2PublicNetworkAccess bool

// @description('Azure OpenAI service public network access.')
// @allowed([ 'Enabled', 'Disabled' ])
// param openAIExternalNetworkAccess string

@description('Cosmos DB public network access.')
@allowed([ 'Enabled', 'Disabled' ])
param cosmosDbPublicAccess string

@description('Event Hub public network access.')
@allowed([ 'Enabled', 'Disabled' ])
param eventHubNetworkAccess string

@description('Azure Language service external network access.')
@allowed([ 'Enabled', 'Disabled' ])
param languageServiceExternalNetworkAccess string

@description('Azure Content Safety external network access.')
@allowed([ 'Enabled', 'Disabled' ])
param aiContentSafetyExternalNetworkAccess string


//
// FEATURE FLAGS - Deploy specific capabilities
//
@description('Create Application Insights dashboard.')
param createAppInsightsDashboard bool

@description('Enable AI Model Inference in API Management.')
param enableAIModelInference bool

@description('Enable Document Intelligence in API Management.')
param enableDocumentIntelligence bool


@description('Enable PII redaction in AI Gateway')
param enableAIGatewayPiiRedaction bool

@description('Enable OpenAI realtime capabilities')
param enableOpenAIRealtime bool

@description('Enable Microsoft Entra ID authentication for API Management.')
param entraAuth bool

//
// COMPUTE SKU & SIZE - SKUs and capacity settings for services
//
@description('API Management service SKU. Only Developer and Premium are supported.')
@allowed([ 'Developer', 'Premium', 'StandardV2', 'PremiumV2' ])
param apimSku string

@description('API Management service SKU units.')
param apimSkuUnits int


@description('Event Hub capacity units.')
param eventHubCapacityUnits int

@description('Cosmos DB throughput in Request Units (RUs).')
param cosmosDbRUs int

@description('Logic Apps SKU capacity units.')
param logicAppsSkuCapacityUnits int

@description('Azure Language service SKU name.')
param languageServiceSkuName string

@description('Azure Content Safety service SKU name.')
param aiContentSafetySkuName string

//
// ACCELERATOR SPECIFIC PARAMETERS - Additional parameters for the solution (should not be modified without careful consideration)
//
@description('Name of the Storage Account file share for Azure Function content.')
param functionContentShareName string

@description('Name of the Storage Account file share for Logic App content.')
param logicContentShareName string

// @description('OpenAI instances configuration - add more instances by modifying this object.')
// param openAiInstances object

@description('Microsoft Entra ID tenant ID for authentication (only used when entraAuth is true).')
param entraTenantId string

@description('Microsoft Entra ID client ID for authentication (only used when entraAuth is true).')
param entraClientId string

@description('Audience value for Microsoft Entra ID authentication (only used when entraAuth is true).')
param entraAudience string

// Load abbreviations from JSON file
var abbrs = loadJsonContent('./abbreviations.json')
// Generate a unique token for resources
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

var openAiPrivateDnsZoneName = 'privatelink.openai.azure.com'
var keyVaultPrivateDnsZoneName = 'privatelink.vaultcore.azure.net'
var monitorPrivateDnsZoneName = 'privatelink.monitor.azure.com'
var eventHubPrivateDnsZoneName = 'privatelink.servicebus.windows.net'
var cosmosDbPrivateDnsZoneName = 'privatelink.documents.azure.com'
var storageBlobPrivateDnsZoneName = 'privatelink.blob.core.windows.net'
var storageFilePrivateDnsZoneName = 'privatelink.file.core.windows.net'
var storageTablePrivateDnsZoneName = 'privatelink.table.core.windows.net'
var storageQueuePrivateDnsZoneName = 'privatelink.queue.core.windows.net'
var aiCogntiveServicesDnsZoneName = 'privatelink.cognitiveservices.azure.com'
var apimV2SkuDnsZoneName = 'privatelink.azure-api.net'
var redisPrivateDnsZoneName = 'privatelink.redis.azure.net'

//Existing Openai Resources 
@description('Name of the existing Azure OpenAI (Cognitive Services) account to reuse.')
param existingOpenAiAccountName string

@description('Resource group of the existing Azure OpenAI account. Defaults to the deployment RG.')
param existingOpenAiResourceGroupName string = resourceGroupName

//Existing Log analytics workspace 
@description('Name of the existing Log Analytics workspace to reuse.')
param existingLogAnalyticsWorkspaceName string

@description('Resource group of the existing Log Analytics workspace. Defaults to the deployment RG.')
param existingLogAnalyticsWorkspaceResourceGroupName string = resourceGroupName

param existingLogAnalyticsWorkspaceSubscriptionId string 


//Exsiting Private Link scope:
param existingPrivateLinkScopeName string 
param existingPrivateLinkScopeRG string 
param existingPrivateLinkScopeSubId string 


// Redis Parameters 
@description('Name of the embdedding deplyment to be used for caching')
param embeddingsDeploymentName string 

@description('name of the Redis Cluster')
param redisClusterName string

@description('Redis Enterprise SKU (Azure Managed Redis / Redis Enterprise).')
param skuName string

param redisPrivateEndpointName string

param apimApplicationInsightsSubscriptionId string 

module vnetExisting './modules/networking/vnet-existing.bicep' = if (useExistingVnet) {
  name: 'vnetExisting'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: vnetName
    apimSubnetName: apimSubnetName
    logicAppSubnetName: logicAppSubnetName
    redisPrivateEndpointSubnetName: redisPrivateEndpointSubnetName
    cosmosPrivateEndpointSubnetName: cosmosPrivateEndpointSubnetName
    eventHubPrivateEndpointSubnetName: eventHubPrivateEndpointSubnetName
    contentSafetyPrivateEndpointSubnetName: contentSafetyPrivateEndpointSubnetName
    languageApiPrivateEndpointSubnetName: languageApiPrivateEndpointSubnetName
    storageAccountPrivateEndpointSubnetName: storageAccountPrivateEndpointSubnetName
    vnetRG: existingVnetRG
  }
}

module monitoring './modules/monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    tags: tags
    apimApplicationInsightsSubscriptionId: apimApplicationInsightsSubscriptionId
    apimApplicationInsightsRgName: resourceGroupName
    privateLinkScopeName: existingPrivateLinkScopeName
    privateLinkScopeRgName: existingPrivateLinkScopeRG
    privateLinkScopeSubId: existingPrivateLinkScopeSubId
    logAnalyticsWorkspaceResourceId: existingLaw.id
    apimApplicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}apim-${resourceToken}'
    apimApplicationInsightsDashboardName: applicationInsightsDashboardName
    createDashboard: createAppInsightsDashboard
  }
  dependsOn: [
    vnetExisting
    existingLaw
  ]
}

resource existingOpenAi 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: existingOpenAiAccountName
  scope: resourceGroup(existingOpenAiResourceGroupName)
}

resource existingLaw 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: existingLogAnalyticsWorkspaceName
  scope: resourceGroup(existingLogAnalyticsWorkspaceSubscriptionId, existingLogAnalyticsWorkspaceResourceGroupName)
} 


module contentSafety 'modules/ai/cognitiveservices.bicep' = {
  name: 'ai-content-safety'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: !empty(aiContentSafetyName) ? aiContentSafetyName : '${abbrs.cognitiveServicesAccounts}consafety-${resourceToken}'
    location: location
    tags: tags
    kind: 'ContentSafety'
    vNetName: vnetExisting.outputs.vnetName
    vNetLocation: vnetExisting.outputs.location
    privateEndpointSubnetName: vnetExisting.outputs.contentSafetyPrivateEndpointSubnetName
    aiPrivateEndpointName: aiContentSafetyPrivateEndpointName
    publicNetworkAccess: aiContentSafetyExternalNetworkAccess
    openAiDnsZoneName: aiCogntiveServicesDnsZoneName
    sku: {
      name: aiContentSafetySkuName
    }
    vNetRG: vnetExisting.outputs.vnetRG
    dnsZoneRG: dnsZoneRG
    dnsSubscriptionId: dnsSubscriptionId
  }
  dependsOn: [
    vnetExisting
  ]
}

module languageService 'modules/ai/cognitiveservices.bicep' = {
  name: 'ai-language-service'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: languageServiceName
    location: location
    tags: tags
    kind: 'TextAnalytics'
    vNetName: vnetExisting.outputs.vnetName
    vNetLocation: vnetExisting.outputs.location
    privateEndpointSubnetName: vnetExisting.outputs.languageApiPrivateEndpointSubnetName
    aiPrivateEndpointName: !empty(languageServicePrivateEndpointName) ? languageServicePrivateEndpointName : '${abbrs.cognitiveServicesAccounts}language-pe-${resourceToken}'
    publicNetworkAccess: languageServiceExternalNetworkAccess
    openAiDnsZoneName: aiCogntiveServicesDnsZoneName
    sku: {
      name: languageServiceSkuName
    }
    vNetRG: vnetExisting.outputs.vnetRG
    dnsZoneRG: dnsZoneRG
    dnsSubscriptionId: dnsSubscriptionId
  }
  dependsOn: [
    vnetExisting
  ]
}

module eventHub './modules/event-hub/event-hub.bicep' = {
  name: 'event-hub'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: eventHubNamespaceName
    location: location
    tags: tags
    eventHubPrivateEndpointName: !empty(eventHubPrivateEndpointName) ? eventHubPrivateEndpointName : '${abbrs.eventHubNamespaces}pe-${resourceToken}'
    vNetName: vnetExisting.outputs.vnetName
    privateEndpointSubnetName: vnetExisting.outputs.eventHubPrivateEndpointSubnetName
    eventHubDnsZoneName: eventHubPrivateDnsZoneName
    publicNetworkAccess: eventHubNetworkAccess
    vNetRG: vnetExisting.outputs.vnetRG
    dnsZoneRG: dnsZoneRG
    dnsSubscriptionId: dnsSubscriptionId
    capacity: eventHubCapacityUnits
  }
  dependsOn: [
    vnetExisting
  ]
}

module apim './modules/apim/apim.bicep' = {
  name: 'apim'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: apimServiceName
    location: location
    tags: tags
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    openAiUris: [existingOpenAi.properties.endpoint]
    // openAiUris: [for i in range(0, length(openAiInstances)): openAis[i].outputs.openAiEndpointUri]
    entraAuth: entraAuth
    clientAppId: entraAuth ? entraClientId : null
    tenantId: entraAuth ? entraTenantId : null
    audience: entraAuth ? entraAudience : null
    eventHubName: eventHub.outputs.eventHubName
    eventHubEndpoint: eventHub.outputs.eventHubEndpoint
    eventHubPIIName: eventHub.outputs.eventHubPIIName
    eventHubConnectionString:eventHub.outputs.eventHubConnectionString  // eventHub.outputs.eventHubEndpoint
    apimSubnetId: vnetExisting.outputs.apimSubnetId
    aiLanguageServiceUrl: languageService.outputs.aiServiceEndpoint
    contentSafetyServiceUrl: contentSafety.outputs.aiServiceEndpoint
    apimNetworkType: apimNetworkType
    enablePIIAnonymization: enableAIGatewayPiiRedaction
    enableAIModelInference: enableAIModelInference
    enableDocumentIntelligence: enableDocumentIntelligence
    enableOpenAIRealtime: enableOpenAIRealtime
    sku: apimSku
    skuCount: apimSkuUnits
    apimV2PublicNetworkAccess: apimV2PublicNetworkAccess
    enableSemanticCaching: true
    semanticCacheName: 'default' // recommended
    semanticCacheConnectionString: redisConnectionString
    embeddingsDeploymentName: embeddingsDeploymentName
    embeddingsBackendId: 'embeddings-backend'
    eventHubNamespaceName: eventHub.outputs.eventHubNamespaceName
  }
  dependsOn: [
    vnetExisting
    eventHub
    redis
    redisKeys
  ]
}


module apimSemCache './modules/apim/apim-semcache.bicep' = {
  name: 'apim-semcache'
  scope: resourceGroup(resourceGroupName)
  params: {
    apimName: apim.outputs.apimName
    redisConnectionString: redisConnectionString
    openAiEndpoint: existingOpenAi.properties.endpoint
    embeddingsDeploymentName: embeddingsDeploymentName
  }
  dependsOn: [
    apim
    redis
    redisKeys
  ]
}

module cosmosDb './modules/cosmos-db/cosmos-db.bicep' = {
  name: 'cosmos-db'
  scope: resourceGroup(resourceGroupName)
  params: {
    accountName: cosmosDbAccountName
    location:location
    tags: tags
    vNetName: vnetExisting.outputs.vnetName
    cosmosDnsZoneName: cosmosDbPrivateDnsZoneName
    cosmosPrivateEndpointName: !empty(cosmosDbPrivateEndpointName) ? cosmosDbPrivateEndpointName : '${abbrs.documentDBDatabaseAccounts}pe-${resourceToken}'
    privateEndpointSubnetName: vnetExisting.outputs.cosmosPrivateEndpointSubnetName
    vNetRG: vnetExisting.outputs.vnetRG
    dnsZoneRG: dnsZoneRG
    dnsSubscriptionId: dnsSubscriptionId
    throughput: cosmosDbRUs
    publicAccess: cosmosDbPublicAccess
  }
  dependsOn: [
    vnetExisting
  ]
}

module storageAccount './modules/functionapp/storageaccount.bicep' = {
  name: 'storage'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    tags: tags
    storageAccountName: storageAccountName
    vNetName: vnetExisting.outputs.vnetName
    privateEndpointSubnetName: vnetExisting.outputs.storageAccountPrivateEndpointSubnetName
    storageBlobDnsZoneName: storageBlobPrivateDnsZoneName
    storageFileDnsZoneName: storageFilePrivateDnsZoneName
    storageTableDnsZoneName: storageTablePrivateDnsZoneName
    storageQueueDnsZoneName: storageQueuePrivateDnsZoneName
    storageBlobPrivateEndpointName: !empty(storageBlobPrivateEndpointName) ? storageBlobPrivateEndpointName : '${abbrs.storageStorageAccounts}blob-pe-${resourceToken}'
    storageFilePrivateEndpointName: !empty(storageFilePrivateEndpointName) ? storageFilePrivateEndpointName : '${abbrs.storageStorageAccounts}file-pe-${resourceToken}'
    storageTablePrivateEndpointName: !empty(storageTablePrivateEndpointName) ? storageTablePrivateEndpointName : '${abbrs.storageStorageAccounts}table-pe-${resourceToken}'
    storageQueuePrivateEndpointName: !empty(storageQueuePrivateEndpointName) ? storageQueuePrivateEndpointName : '${abbrs.storageStorageAccounts}queue-pe-${resourceToken}'
    functionContentShareName: functionContentShareName
    logicContentShareName: logicContentShareName
    vNetRG: vnetExisting.outputs.vnetRG
    dnsZoneRG: dnsZoneRG
    dnsSubscriptionId: dnsSubscriptionId
  }
  dependsOn: [
    vnetExisting
  ]
}

module logicApp './modules/logicapp/logicapp.bicep' = {
  name: 'usageLogicApp'
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    tags: tags
    logicAppName: usageProcessingLogicAppName
    azdserviceName: 'usageProcessingLogicApp'
    storageAccountName: storageAccount.outputs.storageAccountName
    // applicationInsightsName: monitoring.outputs.funcApplicationInsightsName
    skuFamily: 'WS'
    skuName: 'WS1'
    skuCapaicty: logicAppsSkuCapacityUnits
    skuSize: 'WS1'
    skuTier: 'WorkflowStandard'
    isReserved: false
    cosmosDbAccountName: cosmosDb.outputs.cosmosDbAccountName
    eventHubName: eventHub.outputs.eventHubName
    eventHubNamespaceName: eventHub.outputs.eventHubNamespaceName
    cosmosDBDatabaseName: cosmosDb.outputs.cosmosDbDatabaseName
    cosmosDBContainerConfigName: cosmosDb.outputs.cosmosDbStreamingExportConfigContainerName
    cosmosDBContainerUsageName: cosmosDb.outputs.cosmosDbContainerName
    cosmosDBContainerPIIName: cosmosDb.outputs.cosmosDbPiiUsageContainerName
    eventHubPIIName: eventHub.outputs.eventHubPIIName
    apimAppInsightsName: monitoring.outputs.applicationInsightsName
    functionAppSubnetId: vnetExisting.outputs.logicAppSubnetId
    fileShareName: logicContentShareName
  }
  dependsOn: [
    vnetExisting
    storageAccount
    monitoring
    eventHub
    cosmosDb
  ]
}

module redis './modules/redis-managed/redis-managed.bicep' = {
  name: 'redis-semcache'
  scope: resourceGroup(resourceGroupName) // Explicitly set the scope to the target resource group and subscription
  params: {
    location: location
    redisClusterName: redisClusterName
    redisDatabaseName: 'default'
    skuName: skuName
    vNetName: vnetExisting.outputs.vnetName
    privateEndpointSubnetName: vnetExisting.outputs.redisPrivateEndpointSubnetName
    redisPrivateDnsZoneName: redisPrivateDnsZoneName
    redisPrivateEndpointName: redisPrivateEndpointName
    vNetRG: vnetExisting.outputs.vnetRG
    dnsZoneRG: dnsZoneRG
    dnsSubscriptionId: dnsSubscriptionId
    publicNetworkAccess: 'Disabled'
    tags: {
      workload: 'apim-semcache'
    }
  }
}


module redisKeys './modules/redis-managed/get-redis-enterprise-keys.bicep' = {
  name: 'redis-keys'
  scope: resourceGroup(resourceGroupName)
  params: {
    clusterName: redisClusterName
    databaseName: 'default'
  }
  dependsOn: [
    redis
  ]
}

var redisAccessKey = redisKeys.outputs.primaryKey
var redisConnectionString = '${redis.outputs.redisHostName}:10000,password=${redisAccessKey},ssl=True,abortConnect=False'




module rbac './modules/rbacs/rbac-system-identities.bicep' = {
  name: 'rbac'
  scope: resourceGroup(resourceGroupName)
  params: {
    name: 'rbac'
    location: location
    tags: tags
    apimPrincipalId: apim.outputs.apimPrincipalId
    logicAppPrincipalId: logicApp.outputs.logicAppPrincipalId
  }
  dependsOn: [
    apim
    logicApp
  ]
}

module logicAppRbac './modules/rbacs/workload-access.bicep' = {
  name: 'logicapp-rbac'
  scope: resourceGroup(resourceGroupName)
  params: {
    principalResourceId: logicApp.outputs.logicAppId
    principalId: logicApp.outputs.logicAppPrincipalId
    cosmosDbAccountName: cosmosDb.outputs.cosmosDbAccountName
    storageAccountName:storageAccountName
    assignCosmosSqlContributor: true
    assignEventHubsDataOwner: true
    tags: tags
  }
  dependsOn: [
    logicApp
    cosmosDb
  ]
}

// module apimRbac './modules/rbacs/workload-access.bicep' = {
//   name: 'apim-rbac'
//   scope: resourceGroup(resourceGroupName)
//   params: {
//     principalResourceId: apim.outputs.apimId
//     principalId: apim.outputs.apimPrincipalId
//     cosmosDbAccountName: cosmosDb.outputs.cosmosDbAccountName
//     assignCosmosSqlContributor: false
//     assignEventHubsDataOwner: true
//     tags: tags
//   }
//   dependsOn: [
//     apim
//     cosmosDb
//   ]
// }



output APIM_NAME string = apim.outputs.apimName
output APIM_AOI_PATH string = apim.outputs.apimOpenaiApiPath
output APIM_GATEWAY_URL string = apim.outputs.apimGatewayUrl
