// Parameters
param location string = 'East US'
param appServicePlanName string = 'myAppServicePlan'
param webAppName string = 'myUniqueWebApp123'
param skuTier string = 'Basic'
param skuSize string = 'B1'

param dbServerName string = 'mydbserver123'
param dbAdminUser string = 'dbadmin'
param dbAdminPassword string = 'SecureP@ssw0rd!'  // Use a secure value or Key Vault
param dbName string = 'myDatabase'
param dbSku string = 'S0'

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    tier: skuTier
    name: skuSize
  }
  properties: {
    perSiteScaling: false
    reserved: false
  }
}

// Web App
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      connectionStrings: [
        {
          name: 'DefaultConnection'
          connectionString: 'Server=${dbServerName}.database.windows.net;Database=${dbName};User Id=${dbAdminUser};Password=${dbAdminPassword};'
          type: 'SQLAzure'
        }
      ]
    }
  }
}

// Azure SQL Server
resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: dbServerName
  location: location
  properties: {
    administratorLogin: dbAdminUser
    administratorLoginPassword: dbAdminPassword
  }
}

// Azure SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: dbName
  location: location
  sku: {
    name: dbSku
    tier: 'Standard'
  }
}

// Firewall rule to allow Azure services
resource sqlFirewallRule 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Outputs
output webAppUrl string = 'https://${webAppName}.azurewebsites.net'
output dbConnectionString string = 'Server=${dbServerName}.database.windows.net;Database=${dbName};User Id=${dbAdminUser};Password=${dbAdminPassword};'
