param name string
param location string = resourceGroup().location
param tags object = {}
param entraAuth bool = false

@minLength(1)
param publisherEmail string = 'noreply@microsoft.com'

@minLength(1)
param publisherName string = 'n/a'

param sku string = 'Developer'
var isV2SKU = sku == 'StandardV2' || sku == 'PremiumV2'
param skuCount int = 1
param applicationInsightsName string
param openAiUris array

param clientAppId string = ' '
param tenantId string = tenant().tenantId
param audience string = 'https://cognitiveservices.azure.com/.default'

param eventHubName string
param eventHubNamespaceName string
param eventHubEndpoint string

param eventHubPIIName string
// param eventHubPIIEndpoint string
param eventHubConnectionString string


param enableAIModelInference bool = false 
param enableOpenAIRealtime bool = false 
param enableDocumentIntelligence bool = false 
param enablePIIAnonymization bool = false 

param contentSafetyServiceUrl string
param aiLanguageServiceUrl string


//APIM EH Sender RBAC params
var eventHubsDataSenderRoleDefinitionId string = resourceId('Microsoft.Authorization/roleDefinitions', '2b629674-e913-4c01-ae53-ef4638d8f975')

// For semantic caching 

@description('Enable semantic caching for Azure OpenAI API.')
param enableSemanticCaching bool = true

@description('APIM external cache entity name. Use "default" unless you have multi-region caches.')
param semanticCacheName string = 'default'

@secure()
@description('Redis connection string used by APIM external cache.')
param semanticCacheConnectionString string

// @description('Azure OpenAI embeddings deployment name used for semantic caching.')
// param embeddingsDeploymentName string

@description('APIM backend id used by semantic cache lookup policy for embeddings calls.')
param embeddingsBackendId string = 'embeddings-backend'


// Networking
param apimNetworkType string = 'External'
param apimSubnetId string

param apimV2PrivateDnsZoneName string = 'privatelink.azure-api.net'
// param apimV2PrivateEndpointName string
// param dnsZoneRG string = resourceGroup().name
// param dnsSubscriptionId string = subscription().subscriptionId
// param privateEndpointSubnetId string
// param usePrivateEndpoint bool = false
param apimV2PublicNetworkAccess bool = false 
var apimPublicNetworkAccess = apimV2PublicNetworkAccess ? 'Enabled' : 'Disabled'

var openAiApiBackendId = 'openai-backend'
var openAiApiEntraNamedValue = 'entra-auth'
var openAiApiClientNamedValue = 'client-id'
var openAiApiTenantNamedValue = 'tenant-id'
var openAiApiAudienceNamedValue = 'audience'

var apiManagementMinApiVersion = '2021-08-01'
var apiManagementMinApiVersionV2 = '2024-05-01'

// Premium zone logic
var apimZones = (sku == 'Premium' && skuCount > 1) ? (skuCount == 2 ? ['1','2'] : ['1','2','3']) : []

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

// Commented out: These existing resources were causing segment length errors and are no longer needed
// since we use the parameter names directly in the logger credentials
// resource eventHub 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' existing = {
//   name: eventHubName
// }
//
// resource eventHubPII 'Microsoft.EventHub/namespaces/eventhubs@2023-01-01-preview' existing = {
//   name: eventHubPIIName
// }

resource apimService 'Microsoft.ApiManagement/service@2024-05-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': name })
  sku: {
    name: sku
    capacity: (sku == 'Consumption') ? 0 : ((sku == 'Developer') ? 1 : skuCount)
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkType: isV2SKU ? 'External' : apimNetworkType
    publicNetworkAccess: isV2SKU ? apimPublicNetworkAccess : 'Enabled'
    virtualNetworkConfiguration: apimNetworkType != 'None' || isV2SKU ? {
      subnetResourceId: apimSubnetId
    } : null
    apiVersionConstraint: {
      minApiVersion: isV2SKU ? apiManagementMinApiVersionV2 : apiManagementMinApiVersion
    }
    // Custom properties are not supported for Consumption SKU
    customProperties: sku == 'Consumption' ? {} : {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'false'
    }
  }
  zones: apimZones
}



module apimOpenaiApi './api.bicep' = {
  name: 'azure-openai-service-api'
  params: {
    serviceName: apimService.name
    apiName: 'azure-openai-service-api'
    path: 'openai'
    apiRevision: '1'
    apiDispalyName: 'Azure OpenAI API'
    subscriptionRequired: entraAuth ? false : true
    subscriptionKeyName: 'api-key'
    openApiSpecification: string(loadYamlContent('./openai-api/oai-api-spec-2024-10-21.yaml'))
    apiDescription: 'Azure OpenAI API'
    policyDocument: loadTextContent('./policies/openai_api_policy.xml')
    enableAPIDeployment: true
  }
  dependsOn: [
    aadAuthPolicyFragment
    validateRoutesPolicyFragment
    backendRoutingPolicyFragment
    openAIUsagePolicyFragment
    openAIUsageStreamingPolicyFragment
    openAiBackends
    throttlingEventsPolicyFragment
    dynamicThrottlingAssignmentFragment
   //for semantic caching 
   semanticCacheLookupFragment
   semanticCacheStoreFragment
  ]
}


module apimAiModelInferenceApi './api.bicep' = if (enableAIModelInference) {
  name: 'ai-model-inference-api'
  params: {
    serviceName: apimService.name
    apiName: 'ai-model-inference-api'
    path: 'models'
    apiRevision: '1'
    apiDispalyName: 'AI Model Inference API'
    subscriptionRequired: entraAuth ? false : true
    subscriptionKeyName: 'api-key'
    openApiSpecification: loadTextContent('./ai-model-inference/ai-model-inference-api-spec.yaml')
    apiDescription: 'Access to AI inference models published through Azure AI Foundry'
    policyDocument: loadTextContent('./policies/ai-model-inference-api-policy.xml')
    enableAPIDeployment: true
  }
  dependsOn: [
    aadAuthPolicyFragment
    validateRoutesPolicyFragment
    backendRoutingPolicyFragment
    aiUsagePolicyFragment
    throttlingEventsPolicyFragment
  ]
}

module apimOpenAIRealTimetApi './api.bicep' = if (enableOpenAIRealtime) {
  name: 'openai-realtime-ws-api'
  params: {
    serviceName: apimService.name
    apiName: 'openai-realtime-ws-api'
    path: 'openai/realtime'
    apiRevision: '1'
    apiDispalyName: 'Azure OpenAI Realtime API'
    subscriptionRequired: entraAuth ? false : true
    subscriptionKeyName: 'api-key'
    openApiSpecification: 'NA'
    apiDescription: 'Access Azure OpenAI Realtime API for real-time voice and text conversion.'
    policyDocument: loadTextContent('./policies/openai-realtime-policy.xml')
    enableAPIDeployment: true
    serviceUrl: 'wss://to-be-replaced-by-policy'
    apiType: 'websocket'
    apiProtocols: ['wss']
  }
  dependsOn: [
    aadAuthPolicyFragment
    validateRoutesPolicyFragment
    backendRoutingPolicyFragment
    openAIUsagePolicyFragment
    openAIUsageStreamingPolicyFragment
    openAiBackends
  ]
}

module apimDocumentIntelligenceLegacy './api.bicep' = if (enableDocumentIntelligence) {
  name: 'document-intelligence-api-legacy'
  params: {
    serviceName: apimService.name
    apiName: 'document-intelligence-api-legacy'
    path: 'formrecognizer'
    apiRevision: '1'
    apiDispalyName: 'Document Intelligence API (Legacy)'
    subscriptionRequired: entraAuth ? false : true
    subscriptionKeyName: 'Ocp-Apim-Subscription-Key'
    openApiSpecification: loadTextContent('./doc-intel-api/document-intelligence-2024-11-30-compressed.openapi.yaml')
    apiDescription: 'Uses (/formrecognizer) url path. Extracts content, layout, and structured data from documents.'
    policyDocument: loadTextContent('./policies/doc-intelligence-api-policy.xml')
    enableAPIDeployment: true
  }
  dependsOn: [
    aadAuthPolicyFragment
    validateRoutesPolicyFragment
    backendRoutingPolicyFragment
    aiUsagePolicyFragment
    throttlingEventsPolicyFragment
  ]
}

module apimDocumentIntelligence './api.bicep' = if (enableDocumentIntelligence) {
  name: 'document-intelligence-api'
  params: {
    serviceName: apimService.name
    apiName: 'document-intelligence-api'
    path: 'documentintelligence'
    apiRevision: '1'
    apiDispalyName: 'Document Intelligence API'
    subscriptionRequired: entraAuth ? false : true
    subscriptionKeyName: 'Ocp-Apim-Subscription-Key'
    openApiSpecification: loadTextContent('./doc-intel-api/document-intelligence-2024-11-30-compressed.openapi.yaml')
    apiDescription: 'Uses (/documentintelligence) url path. Extracts content, layout, and structured data from documents.'
    policyDocument: loadTextContent('./policies/doc-intelligence-api-policy.xml')
    enableAPIDeployment: true
  }
  dependsOn: [
    aadAuthPolicyFragment
    validateRoutesPolicyFragment
    backendRoutingPolicyFragment
    aiUsagePolicyFragment
    throttlingEventsPolicyFragment
  ]
}

// Backends
resource openAiBackends 'Microsoft.ApiManagement/service/backends@2022-08-01' = [for (openAiUri, i) in openAiUris: {
  name: '${openAiApiBackendId}-${i}'
  parent: apimService
  properties: {
    description: openAiApiBackendId
    url: openAiUri
    protocol: 'http'
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}]



resource contentSafetyBackend 'Microsoft.ApiManagement/service/backends@2022-08-01' = {
  name: 'content-safety-backend'
  parent: apimService
  properties: {
    description: 'Content Safety Service Backend'
    url: contentSafetyServiceUrl
    protocol: 'http'
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
  }
}

// Named Values (Entra + client details)
resource apiopenAiApiEntraNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = {
  name: openAiApiEntraNamedValue
  parent: apimService
  properties: {
    displayName: openAiApiEntraNamedValue
    secret: false
    value: entraAuth
  }
}

resource apiopenAiApiClientNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = {
  name: openAiApiClientNamedValue
  parent: apimService
  properties: {
    displayName: openAiApiClientNamedValue
    secret: true
    value: clientAppId
  }
}

resource apiopenAiApiTenantNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' = {
  name: openAiApiTenantNamedValue
  parent: apimService
  properties: {
    displayName: openAiApiTenantNamedValue
    secret: true
    value: tenantId
  }
}

resource apimOpenaiApiAudienceNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' =  {
  name: openAiApiAudienceNamedValue
  parent: apimService
  properties: {
    displayName: openAiApiAudienceNamedValue
    secret: true
    value: audience
  }
}

resource piiServiceUrlNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' =  {
  name: 'piiServiceUrl'
  parent: apimService
  properties: {
    displayName: 'piiServiceUrl'
    secret: false
    value: aiLanguageServiceUrl
  }
}

resource piiServiceKeyNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' =  {
  name: 'piiServiceKey'
  parent: apimService
  properties: {
    displayName: 'piiServiceKey'
    secret: true
    value: 'replace-with-language-service-key-if-needed'
  }
}

resource contentSafetyServiceUrlNamedValue 'Microsoft.ApiManagement/service/namedValues@2022-08-01' =  {
  name: 'contentSafetyServiceUrl'
  parent: apimService
  properties: {
    displayName: 'contentSafetyServiceUrl'
    secret: false
    value: contentSafetyServiceUrl
  }
}

// Policy Fragments
resource aadAuthPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
  parent: apimService
  name: 'aad-auth'
  properties: {
    value: loadTextContent('./policies/frag-aad-auth.xml')
    format: 'rawxml'
  }
  dependsOn: [
    apiopenAiApiClientNamedValue
    apiopenAiApiEntraNamedValue
    apimOpenaiApiAudienceNamedValue
    apiopenAiApiTenantNamedValue
  ]
}

resource validateRoutesPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
  parent: apimService
  name: 'validate-routes'
  properties: {
    value: loadTextContent('./policies/frag-validate-routes.xml')
    format: 'rawxml'
  }
}

resource backendRoutingPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
  parent: apimService
  name: 'backend-routing'
  properties: {
    value: loadTextContent('./policies/frag-backend-routing.xml')
    format: 'rawxml'
  }
}

resource openAIUsagePolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
  parent: apimService
  name: 'openai-usage'
  properties: {
    value: loadTextContent('./policies/frag-openai-usage.xml')
    format: 'rawxml'
  }
  dependsOn: [
    ehUsageLogger
  ]
}

resource openAIUsageStreamingPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
  parent: apimService
  name: 'openai-usage-streaming'
  properties: {
    value: loadTextContent('./policies/frag-openai-usage-streaming.xml')
    format: 'rawxml'
  }
}

resource aiUsagePolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
  parent: apimService
  name: 'ai-usage'
  properties: {
    value: loadTextContent('./policies/frag-ai-usage.xml')
    format: 'rawxml'
  }
  dependsOn: [
    ehUsageLogger
  ]
}

resource throttlingEventsPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
  parent: apimService
  name: 'throttling-events'
  properties: {
    value: loadTextContent('./policies/frag-throttling-events.xml')
    format: 'rawxml'
  }
}

resource dynamicThrottlingAssignmentFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
  parent: apimService
  name: 'dynamic-throttling-assignment'
  properties: {
    value: loadTextContent('./policies/frag-dynamic-throttling-assignment.xml')
    format: 'rawxml'
  }
}

resource piiAnonymizationPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
  parent: apimService
  name: 'pii-anonymization'
  properties: {
    value: loadTextContent('./policies/frag-pii-anonymization.xml')
    format: 'rawxml'
  }
  dependsOn: [
    piiServiceUrlNamedValue
    piiServiceKeyNamedValue
  ]
}

resource piiDenonymizationPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
  parent: apimService
  name: 'pii-deanonymization'
  properties: {
    value: loadTextContent('./policies/frag-pii-deanonymization.xml')
    format: 'rawxml'
  }
}

resource piiStateSavingPolicyFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = if (enablePIIAnonymization) {
  parent: apimService
  name: 'pii-state-saving'
  properties: {
    value: loadTextContent('./policies/frag-pii-state-saving.xml')
    format: 'rawxml'
  }
  dependsOn: [
    ehPIIUsageLogger
  ]
}

// Diagnostics/Logger
resource apimLogger 'Microsoft.ApiManagement/service/loggers@2022-08-01' = {
  name: 'appinsights-logger'
  parent: apimService
  properties: {
    credentials: {
      instrumentationKey: applicationInsights.properties.InstrumentationKey
    }
    description: 'Application Insights logger for API observability'
    isBuffered: false
    loggerType: 'applicationInsights'
    resourceId: applicationInsights.id
  }
}

resource apimAppInsights 'Microsoft.ApiManagement/service/diagnostics@2022-08-01' = {
  parent: apimService
  name: 'applicationinsights'
  properties: {
    alwaysLog: 'allErrors'
    httpCorrelationProtocol: 'Legacy'
    verbosity: 'information'
    logClientIp: true
    loggerId: apimLogger.id
    metrics: true
    sampling: {
      samplingType: 'fixed'
      percentage: 100
    }
    frontend: {
      request: { body: { bytes: 0 } }
      response: { body: { bytes: 0 } }
    }
    backend: {
      request: { body: { bytes: 0 } }
      response: { body: { bytes: 0 } }
    }
  }
}

// Event Hub Loggers - System Assigned Identity (no identityClientId needed)
resource apimEventHubsSender 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, eventHubsDataSenderRoleDefinitionId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: eventHubsDataSenderRoleDefinitionId
    principalId: apimService.identity.principalId
    principalType: 'ServicePrincipal'
  }
}


var ehEpNoScheme = replace(eventHubEndpoint, 'https://', '')
var ehEpNoPort   = replace(ehEpNoScheme, ':443/', '')
var eventHubHost = replace(ehEpNoPort, '/', '')   // final: "az-uaenorth-aihub-eventhub-poc.servicebus.windows.net"
 
resource ehUsageLogger 'Microsoft.ApiManagement/service/loggers@2022-08-01' = {
  name: 'usage-eventhub-logger'
  parent: apimService
  properties: {
    loggerType: 'azureEventHub'
    description: 'Event Hub logger for OpenAI usage metrics'
    credentials: {
      name: eventHubName
      endpointAddress: eventHubHost
      identityClientId: 'systemAssigned'
    }
  }
  dependsOn: [
     apimEventHubsSender
  ]
}


resource ehPIIUsageLogger 'Microsoft.ApiManagement/service/loggers@2022-08-01' = if (enablePIIAnonymization) {
  name: 'pii-usage-eventhub-logger'
  parent: apimService
  properties: {
    loggerType: 'azureEventHub'
    description: 'Event Hub logger for PII usage metrics and logs'
    credentials: {
      name: eventHubPIIName
      // endpointAddress: replace(eventHubPIIEndpoint, 'https://', '')
      connectionString: eventHubEndpoint
      // System Assigned MI is used implicitly by APIM
    }
  }
}


//Redis Cache for Semantic Caching

param embeddingsDeploymentUrl string 

// 1) External cache (Redis)
resource externalCache 'Microsoft.ApiManagement/service/caches@2024-05-01' = if (enableSemanticCaching) {
  parent: apimService
  name: semanticCacheName
  properties: {
    connectionString: semanticCacheConnectionString
    useFromLocation: 'default'
    description: 'Redis external cache for semantic caching'
  }
}

// 2) Embeddings backend with Managed Identity auth
// NOTE: Using nested deployment because managedIdentity credentials aren’t consistently supported in Bicep typings.
// 2) Embeddings backend with MI auth (nested deployment workaround)
resource embeddingsBackendMi 'Microsoft.Resources/deployments@2021-04-01' = if (enableSemanticCaching) {
  name: '${apimService.name}-embeddings-backend-mi'
  properties: {
    mode: 'Incremental'

    // Pass values from the outer template into the nested template explicitly
    parameters: {
      apimName: {
        value: apimService.name
      }
      embeddingsBackendId: {
        value: embeddingsBackendId
      }
      embeddingsDeploymentUrl: {
        value: embeddingsDeploymentUrl
      }
    }

    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'

      // Declare nested template parameters
      parameters: {
        apimName: { type: 'string' }
        embeddingsBackendId: { type: 'string' }
        embeddingsDeploymentUrl: { type: 'string' }
      }

      resources: [
        {
          type: 'Microsoft.ApiManagement/service/backends'
          apiVersion: '2024-05-01'
          name: '[format(\'{0}/{1}\', parameters(\'apimName\'), parameters(\'embeddingsBackendId\'))]'
          properties: {
            title: '[parameters(\'embeddingsBackendId\')]'
            description: 'Embeddings backend for semantic cache'
            url: '[parameters(\'embeddingsDeploymentUrl\')]'
            protocol: 'http'
            tls: {
              validateCertificateChain: true
              validateCertificateName: true
            }
            credentials: {
              header: {}
              query: {}
              managedIdentity: {
                resource: 'https://cognitiveservices.azure.com/'
              }
            }
          }
        }
      ]
    }
  }
}


// Policy Fragments for semantic caching 

// 3) Policy fragments
resource semanticCacheLookupFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = if (enableSemanticCaching) {
  parent: apimService
  name: 'semantic-cache-lookup'
  properties: {
    format: 'rawxml'
    value: '''
<fragment>
  <choose>
    <when condition="@(!context.Request.Headers.GetValueOrDefault("Accept","").Contains("text/event-stream")
      && ((context.Request.Url.Path ?? "").Contains("/chat/completions") || (context.Request.Url.Path ?? "").Contains("/responses")))">
      <azure-openai-semantic-cache-lookup
          score-threshold="0.05"
          embeddings-backend-id="${embeddingsBackendId}"
          embeddings-backend-auth="system-assigned"
          ignore-system-messages="true"
          max-message-count="10">
        <vary-by>@(context.Subscription?.Id ?? "no-sub")</vary-by>
        <vary-by>@(context.Request.Url.Path)</vary-by>
      </azure-openai-semantic-cache-lookup>
    </when>
  </choose>
</fragment>
'''
  }
  dependsOn: [
    externalCache
    embeddingsBackendMi
  ]
}

resource semanticCacheStoreFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = if (enableSemanticCaching) {
  parent: apimService
  name: 'semantic-cache-store'
  properties: {
    format: 'rawxml'
    value: '''
<fragment>
  <choose>
    <when condition="@(!context.Request.Headers.GetValueOrDefault("Accept","").Contains("text/event-stream")
      && ((context.Request.Url.Path ?? "").Contains("/chat/completions") || (context.Request.Url.Path ?? "").Contains("/responses")))">
      <azure-openai-semantic-cache-store duration="60" />
    </when>
  </choose>
</fragment>
'''
  }
  dependsOn: [
    externalCache
  ]
}


// (Your product/user/subscription resources below remain unchanged...)

@description('The name of the deployed API Management service.')
output apimName string = apimService.name

@description('The path for the OpenAI API in the deployed API Management service.')
output apimOpenaiApiPath string = apimOpenaiApi.outputs.path

@description('Gateway URL for the deployed API Management resource.')
output apimGatewayUrl string = apimService.properties.gatewayUrl

@description('System-assigned managed identity principalId for APIM (use this for RBAC).')
output apimPrincipalId string = apimService.identity.principalId

@description('APIM resource id.')
output apimId string = apimService.id
