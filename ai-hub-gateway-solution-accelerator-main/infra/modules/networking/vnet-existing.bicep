param name string
param vnetRG string

param apimSubnetName string
param logicAppSubnetName string
param redisPrivateEndpointSubnetName string
param cosmosPrivateEndpointSubnetName string
param eventHubPrivateEndpointSubnetName string
param contentSafetyPrivateEndpointSubnetName string
param languageApiPrivateEndpointSubnetName string
param storageAccountPrivateEndpointSubnetName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: name
  scope: resourceGroup(vnetRG)
}

resource apimSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  name: apimSubnetName
  parent: virtualNetwork
}

resource logicAppSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  name: logicAppSubnetName
  parent: virtualNetwork
}

resource redisPrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  name: redisPrivateEndpointSubnetName
  parent: virtualNetwork
}

resource cosmosPrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  name: cosmosPrivateEndpointSubnetName
  parent: virtualNetwork
}

resource eventHubPrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  name: eventHubPrivateEndpointSubnetName
  parent: virtualNetwork
}

resource contentSafetyPrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  name: contentSafetyPrivateEndpointSubnetName
  parent: virtualNetwork
}

resource languageApiPrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  name: languageApiPrivateEndpointSubnetName
  parent: virtualNetwork
}

resource storageAccountPrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' existing = {
  name: storageAccountPrivateEndpointSubnetName
  parent: virtualNetwork
}


output vnetRG string = vnetRG
output location string = virtualNetwork.location

output virtualNetworkId string = virtualNetwork.id
output vnetName string = virtualNetwork.name

output apimSubnetName string = apimSubnet.name
output apimSubnetId string = '${virtualNetwork.id}/subnets/${apimSubnetName}'

output logicAppSubnetName string = logicAppSubnet.name
output logicAppSubnetId string = '${virtualNetwork.id}/subnets/${logicAppSubnetName}'

output redisPrivateEndpointSubnetName string = redisPrivateEndpointSubnet.name
output redisPrivateEndpointSubnetId string = '${virtualNetwork.id}/subnets/${redisPrivateEndpointSubnetName}'

output cosmosPrivateEndpointSubnetName string = cosmosPrivateEndpointSubnet.name
output cosmosPrivateEndpointSubnetId string = '${virtualNetwork.id}/subnets/${cosmosPrivateEndpointSubnetName}'

output eventHubPrivateEndpointSubnetName string = eventHubPrivateEndpointSubnet.name
output eventHubPrivateEndpointSubnetId string = '${virtualNetwork.id}/subnets/${eventHubPrivateEndpointSubnetName}'

output contentSafetyPrivateEndpointSubnetName string = contentSafetyPrivateEndpointSubnet.name
output contentSafetyPrivateEndpointSubnetId string = '${virtualNetwork.id}/subnets/${contentSafetyPrivateEndpointSubnetName}'

output languageApiPrivateEndpointSubnetName string = languageApiPrivateEndpointSubnet.name
output languageApiPrivateEndpointSubnetId string = '${virtualNetwork.id}/subnets/${languageApiPrivateEndpointSubnetName}'

output storageAccountPrivateEndpointSubnetName string = storageAccountPrivateEndpointSubnet.name
output storageAccountPrivateEndpointSubnetId string = '${virtualNetwork.id}/subnets/${storageAccountPrivateEndpointSubnetName}'



