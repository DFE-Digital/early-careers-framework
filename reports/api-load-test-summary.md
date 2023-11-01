# Performance summary

|     | Total | Passed |
| --- | ----- | ------ |
| **total requests** | 679 | |
| **Failed requests** | 2 | :x: |
| **Breached thresholds** | 12 | :x: |
| **Failed checks** | 0 | :white_check_mark: |

## Failed thresholds

### ::API v1::/participants/ecf?page[page]=first

| Metric | Cause |
| ------ | ----- |
| http_req_duration | p(95)&lt;1200 |
| http_req_duration | max&lt;1800 |

### ::API v1::/participants/ecf?page[page]=last

| Metric | Cause |
| ------ | ----- |
| http_req_duration | max&lt;1800 |
| http_req_duration | p(95)&lt;1200 |

### ::API v2::/participants/ecf?page[page]=last

| Metric | Cause |
| ------ | ----- |
| http_req_duration | p(95)&lt;1200 |
| http_req_duration | max&lt;1800 |

### ::API v3::/participants/ecf?page[page]=last

| Metric | Cause |
| ------ | ----- |
| http_req_duration | p(95)&lt;1200 |
| http_req_duration | max&lt;1800 |

### ::API v2::/participants/ecf?page[page]=first

| Metric | Cause |
| ------ | ----- |
| http_req_duration | p(95)&lt;1200 |
| http_req_duration | max&lt;1800 |

### ::API v3::/participants/ecf?page[page]=first

| Metric | Cause |
| ------ | ----- |
| http_req_duration | p(95)&lt;1200 |
| http_req_duration | max&lt;1800 |



For a more detailed report see the artifacts attached to the latest workflow run.