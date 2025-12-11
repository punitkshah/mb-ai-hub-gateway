using './main.bicep'

param environmentName = 'aihub-poc-nonprod'
param location = 'uaenorth'

param tags = {
  app_name: 'AI Hub POC'
  app_owner_1: 'Xi Liang'
  app_owner_1_email: 'XiL@mashreq.com'
  app_owner_2: 'Gyan Srivastava'
  app_owner_2_email: 'GyanS@mashreq.com'
  // asr_replication: 'NA'
  // business_criticality: 'NA'
  business_unit: 'bankwide'
  cost_center_code: 'CC 101 SUP 91701'
  enabler: 'data'
  environment: 'nonprod'
  expiry_date: '2026-02-10'
  iproc_number: 'NA'
  regulatory_compliance: 'NA'
  subscription: 'mashreq-uae-non-prod-ai'
  team_dl: 'XiL@mashreq.com'
  temporary_resource: 'yes'
}

param resourceGroupName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod'

param apimServiceName = 'az-uaenorth-aihub-apimgmt-poc'
param applicationInsightsDashboardName = 'az-uaenorth-aihub-appinsights-dashboard-poc'
param applicationInsightsName = 'az-uaenorth-aihub-appinsights-poc'
param eventHubNamespaceName = 'az-uaenorth-aihub-eventhub-poc'
param cosmosDbAccountName = 'az-uaenorth-aihub-cosmos-poc'
param usageProcessingLogicAppName = 'az-uaenorth-aihub-logicapp-poc'
param storageAccountName = 'azuaenaihubpoc'
param languageServiceName = 'az-uaenorth-aihub-language-poc'
param aiContentSafetyName = 'az-uaenorth-aihub-contentsafety-poc'


param vnetName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod'
param useExistingVnet = true
param existingVnetRG = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod'

// SUBNETS
param apimSubnetName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.apim'
param logicAppSubnetName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.logicapp1'

param redisPrivateEndpointSubnetName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.redis1'
param cosmosPrivateEndpointSubnetName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.cosmos'
param eventHubPrivateEndpointSubnetName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.eventhub'
param contentSafetyPrivateEndpointSubnetName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.aicontentsafe'
param languageApiPrivateEndpointSubnetName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.ailangforpii'
param storageAccountPrivateEndpointSubnetName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.sa'
param othersPrivateEndpointSubnetName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.others'

// NSG NAMES
param apimNsgName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.apim-nsg'
param logicAppNsgName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.logicapp1-nsg'

param cosmosPrivateEndpointNsgName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.cosmos-nsg'
param redisPrivateEndpointNsgName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.redis1-nsg'
param eventhubPrivateEndpointNsgName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.eventhub-nsg'
param contentSafetyPrivateEndpointNsgName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.aicontentsafe-nsg'
param languageApiPrivateEndpointNsgName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.ailangforpii-nsg'
param storageAccountPrivateEndpointNsgName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.sa-nsg'
param othersPrivateEndpointNsgName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.others-nsg'

param apimRouteTableName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod.rt'



// DNS zone params
param dnsZoneRG = 'internal.mashreq.azureuaenorth.management_prod'
param dnsSubscriptionId = '5fc28290-122a-4abb-bd5b-fdf29b6b116d'

// Private endpoint names
param storageBlobPrivateEndpointName = 'az-uaen-aihnpr-blob-poc-pep'
param storageFilePrivateEndpointName = 'az-uaen-aihnpr-file-poc-pep'
param storageTablePrivateEndpointName = 'az-uaen-aihnpr-table-poc-pep'
param storageQueuePrivateEndpointName = 'az-uaen-aihnpr-queue-poc-pep'

param eventHubPrivateEndpointName = 'az-uaenorth-aihub-eventhub-poc-pep'
param cosmosDbPrivateEndpointName = 'az-uaenorth-aihub-cosmos-poc-pep'
param languageServicePrivateEndpointName = 'az-uaenorth-aihub-language-poc-pep'
param aiContentSafetyPrivateEndpointName = 'az-uaenorth-aihub-contentsafety-poc-pep'
// param openAiPrivateEndpointName = 'pe-aoai-nonprod'
// param apimV2PrivateEndpointName = ''

// Network access configuration
param apimNetworkType = 'Internal'
// param apimV2UsePrivateEndpoint = false
param apimV2PublicNetworkAccess = false 

// param openAIExternalNetworkAccess = 'Disabled'
param cosmosDbPublicAccess = 'Disabled'
param eventHubNetworkAccess = 'Disabled'
param languageServiceExternalNetworkAccess = 'Disabled'
param aiContentSafetyExternalNetworkAccess = 'Disabled'

// param useAzureMonitorPrivateLinkScope = !useExistingVnet

// Feature flags
param createAppInsightsDashboard = false
param enableAIModelInference = true
param enableDocumentIntelligence = false
param enableAIGatewayPiiRedaction = false
param enableOpenAIRealtime = false


// SKUs / capacities
param apimSku = 'Premium'
param apimSkuUnits = 1
param eventHubCapacityUnits = 1
param cosmosDbRUs = 400
param logicAppsSkuCapacityUnits = 1
param languageServiceSkuName = 'S'
param aiContentSafetySkuName = 'S0'

// Shares
param functionContentShareName = 'usage-function-content'
param logicContentShareName = 'usage-logic-content'




param existingOpenAiAccountName  = 'internal-mashreq-aoai-nonprod'
param existingOpenAiResourceGroupName = 'az-uaenorth-dataplatform-openaiptu-common-nonprod'


//Exsiting Log Anaytics Workspace 
param existingLogAnalyticsWorkspaceName = 'internal-mashreq-azuaen-loganalytics-metrics-prod'
param existingLogAnalyticsWorkspaceResourceGroupName = 'internal.mashreq.azureuaenorth.aihub_poc_nonprod'

//Exsiting private link scope
param existingPrivateLinkScopeName = 'uaen-monitor-cit-ama-privatelinkscope_prod'
param existingPrivateLinkScopeRG = 'internal.mashreq.azureuaenorth.hubbridge.azuremonitor_prod'
//param existingPrivateLinkEndpoint = 'uaen-monitor-cit-ama-privatelinkscope_prod'
param existingPrivateLinkScopeSubId = '941f16d9-f54b-46c6-b20b-bd0ee942c63d'

param entraAuth = false
// below params required only if param entraAuth = true
param entraTenantId = ''
param entraClientId = ''
param entraAudience = ''

// Redis
param redisClusterName = 'az-uaenorth-aihub-redis-poc'
param skuName = 'Balanced_B10'
param redisPrivateEndpointName = 'az-uaenorth-aihub-redis-poc-pep'
param embeddingsDeploymentName = 'text-embedding-ada-002'

