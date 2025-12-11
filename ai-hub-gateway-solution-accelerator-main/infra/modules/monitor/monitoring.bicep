// RG for existing AMPLS
param privateLinkScopeRgName string
param privateLinkScopeSubId string = subscription().subscriptionId
param privateLinkScopeName string

param apimApplicationInsightsName string
param apimApplicationInsightsRgName string
param apimApplicationInsightsSubscriptionId string
param apimApplicationInsightsDashboardName string
param location string
param tags object = {}
param createDashboard bool

param logAnalyticsWorkspaceResourceId string

// 1) App Insights in its RG
module apimApplicationInsights 'applicationinsights.bicep' = {
  name: 'application-insights'
  scope: resourceGroup(apimApplicationInsightsSubscriptionId, apimApplicationInsightsRgName)
  params: {
    name: apimApplicationInsightsName
    dashboardName: apimApplicationInsightsDashboardName
    location: location
    tags: tags
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceResourceId
    createDashboard: createDashboard
    usePrivateLinkScope: privateLinkScopeName != ''
  }
}

// 2) AMPLS scoped resource in the AMPLS RG
module appInsightsAmplsLink 'ampls-link.bicep' = if (privateLinkScopeName != '') {
  name: 'ampls-appinsights-link'
  scope: resourceGroup(privateLinkScopeSubId, privateLinkScopeRgName)
  params: {
    privateLinkScopeName: privateLinkScopeName
    linkedResourceId: apimApplicationInsights.outputs.id
  }
}

// Outputs as you had them
output applicationInsightsName string = apimApplicationInsights.outputs.name
output applicationInsightsConnectionString string = apimApplicationInsights.outputs.connectionString
output applicationInsightsInstrumentationKey string = apimApplicationInsights.outputs.instrumentationKey
output logAnalyticsWorkspaceId string = logAnalyticsWorkspaceResourceId
output logAnalyticsWorkspaceName string = last(split(logAnalyticsWorkspaceResourceId, '/'))
