targetScope = 'resourceGroup'

param redisClusterName string
param location string = resourceGroup().location
param skuName string = 'Balanced_B10'

@description('Resource ID of the User Assigned Managed Identity (UAMI).')
param uamiResourceId string

@description('Versioned Key Vault key URL. Example: https://<vault>.vault.azure.net/keys/<key>/<version>')
param keyEncryptionKeyUrl string

@description('Key Vault resource ID (for RBAC assignment scope).')
param keyVaultResourceId string

@allowed([ 'Enabled' 'Disabled' ])
param publicNetworkAccess string = 'Disabled'

// ---------- Existing resources ----------
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: last(split(uamiResourceId, '/'))
  scope: resourceGroup(
    split(uamiResourceId, '/')[2], // subscriptionId
    split(uamiResourceId, '/')[4]  // resourceGroupName
  )
}

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: last(split(keyVaultResourceId, '/'))
  scope: resourceGroup(
    split(keyVaultResourceId, '/')[2],
    split(keyVaultResourceId, '/')[4]
  )
}

// ---------- RBAC (recommended) ----------
var kvCryptoServiceEncUserRoleDefId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'e147488a-f6f5-4113-8e2d-b22465e65bf6' // Key Vault Crypto Service Encryption User
)

resource kvRoleAssign 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(kv.id, uamiResourceId, kvCryptoServiceEncUserRoleDefId)
  scope: kv
  properties: {
    roleDefinitionId: kvCryptoServiceEncUserRoleDefId
    principalId: uami.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// ---------- Update (PUT) the existing cluster ----------
resource redisEnterprise 'Microsoft.Cache/redisEnterprise@2025-08-01-preview' = {
  name: redisClusterName
  location: location
  sku: {
    name: skuName
  }

  // Required for CMK
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uamiResourceId}': {}
    }
  }

  properties: {
    // keep your current settings (match what you already use)
    highAvailability: 'Enabled'
    minimumTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess

    // CMK
    encryption: {
      customerManagedKeyEncryption: {
        keyEncryptionKeyUrl: keyEncryptionKeyUrl
        keyEncryptionKeyIdentity: {
          identityType: 'userAssignedIdentity'
          userAssignedIdentityResourceId: uamiResourceId
        }
      }
    }
  }
}
