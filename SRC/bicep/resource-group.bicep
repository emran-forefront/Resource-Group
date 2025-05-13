targetScope = 'subscription'


param rgName string = 'emran-test-rg'
param location string = 'northeurope'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
  tags: {
    environment: 'dev'
  }  
  
}
