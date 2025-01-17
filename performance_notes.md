## Is this happening to one provider or multiple providers

It's not possible to tell from the information available in Sentry. According to the errors its only happened to one user (most of the time when it occurs we don't get the user context in Sentry).

The user it did get logged against was `06e6a6c1-6e12-4625-b29e-b79c00f516f5` which is `matthew.doyle@education.gov.uk`.

It looks like we only set the user for `ApplicationController` and not `Api::ApiController` - we may want to add something like this to the API controller so we get the details of the LP making the request:

```
before_action :set_sentry_user

def set_sentry_user
  Sentry.set_user(id: current_user&.lead_provider&.id)
end
```

## What is the pattern of the provider that is causing this error, is it they are querying 3000 per page, are they hammering the API

The only pattern I can see in the events is that they all seem to happen on the hour, with the error occurring ~30s later, which makes sense as I believe our Postgres timeout is 30s:

https://dfe-teacher-services.sentry.io/issues/6097069356/events/?environment=production&project=5748989&referrer=issue-stream&statsPeriod=90d&stream_index=0

It seems like a provider is running a scheduled request every hour to get the latest participants (no filter/page params) and it occasionally fails on random hours of the day.

Looking at Kibana the service doesn't seem to be spiking when these failures happen (there are various spikes of traffic in the logs but they don't line up with these errors).

January 14th had errors at 10am and 12pm, with Kibana showing higher traffic at 3am, 1pm and 9:30pm:

https://kibana-uk1.logit.io/s/e9b9162d-0b5e-4362-bed0-8e577f88d06e/app/data-explorer/discover#?_a=(discover:(columns:!(_source),isDirty:!t,sort:!()),metadata:(indexPattern:'filebeat-*',view:discover))&_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:'2025-01-14T00:00:00.000Z',to:'2025-01-14T23:30:00.000Z'))&_q=(filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'filebeat-*',key:kubernetes.container.name,negate:!f,params:(query:cpd-ecf-production-web),type:phrase),query:(match_phrase:(kubernetes.container.name:cpd-ecf-production-web)))),query:(language:kuery,query:''))

January 13th had errors at 8am and 1pm, with Kibana showing higher traffic at 3am and 9:30am:

https://kibana-uk1.logit.io/s/e9b9162d-0b5e-4362-bed0-8e577f88d06e/app/data-explorer/discover#?_a=(discover:(columns:!(_source),isDirty:!t,sort:!()),metadata:(indexPattern:'filebeat-*',view:discover))&_g=(filters:!(),refreshInterval:(pause:!t,value:0),time:(from:'2025-01-13T00:00:00.000Z',to:'2025-01-13T23:30:00.000Z'))&_q=(filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:'filebeat-*',key:kubernetes.container.name,negate:!f,params:(query:cpd-ecf-production-web),type:phrase),query:(match_phrase:(kubernetes.container.name:cpd-ecf-production-web)))),query:(language:kuery,query:''))

## How often is the provider experiencing this error

It looks like its happening around 7-10 days out of each month. Sometimes multiple times per day.

## Analyse the participants endpoint and highlight any bottlenecks we can see, and performance improvements we can make like adding indices, improving pagination etc. that could help

Initial participants query is slow:

```
1878.0 ms
1746.4 ms
1744.4 ms
1761.5 ms
```

Attempt to optimise with pagy_countless doesn't work as we get:

```
undefined method `to_sql' 
```

This is due to `pagy_countless` returning an eager-loaded array of records (unlike the default `pagy` call which will return an active record data set), which we are then passing into another query:

```
.joins("INNER JOIN (#{paginated_join.to_sql}) as tmp on tmp.id = users.id")
```

By updating the query to filter on the array of users instead of join, we can get it to execute successfully:

```
_pagy, paginated_records = pagy_countless(scope)

...

.where(users: { id: paginated_join.map(&:id) })
```

The query runtimes after making this change were much faster:

```
635.7 ms
648.6 ms
644.1 ms
627.1 ms
```

The overall response time of the endpoint went from ~3.3s down to ~2s with this change (in development against snapshot data).
