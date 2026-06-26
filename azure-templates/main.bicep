param location string = resourceGroup().location
param sqlAdminLogin string = 'orbitadmin'

@secure()
param sqlAdminPassword string

// Network Modülünün Çağrılması
module networkModule 'network.bicep' = {
  name: 'orbit-network-deployment'
  params: {
    location: location
  }
}

// SQL Modülünün Çağrılması
module sqlModule 'sql.bicep' = {
  name: 'orbit-sql-deployment'
  params: {
    location: location
    sqlAdminLogin: sqlAdminLogin
    sqlAdminPassword: sqlAdminPassword
  }
}
