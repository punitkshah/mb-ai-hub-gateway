param clusterName string
param databaseName string = 'default'
param apiVersion string = '2025-07-01'

resource getKeys 'Microsoft.Resources/deployments@2021-04-01' = {
  name: '${clusterName}-redis-db-keys'
  properties: {
    mode: 'Incremental'
    parameters: {
      clusterName: { value: clusterName }
      databaseName: { value: databaseName }
      apiVersion: { value: apiVersion }
    }
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        clusterName: { type: 'string' }
        databaseName: { type: 'string' }
        apiVersion: { type: 'string' }
      }
      resources: []
      outputs: {
        primaryKey: {
          type: 'string'
          value: '[listKeys(resourceId("Microsoft.Cache/redisEnterprise/databases", parameters("clusterName"), parameters("databaseName")), parameters("apiVersion")).primaryKey]'
        }
      }
    }
  }
}

@secure()
output primaryKey string = getKeys.properties.outputs.primaryKey.value
