import datetime
import math
import models.ai.com.ops.hops.helm.v1alpha1 as helmv1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

# ==============================================================================
# E2E Test for OpenTelemetryOperator XRD (Kubernetes-only)
#
# This test uses the Helm provider with ProviderConfig which uses
# injected identity (no credentials needed - runs in-cluster).
# ==============================================================================

# Generate unique name using timestamp to avoid CI conflicts
_now = str(int(math.floor(datetime.ticks())))
_test_name = "e2e-otel-" + _now

_items = [
    metav1alpha1.E2ETest {
        metadata.name = "opentelemetryoperator-helm"
        spec = {
            crossplane = {
                autoUpgrade.channel = "Rapid"
            }
            defaultConditions = ["Ready"]
            timeoutSeconds = 1800  # 30 minutes
            cleanupTimeoutSeconds = 1800  # 30 minutes
            skipDelete = False

            # ==============================================================
            # initResources: Configuration packages installed first
            # These are NOT deleted during cleanup
            # ==============================================================
            initResources = [
                # cert-manager Configuration - required by OpenTelemetry Operator
                {
                    apiVersion = "pkg.crossplane.io/v1"
                    kind = "Configuration"
                    metadata.name = "helm-cert-manager"
                    spec = {
                        package = "ghcr.io/hops-ops/helm-cert-manager:v0.6.1"
                    }
                }
            ]

            # ==============================================================
            # extraResources: RBAC and Helm ProviderConfig
            # These are NOT deleted during cleanup
            # ==============================================================
            extraResources = [
                # Grant cluster-admin to all SAs in crossplane-system namespace
                # This allows the Helm provider to create namespaces and install charts
                {
                    apiVersion = "rbac.authorization.k8s.io/v1"
                    kind = "ClusterRoleBinding"
                    metadata.name = "crossplane-system-cluster-admin"
                    roleRef = {
                        apiGroup = "rbac.authorization.k8s.io"
                        kind = "ClusterRole"
                        name = "cluster-admin"
                    }
                    subjects = [
                        {
                            kind = "Group"
                            name = "system:serviceaccounts:crossplane-system"
                            apiGroup = "rbac.authorization.k8s.io"
                        }
                    ]
                }
                # Helm ProviderConfig - uses in-cluster identity
                # Must use helm.m.crossplane.io to match the Release API
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "ProviderConfig"
                    metadata = {
                        name = "default"
                        namespace = "default"
                    }
                    spec = {
                        credentials = {
                            source = "InjectedIdentity"
                        }
                    }
                }
            ]

            # ==============================================================
            # manifests: CertManager and OpenTelemetryOperator XRs to test
            # Resources here ARE deleted during cleanup
            # ==============================================================
            manifests = [
                # CertManager must be installed before OpenTelemetry Operator
                {
                    apiVersion = "helm.hops.ops.com.ai/v1alpha1"
                    kind = "CertManager"
                    metadata = {
                        name = "cert-manager"
                        namespace = "default"
                    }
                    spec = {
                        clusterName = "cert-manager"
                        providerConfigRef = {
                            name = "default"
                            kind = "ProviderConfig"
                        }
                    }
                }
                helmv1alpha1.OpenTelemetryOperator {
                    metadata = {
                        name = _test_name
                        namespace = "default"
                    }
                    spec = {
                        clusterName = _test_name
                        # labels uses x-kubernetes-preserve-unknown-fields
                        labels = {
                            "hops.ops.com.ai/e2etest" = "true"
                            "hops.ops.com.ai/test-run" = _now
                        }
                        providerConfigRef = {
                            name = "default"
                            kind = "ProviderConfig"
                        }
                        # values uses x-kubernetes-preserve-unknown-fields
                        values = {
                            manager = {
                                resources = {
                                    requests = {cpu = "10m", memory = "32Mi"}
                                }
                            }
                            kubeRBACProxy = {
                                resources = {
                                    requests = {cpu = "10m", memory = "32Mi"}
                                }
                            }
                        }
                    }
                }
            ]
        }
    }
]
items = _items
