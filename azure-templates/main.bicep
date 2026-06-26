// azure-templates/main.bicep

param location string = resourceGroup().location
param sqlAdminLogin string = 'orbitadmin'

@secure()
@description('SQL Server yönetici şifresi. Dağıtım esnasında CLI üzerinden veya parametre dosyasından güvenli şekilde girilmelidir.')
param sqlAdminPassword string

// 1. Network Security Group (NSG) - Güvenlik Kuralları
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

// 2. Sanal Ağ (VNet) ve 3 Adet Subnet
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

// 3. Azure SQL Server 
resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: 'orbit-sqlserver-${uniqueString(resourceGroup().id)}' 
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
  }
}

// 4. Azure SQL Database 
resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: 'orbit-sqldb'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
    capacity: 5
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
  }
}
