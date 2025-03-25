# Read the XR and the OCDs
oxr: any = option("params").oxr
ocds: any = option("params").ocds

spec: any = oxr.spec
parameters: any = spec.parameters

# Initialize the items list
_items: [any] = []

## Adding resources
_cephObject= {
  apiVersion = "kubernetes.crossplane.io/v1alpha2"
  kind = "Object"
  metadata = {
    name = "{}-ss".format(oxr.metadata.name)
    annotations = {
      "krm.kcl.dev/composition-resource-name": "ceph-bucket"
    }
  }
  spec = {
    forProvider = {
      manifest = {
        apiVersion = "objectbucket.io/v1alpha1"
        kind = "ObjectBucketClaim"
        metadata = {
          name = parameters.bucketName
          namespace = parameters.source_secret.namespace
        }
        spec = {
          bucketName       = parameters.bucketName
          storageClassName = parameters.storageClassName
          additionalConfig = {
            maxSize    = parameters.maxSize
            maxObjects = parameters.maxObjects
          }
        }
      }
    }
    managementPolicies = ["Observe"]
    providerConfigRef = {
      name = spec.providerConfigsRef.scK8sProviderName
    }
  }
}

_items += [_cephObject]

dxr = {
    **oxr
}

items = _items + [dxr]