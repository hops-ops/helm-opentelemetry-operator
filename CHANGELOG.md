### What's changed in v0.1.0

* feat: initial commit (by @patrickleet)

* chore(deps): update helm release opentelemetry-operator to v0.102.0 (#1) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* chore(deps): update unbounded-tech/workflow-simple-release action to v2.1.1 (#2) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* chore(deps): update unbounded-tech/workflows-crossplane action to v2.13.0 (#4) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* feat: helm chart xrd (by @patrickleet)

* chore(deps): update unbounded-tech/workflow-vnext-tag action to v1.21.0 (#6) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* feat(deps): update crossplane-contrib/provider-helm docker tag to v1.0.6 (#5) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* fix(e2e): add RBAC for Helm provider to create namespaces (by @patrickleet)

  Add ClusterRoleBinding granting cluster-admin to crossplane-system
  service accounts. This allows the Helm provider to create namespaces
  and install charts during e2e tests.

  Also align with cert-manager e2e test pattern:
  - Use autoUpgrade.channel = "Rapid" instead of pinned version
  - Increase cleanupTimeoutSeconds to 1800

  Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>

* fix(e2e): add cert-manager as prerequisite for OpenTelemetry Operator (by @patrickleet)

  OpenTelemetry Operator Helm chart requires cert-manager CRDs for
  its webhook certificates. Add helm-cert-manager Configuration to
  initResources and CertManager instance to manifests.

  Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>


