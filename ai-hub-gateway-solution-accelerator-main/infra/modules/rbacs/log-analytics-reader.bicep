targetScope = 'resourceGroup'

param principalResourceId string
param principalId string

@description('Log Analytics workspace name in THIS (module) RG.')
param lawName string

@description('Subscription ID where the LAW lives (used for roleDefinitionId).')
param lawSubscriptionId string

var logAnalyticsReaderRoleGuid = '73c42c96-874c-492b-b04d-ab87d138a893'

// Build roleDefinitionId in the LAW subscription (important for cross-sub)
var logAnalyticsReaderRoleId = subscriptionResourceId(
  lawSubscriptionId,
  'Microsoft.Authorization/roleDefinitions',
  logAnalyticsReaderRoleGuid
)

// Now the LAW is in the SAME scope as the module (this RG), so no BCP139 issue
resource existingLaw 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: lawName
}

resource logAnalyticsReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(existingLaw.id, principalResourceId, logAnalyticsReaderRoleId)
  scope: existingLaw
  properties: {
    roleDefinitionId: logAnalyticsReaderRoleId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
