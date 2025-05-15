
@description('Location for all resources')
param location string = resourceGroup().location

@description('Hub VNet name')
param hubVnetName string = 'vnet-hub'

@description('Hub VNet address space')
param hubVnetAddressPrefix string = '10.0.0.0/16'

@description('Hub subnet prefix')
param hubSubnetPrefix string = '10.0.0.0/24'

@description('Spoke VNets to deploy')
param spokes array = [
  {
    name: 'vnet-spoke1'
    addressPrefix: '10.1.0.0/16'
    subnetPrefix: '10.1.0.0/24'
  }
  {
    name: 'vnet-spoke2'
    addressPrefix: '10.2.0.0/16'
    subnetPrefix: '10.2.0.0/24'
  }
]

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: hubVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubVnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: hubSubnetPrefix
        }
      }
    ]
  }
}

resource spokeVnets 'Microsoft.Network/virtualNetworks@2023-04-01' = [for spoke in spokes: {
  name: spoke.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        spoke.addressPrefix
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: spoke.subnetPrefix
        }
      }
    ]
  }
}]

resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = [for (spoke, i) in spokes: {
  name: 'to-${spoke.name}'
  parent: hubVnet
  properties: {
    remoteVirtualNetwork: {
      id: spokeVnets[i].id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
  dependsOn: [
    spokeVnets[i]
  ]
}]

resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-04-01' = [for (spoke, i) in spokes: {
  name: '${spoke.name}/to-${hubVnet.name}'
  properties: {
    remoteVirtualNetwork: {
      id: hubVnet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
  dependsOn: [
    spokeVnets[i]
  ]
}]
