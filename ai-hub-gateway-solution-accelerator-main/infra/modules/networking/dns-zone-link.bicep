targetScope = 'resourceGroup'

param vnetId string
param vnetName string
param privateDnsZoneNames array

resource privateDnsZones 'Microsoft.Network/privateDnsZones@2020-06-01' existing = [
  for zoneName in privateDnsZoneNames: {
    name: zoneName
  }
]

resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [
  for (zoneName, i) in privateDnsZoneNames: {
    name: '${vnetName}-vnetlink'
    parent: privateDnsZones[i]
    location: 'global'
    properties: {
      virtualNetwork: {
        id: vnetId
      }
      registrationEnabled: false
    }
  }
]

// ✅ Correct: apply an indexer to the resource collection
output vnetLinkIds array = [
  for i in range(0, length(privateDnsZoneNames)): vnetLinks[i].id
]
