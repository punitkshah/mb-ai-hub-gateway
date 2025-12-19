param apimName string

@secure()
param redisConnectionString string

// param openAiEndpoint string
// param embeddingsDeploymentName string
param embeddingsBackendId string = 'embeddings-backend'
param embeddingsDeploymentUrl string 

// var aoaiBase = endsWith(openAiEndpoint, '/') ? substring(openAiEndpoint, 0, length(openAiEndpoint) - 1) : openAiEndpoint
// var embeddingsBackendUrl = '${aoaiBase}/openai/deployments/${embeddingsDeploymentName}/embeddings'

resource apimService 'Microsoft.ApiManagement/service@2024-05-01' existing = {
  name: apimName
}

// 1) External cache (Redis)
resource externalCache 'Microsoft.ApiManagement/service/caches@2024-05-01' = {
  parent: apimService
  name: 'default'
  properties: {
    connectionString: redisConnectionString
    useFromLocation: 'default'
    description: 'Redis external cache for semantic caching'
  }
}

// 2) Embeddings backend with MI auth (nested deployment workaround)
resource embeddingsBackendMi 'Microsoft.Resources/deployments@2021-04-01' = {
  name: '${apimName}-embeddings-backend-mi'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: [
        {
          type: 'Microsoft.ApiManagement/service/backends'
          apiVersion: '2024-05-01'
          name: '${apimName}/${embeddingsBackendId}'
          properties: {
            description: 'Embeddings backend for semantic cache'
            url: embeddingsDeploymentUrl
            protocol: 'http'
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

resource semanticCacheLookupFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' = {
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
          embeddings-backend-id ="${embeddingsBackendId}"
          embeddings-backend-auth ="system-assigned"
          ignore-system-messages="true"
          max-message-count="10">
        <!-- Partition cache -->
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



resource semanticCacheStoreFragment 'Microsoft.ApiManagement/service/policyFragments@2022-08-01' =  {
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
