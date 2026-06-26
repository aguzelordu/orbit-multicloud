param location string

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'orbit-azure-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP-Inbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'orbit-azure-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.2.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'FrontendSubnet'
        properties: {
          addressPrefix: '10.2.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
      {
        name: 'BackendSubnet'
        properties: {
          addressPrefix: '10.2.2.0/24'
        }
      }
      {
        name: 'DatabaseSubnet'
        properties: {
          addressPrefix: '10.2.3.0/24'
        }
      }
    ]
  }
}
