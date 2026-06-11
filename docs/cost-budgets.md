# Cost Budgets

This repository keeps default CI lanes at zero direct spend.

```json
{
  "lane": "release",
  "budget_usd": 0,
  "quota_usd": 0,
  "quota_minutes": 0,
  "currency": "USD",
  "default_test_command": "cargo test --workspace --locked",
  "paid_services_allowed": false,
  "stop_condition": "no paid external service is invoked from CI or default local lanes",
  "kill_switch": "manual",
  "kill_switch_owner": "release operator",
  "kill_switch_action": "cancel the CI run or interrupt the local process",
  "evidence_paths": [
    ".github/workflows/ci.yml",
    ".github/workflows/jankurai.yml",
    "ops/ci/security.sh",
    "docs/testing.md"
  ]
}
```
