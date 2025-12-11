targetScope = 'resourceGroup'

param name string
param dashboardName string
param location string = resourceGroup().location
param tags object = {}

param logAnalyticsWorkspaceId string
param createDashboard bool

// Just a flag – don't try to reach the AMPLS from here
@description('Set to true when this App Insights instance will be linked to an AMPLS.')
param usePrivateLinkScope bool = false

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': name })
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspaceId

    // Behaviour depends on whether we use AMPLS
    publicNetworkAccessForIngestion: usePrivateLinkScope ? 'Disabled' : 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    CustomMetricsOptedInType: 'WithDimensions'
  }
}

module applicationInsightsDashboard 'applicationinsights-dashboard.bicep' = if (createDashboard) {
  name: 'application-insights-dashboard'
  params: {
    name: dashboardName
    location: location
    applicationInsightsName: applicationInsights.name
  }
}

output connectionString string = applicationInsights.properties.ConnectionString
output instrumentationKey string = applicationInsights.properties.InstrumentationKey
output name string = applicationInsights.name
output id string = applicationInsights.id
