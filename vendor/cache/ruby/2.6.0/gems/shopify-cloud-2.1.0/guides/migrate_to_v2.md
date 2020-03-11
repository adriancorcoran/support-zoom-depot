:bulb: Migrating an existing application from shopify-cloud 1.x to shopify-cloud 2.x :bulb:

### A bit of context

At the time this gem was created, we had the assumption that only part of the log would be useful for developers. That's why we used the [lograge](https://github.com/roidrage/lograge) gem which is very opinionated about which logs are useful.

We ultimately realized that Lograge is not for us, as many developers at Shopify prefer having all logs available to them.
This gem also has the disadvantage of emitting unbuffered multiline logs, which have been difficult for developers to consume in Splunk.

We took the decision to drop support for Lograge and use BufferedLogger instead. If you are familiar with Shopify Core logs, your app's log will look mostly the same.

### What is Buffered-logger?

[Buffered Logger](https://github.com/Shopify/buffered-logger) emits logs using the standard Rails log format in a threadsafe manner. Field extractions are delegated to Splunk, just as Core and the deprecated Heroku pipeline used to work many moons ago. Full events are ingested by Splunk without having to filter through multiple interleaved lines like has been the case with Lograge.

### How to migrate?

- Navigate to `config/deploy/production/web.yml`
- Find the `web` container entry in the YAML
  - These files contain configurations for several Kubernetes resources
  - Ensure you've found the **container** entry, not the **pod** entry!
  - It should look very similar to the code snippet below
- Edit the container entry, changing the current `name` key's value from `web` to `rails`, like this (the line with the `<<<<<<<<<<<<`):

```
spec:
  automountServiceAccountToken: true
  containers:
  - name: rails <<<<<<<<<<<<
    image: gcr.io/shopify-docker-images/apps/production/vpnify:<%= current_sha %>
    args:
    - web
    ports:
    - containerPort: 8000
      name: http-alt
```

#### ActiveJob Logs

Logs coming from jobs will also be buffered **if you use ActiveJob**, but you need to make another similar change:

- Navigate to `config/deploy/production/jobs.yml`
- Find the `jobs` container entry in the YAML
  - These files contain configurations for several Kubernetes resources
  - Ensure you've found the **container** entry, not the **pod** entry!
  - It should look very similar to the code snippet below
- Edit the container entry, changing the current `name` key's value from `jobs` to `active-job`, like this (the line with the `<<<<<<<<<<<<`):

```
spec:
  automountServiceAccountToken: false
  containers:
  - name: active-job <<<<<<<<<<<<
    image: gcr.io/shopify-docker-images/apps/production/solid_track:<%= current_sha %>
    envFrom:
    - configMapRef:
      name: application-state
```

**Note**: If you enqueue jobs directly with the low-level API provided by the adapter (i.e. Sidekiq), your logs won't be
buffered.

### How to search for logs

- The change required in search queries for the standard rails logs is to swap out `sourcetype=fluentd` for `sourcetype=rails:cloudplatform`
- The change required in search queries for the standard active-job logs is to swap out `sourcetype=fluentd` for `sourcetype=active-job:cloudplatform`
