@minLength(5)
@maxLength(8)
@description('Name of environment')
param env string = 'devd2'

var appiName = 'appi-scm-${env}-${uniqueString(resourceGroup().id)}'
var location = resourceGroup().location
var resourceTag = {
  Environment: env
}

resource appi 'Microsoft.Insights/components@2015-05-01' = {
  name: appiName
  location: location
  tags: resourceTag
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

output applicationInsightsKey string = appi.properties.InstrumentationKey


