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
          namespace = parameters.secret.source_namespace
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
    managementPolicies = spec.managementPolicies
    providerConfigRef = {
      name = spec.providerConfigsRef.scK8sProviderName
    }
  }
}
_sourceSecret = {
  apiVersion = "kubernetes.crossplane.io/v1alpha2"
  kind = "Object"
  metadata = {
    name = "{}-ss".format(oxr.metadata.name)
    annotations = {
      "krm.kcl.dev/composition-resource-name": "source-secret"
    }
  }
  spec = {
    forProvider = {
      manifest = {
        apiVersion = "v1"
        kind = "Secret"
        metadata = {
          name = parameters.bucketName
          namespace = parameters.secret.source_namespace
        }
      }
    }
    managementPolicies = ["Observe"]
    providerConfigRef = {
      name = spec.providerConfigsRef.scK8sProviderName
    }
  }
}

_destinationSecret = {
  apiVersion = "kubernetes.crossplane.io/v1alpha2"
  kind = "Object"
  metadata = {
    name = "{}-ds".format(oxr.metadata.name)
    annotations = {
      "krm.kcl.dev/composition-resource-name": "destination-secret"
    }
  }
  spec = {
    forProvider = {
      manifest = {
        apiVersion = "v1"
        kind = "Secret"
        metadata = {
          name = parameters.bucketName
          namespace = parameters.secret.destination_namespace
        }
        # Get data and type from the source secret's status
        data = ocds["source-secret"]?.Resource?.status?.atProvider?.manifest?.data
        type = ocds["source-secret"]?.Resource?.status?.atProvider?.manifest?.type
      }
    }
    managementPolicies = spec.managementPolicies
    providerConfigRef = {
      name = spec.providerConfigsRef.ccK8sProviderName
    }
  }
}

_pushSecret = {
  apiVersion = "kubernetes.crossplane.io/v1alpha2"
  kind = "Object"
  metadata = {
    name = "{}-push-secret".format(oxr.metadata.name)
    annotations = {
      "krm.kcl.dev/composition-resource-name": "push-secret"
    }
  }
  spec = {
    forProvider = {
      manifest = {
        apiVersion = "external-secrets.io/v1alpha1"
        kind = "PushSecret"
        metadata = {
          name = parameters.bucketName
          namespace = parameters.secret.destination_namespace
        }
        spec = {
          updatePolicy = "Replace"
          deletionPolicy = "None"
          refreshInterval = "1h"
          secretStoreRefs = [
            {
              name = "vault-backend"
              kind = "ClusterSecretStore"
            }
          ]
          selector = {
            secret = {
              name = parameters.bucketName
            }
          }
          data = [
            {
              match = {
                secretKey = "AWS_ACCESS_KEY_ID"
                remoteRef = {
                  remoteKey = "mw-stg/mutai_bucket"
                  property = "AWS_ACCESS_KEY_ID"
                }
              }
            },
            {
              match = {
                secretKey = "AWS_SECRET_ACCESS_KEY"
                remoteRef = {
                  remoteKey = "mw-stg/mutai_bucket"
                  property = "AWS_SECRET_ACCESS_KEY"
                }
              }
            }
          ]
        }
      }
    }
    managementPolicies = spec.managementPolicies
    providerConfigRef = {
      name = spec.providerConfigsRef.ccK8sProviderName
    }
  }
}

_items += [_cephObject,_sourceSecret,_destinationSecret,_pushSecret]

dxr = {
    **oxr
}

items = _items + [dxr]