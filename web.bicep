param location string = 'East US'
param appServicePlanName string = 'myAppServicePlan'
param webAppName string = 'myUniqueWebApp123'
param skuTier string = 'Basic'
param skuSize string = 'B1'

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

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

output webAppUrl string = 'https://${webAppName}.azurewebsites.net'
