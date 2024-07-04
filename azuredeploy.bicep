param location string = 'East US'
param adminUsername string = 'azureuser'
param adminPassword secureString

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: 'myVNet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: 'mySubnet'
  parent: vnet
  location: location
  properties: {
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'myNSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowSSHFromLB'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: lbFrontEndIP.properties.ipAddress  // Whitelist LB IP for SSH
          destinationAddressPrefix: '*'
          access: 'Allow'
          direction: 'Inbound'
          priority: 1000
        }
      }
    ]
  }
}

resource lb 'Microsoft.Network/loadBalancers@2020-06-01' = {
  name: 'myLB'
  location: location
  properties: {
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontEnd'
        properties: {
          publicIPAddress: pubIP.id
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'BackendPool1'
      }
    ]
    inboundNatRules: [
      {
        name: 'SSHAccessVM1'
        properties: {
          frontendIPConfiguration: {
            id: lbFrontEndIP.id
          }
          protocol: 'Tcp'
          frontendPort: 50001  // Choose a unique port for VM1 SSH
          backendPort: 22
          enableFloatingIP: false
          idleTimeoutInMinutes: 15
          enableTcpReset: false
          disableOutboundSnat: false
        }
      },
      {
        name: 'SSHAccessVM2'
        properties: {
          frontendIPConfiguration: {
            id: lbFrontEndIP.id
          }
          protocol: 'Tcp'
          frontendPort: 50002  // Choose a unique port for VM2 SSH
          backendPort: 22
          enableFloatingIP: false
          idleTimeoutInMinutes: 15
          enableTcpReset: false
          disableOutboundSnat: false
        }
      }
    ]
  }
}

resource lbFrontEndIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: 'myLBPublicIP'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource pubIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: 'myPublicIP'
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource vm1 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: 'myVM1'
  location: location
  dependsOn: [subnet]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '16.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: 'myVM1'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic1.id
        }
      ]
    }
  }
}

resource nic1 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: 'myNIC1'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: null
        }
      }
    ]
  }
}

resource vm2 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: 'myVM2'
  location: location
  dependsOn: [subnet]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS1_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '16.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    osProfile: {
      computerName: 'myVM2'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic2.id
        }
      ]
    }
  }
}

resource nic2 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: 'myNIC2'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig2'
        properties: {
          subnet: {
            id: subnet.id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: null
        }
      }
    ]
  }
}
