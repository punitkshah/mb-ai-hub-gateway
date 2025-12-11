@description('Azure region for the Redis cluster.')
param location string = resourceGroup().location

@description('Name of the Azure Managed Redis (Redis Enterprise) cluster.')
param redisClusterName string

@description('Name of the database inside the cluster.')
param redisDatabaseName string = 'default'

@description('Redis Enterprise SKU name. Example: Enterprise_E10, Enterprise_E20, EnterpriseFlash_F300, Balanced_B5, etc.')
param skuName string 

// @description('Capacity for Enterprise / EnterpriseFlash SKUs. (Enterprise: 2,4,6,...  EnterpriseFlash: 3,9,15,...)')
// param skuCapacity int 

// param effectiveCapacity int 

@allowed([
  'Enabled'
  'Disabled'
])
@description('Public network access for the cluster endpoint.')
param publicNetworkAccess string = 'Disabled'


@description('Optional tags.')
param tags object = {}

param redisPrivateEndpointName string
param vNetName string
param privateEndpointSubnetName string
param redisPrivateDnsZoneName string

// Use existing network/dns zone
param dnsZoneRG string
param dnsSubscriptionId string

param vNetRG string


resource redisEnterprise 'Microsoft.Cache/redisEnterprise@2025-07-01' = {
  name: redisClusterName
  location: location
  tags: tags
  sku: {
    name: skuName
    // capacity: effectiveCapacity
  }
  properties: {
    highAvailability: 'Enabled'
    minimumTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess
  }
}



resource redisDb 'Microsoft.Cache/redisEnterprise/databases@2025-07-01' = {
  parent: redisEnterprise
  name: redisDatabaseName
  properties: {
    // APIM external cache typically uses access keys.
    accessKeysAuthentication: 'Enabled'

    // Best default for APIM / clients.
    clientProtocol: 'Encrypted'

    // REQUIRED for RediSearch on Azure Managed Redis.
    clusteringPolicy: 'EnterpriseCluster'
    evictionPolicy: 'NoEviction'

    // Enable RediSearch module (needed for vector similarity search).
    // NOTE: modules can only be added at creation time.
    modules: [
      {
        name: 'RediSearch'
        args: ''
      }
    ]
  }
}


resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vNetName
  scope: resourceGroup(vNetRG)
}

// Get existing subnet
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: privateEndpointSubnetName
  parent: vnet
}


module redisPrivateEndpoint '../networking/private-endpoint.bicep' = {
  name: '${redisClusterName}-privateEndpoint'
  params: {
    groupIds: [
      'redis' 
    ]
    dnsZoneName: redisPrivateDnsZoneName
    name: redisPrivateEndpointName
    privateLinkServiceId:redisEnterprise.id   
    location: location
    dnsZoneRG: dnsZoneRG
    privateEndpointSubnetId: subnet.id
    dnsSubId: dnsSubscriptionId
  }
} 

output redisClusterId string = redisEnterprise.id
output redisDatabaseId string = redisDb.id
output redisHostName string = redisEnterprise.properties.hostName
output redisPrivateEndpointName string = redisPrivateEndpoint.name 
