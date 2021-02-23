# gcloud

This example shows how to setup and manage eventing using Terraform through the
gcloud command-line interface.

This actuates the following resources:

* A GKE cluster named `events-example-cluster-gcloud` with eventing installed.
* A Pub/Sub topic named `test-topic-gcloud`.
* An event-display service in the namespace `default`.
* A Broker named `default` in the namespace `default`.
* A Pub/Sub trigger in the namespace `default`, sourcing messages from the topic `test-topic-gcloud`, and sinking messages to the event-display service.

## Instructions

In order to run this, first initialize Terraform:

```shell
terraform init
```

Then, apply the configuration:

```shell
terraform apply
```

Now, to verify that eventing is working properly, publish a message to the Pub/Sub topic:

```shell
gcloud pubsub topics publish test-topic-gcloud --message='Hello world!'
```

Observe it through the event-display service:
```shell
kubectl logs -l role=event-display -c user-container
```
