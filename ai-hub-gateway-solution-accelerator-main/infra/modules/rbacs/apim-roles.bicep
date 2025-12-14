param name string
param location string = resourceGroup().location
param tags object = {}

@description('APIM system-assigned managed identity principalId')
param apimPrincipalId string


var cognitiveServicesOpenAIUserRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')
var cognitiveServicesUserRoleDefinitionId       = resourceId('Microsoft.Authorization/roleDefinitions', 'a97b65f3-24c7-4388-baec-2e87135dc908')


// --------------------
// APIM -> Cognitive Services access (OpenAI/Language/Content Safety)
// --------------------
resource apimCognitiveServicesUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, apimPrincipalId, cognitiveServicesUserRoleDefinitionId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: cognitiveServicesUserRoleDefinitionId
    principalId: apimPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource apimCognitiveServicesOpenAIUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, apimPrincipalId, cognitiveServicesOpenAIUserRoleDefinitionId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: cognitiveServicesOpenAIUserRoleDefinitionId
    principalId: apimPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// --------------------
// APIM -> Event Hubs sender  Comment the beow code if this RBAC is already assigned in APIM module
// --------------------
// resource apimEventHubsSender 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(resourceGroup().id, apimPrincipalId, eventHubsDataSenderRoleDefinitionId)
//   scope: resourceGroup()
//   properties: {
//     roleDefinitionId: eventHubsDataSenderRoleDefinitionId
//     principalId: apimPrincipalId
//     principalType: 'ServicePrincipal'
//   }
// }

// --------------------
// Optional: Logic App -> Event Hubs sender (if Logic App uses MI auth to send)
// --------------------

