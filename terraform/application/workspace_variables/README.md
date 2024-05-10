# Backend tfvars naming convention

```
s189t01cpdecftfstatestsa
╞═════╡╞════╡╞═════╡╞╡╞╡
│      │     │      │  └─── type of resouce
│      │     │      │         sa      = storage account
│      │     │      └────── environment:
│      │     │                dv      = development
│      │     │                rv      = review
│      │     │                st      = staging
│      │     │                sb      = sandbox
│      │     │                pd      = production
│      │     └───────────── contents
│      │                      tfstate = terraform state file
│      └─────────────────── programme/app
│                             cpd     = continuing professional development
│                             ecf     = early careers framework
│                             npq     = national professional qualifications
│                             eal     = engage and learn
│                             i       = information
└────────────────────────── subscription
                              d01     = development (used for devops testing)
                              t01     = test (used for testing, review apps, staging)
                              p01     = production (used for sandbox, prod)
```

This string can be 24 characters long max so we can't afford to use
the three letter names for some envs that other teams use (like sbx
for sandbox).
