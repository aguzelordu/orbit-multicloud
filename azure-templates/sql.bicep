param location string
param sqlAdminLogin string

@secure()
param sqlAdminPassword string

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: 'orbit-sqlserver-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
  }
}

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
