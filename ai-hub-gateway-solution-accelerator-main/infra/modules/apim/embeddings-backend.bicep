@description('Name of the APIM service (must already exist).')
param apimName string

@description('APIM backend id for embeddings.')
param embeddingsBackendId string

@description('Embeddings deployment URL.')
param embeddingsDeploymentUrl string

resource apim 'Microsoft.ApiManagement/service@2024-05-01' existing = {
  name: apimName
}

resource embeddingsBackend 'Microsoft.ApiManagement/service/backends@2024-05-01' = {
  parent: apim
  name: embeddingsBackendId
  properties: {
    title: embeddingsBackendId
    description: 'Embeddings backend for semantic cache'
    url: embeddingsDeploymentUrl
    protocol: 'http'
    tls: {
      validateCertificateChain: true
      validateCertificateName: true
    }
    credentials: {
      header: {}
      query: {}
      managedIdentity: {
        // For Azure OpenAI / Cognitive Services token audience
        resource: 'https://cognitiveservices.azure.com/'
        // If you ever want UAMI for the backend call, add:
        // clientId: '<uami-client-id-guid>'
      }
    }
  }
}
