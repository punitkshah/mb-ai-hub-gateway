@description('Azure Key Vault name, must be globally unique')
param keyVaultResourceName string

@description('Location for the Azure Key Vault.')
param location string = resourceGroup().location

@description('Resource tags')
param tags object = {}

@allowed([
  'standard'
  'premium'
])
@description('Key Vault SKU')
param skuName string = 'standard'

@allowed([
  'Enabled'
  'Disabled'
])
@description('Public network access for Key Vault. Recommended Disabled when using private endpoint.')
param publicNetworkAccess string = 'Disabled'

// Networking
@description('Name of the private endpoint for the Key Vault')
param keyVaultPrivateEndpointName string

@description('Virtual network name for the private endpoint')
param vNetName string

@description('Subnet name for the private endpoint')
param privateEndpointSubnetName string

@description('Existing Private DNS Zone name for Key Vault (typically privatelink.vaultcore.azure.net)')
param keyVaultPrivateDnsZoneName string = 'privatelink.vaultcore.azure.net'

@description('Resource group of the existing Private DNS Zone')
param dnsZoneRG string

@description('Subscription ID where the existing Private DNS Zone lives')
param dnsSubscriptionId string

@description('Resource group of the existing virtual network')
param vNetRG string

// -------- Existing network and DNS resources --------

// Existing VNet
resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vNetName
  scope: resourceGroup(vNetRG)
}

// Existing subnet within the VNet
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: privateEndpointSubnetName
  parent: vnet
}

// Existing Private DNS zone for Key Vault (privatelink.vaultcore.azure.net)
resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: keyVaultPrivateDnsZoneName
  scope: resourceGroup(dnsZoneRG, dnsSubscriptionId)
}

// -------- Key Vault --------

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultResourceName
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: skuName
    }

    // Recommended modern pattern: use RBAC instead of access policies
    enableRbacAuthorization: true

    publicNetworkAccess: publicNetworkAccess

    // Deny by default; we rely on private endpoint + Private DNS
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipRules: []
      virtualNetworkRules: []
    }

    // Optional, but usually good hygiene
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    enabledForDeployment: false
    softDeleteRetentionInDays: 90
  }
}

// -------- Private Endpoint (via your existing module) --------

// This assumes your '../networking/private-endpoint.bicep' module
// has the same parameters as in your Cosmos example:
//   - groupIds
//   - dnsZoneName
//   - name
//   - privateLinkServiceId
//   - location
//   - dnsZoneRG
//   - privateEndpointSubnetId
//   - dnsSubId

module keyVaultPrivateEndpoint '../networking/private-endpoint.bicep' = {
  name: '${keyVaultResourceName}-privateEndpoint'
  params: {
    groupIds: [
      'vault'
    ]
    dnsZoneName: keyVaultPrivateDnsZoneName
    name: keyVaultPrivateEndpointName
    privateLinkServiceId: keyVault.id
    location: location
    dnsZoneRG: dnsZoneRG
    privateEndpointSubnetId: subnet.id
    dnsSubId: dnsSubscriptionId
  }
}

// -------- Outputs --------

output keyVaultNameOut string = keyVault.name
output keyVaultId string = keyVault.id
output keyVaultUri string = keyVault.properties.vaultUri
output keyVaultPrivateEndpointNameOut string = keyVaultPrivateEndpoint.name
