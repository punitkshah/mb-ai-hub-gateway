targetScope = 'resourceGroup'

@description('Name of an existing Azure Monitor Private Link Scope (AMPLS) in this resource group.')
param privateLinkScopeName string

@description('Resource ID of the resource to link (App Insights).')
param linkedResourceId string

resource privateLinkScope 'microsoft.insights/privateLinkScopes@2021-07-01-preview' existing = {
  name: privateLinkScopeName
}

resource appInsightsScopedResource 'Microsoft.Insights/privateLinkScopes/scopedResources@2021-07-01-preview' = {
  parent: privateLinkScope
  name: 'appinsights-connection' // or your convention
  properties: {
    linkedResourceId: linkedResourceId
  }
}
