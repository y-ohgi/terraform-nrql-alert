terraform-nrql-alert
---

# About
Terraform でNewRelic のNRQL ベースのAlert を作成するモジュール

# e.g.
```hcl
data "newrelic_alert_policy" "policy" {
  name = "<YOUR EXISTS ALERT POLICY>"
}

module "apm-apdex" {
  source = "github.com/y-ohgi/terraform-nrql-alert"

  policy_id = data.newrelic_alert_policy.policy.id

  alert_name = "apm-Apdex"

  nrql = "FROM TransactionError SELECT count(*) WHERE appName = '${local.app_name[var.name]}'"

  operator  = "above"
  threshold = 0.7
}
```
