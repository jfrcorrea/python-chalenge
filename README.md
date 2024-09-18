# Python Challenge

## Introduction
This is an app to process data events sent by several "Event Producers" and deliver to a "Sender" responsible for spread the processed events to subscribed clients.

## Architecture overview
![image info](./images/EventProcessor.png)
To achieve a low latency solution, the AWS Kinesis Data Stream was chosen. Due to its suitability for real-time processing of streaming big data.

The Kinesis Data Stream can receive data from multiple producers (fan-in), split the records into multiple shards, a Data Firehose concurrently transforms the data using a Lambda Function before delivering it to an S3 Bucket. Then the S3 bucket notifies a SNS topic for each valid file created, spreading the data among the consumers (fan-out).

The S3 Bucket was select as the final destination of the Data Firehose due to its ability to store data persistently, enabling backfilling.

The invalid data records are stored in the same S3 Bucket, but in a different folder. This folder can be monitored to check if any producer is not working well.

### Components
This section outlines the components involved in the Event processor.

#### AWS Kinesis Stream
Acts as a source where producers can publish data records in JSON format.
Each record must include a key named "producer" containing the producer identifier.
Optionally, producers can specify a partition key to leverage sharding within the Kinesis stream.

#### AWS Data Firehose
Continuously retrieves data records from the Kinesis Data Stream and delivers them to the next processing stage.

#### AWS Lambda
Validates the data records against pre-registered schemas specific to each producer.
These schemas are currently implemented using [Python Data Classes](https://docs.python.org/3.10/library/dataclasses.html) for simplicity.
However, utilizing libraries like Pydantic or JSON Schema can provide further enhancements.

New producer schemas can be defined within the [models.py](https://github.com/jfrcorrea/python-challenge/blob/main/terraform/functions/validate/models.py) file.
Once created, register them in the `producers` variable inside the [main.py](https://github.com/jfrcorrea/python-challenge/blob/main/terraform/functions/validate/main.py) file.

#### AWS S3
Serves as the persistence layer, storing both valid and invalid data records.
Valid records are placed within the `data/` folder of the S3 bucket, while invalid ones are stored in the `error/` folder.

#### AWS SNS
The S3 bucket triggers notifications whenever a new valid data record lands in the `data/` folder.
This allows consumers to subscribe and retrieve the data for further processing.

### Provisioning Strategy
Given my experience, I chose Terraform for managing the infrastructure.
To streamline the development process, I initially stored the Terraform state locally.

Possible improvements:
- **Consider a CI/CD pipeline**: To automate infrastructure provisioning and ensure consistency, implement a CI/CD pipeline. This pipeline can execute `terraform plan` when a pull request is created, allowing for code review and validation. Upon merging the pull request into the main branch, `terraform apply` can be triggered to apply the changes to the infrastructure.
- **Remote state storage**: For improved collaboration and resilience, the Terraform state can be stored in a remote backend, such as an S3 bucket. If a pre-existing bucket is available, it can be used.

## Prerequisites
In order to deploy infrastructure, the [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) is required.

To locally test using a producer mock, the [Docker Engine](https://docs.docker.com/engine/install/) is required.

## Instructions
1. Clone this repository locally;

2. Go to `terraform` directory:

  ```shell
  cd terraform/
  ```

3. Initialize Terraform state:

  ```shell
  terraform init
  ```

4. Create a Terraform plan:

  ```shell
  terraform plan
  ```

5. Apply the infrastructure:

  ```shell
  terraform apply
  ```

### Using the application
After creation of all resources, producers are allowed to send data to this application. Data can be sent using several tools as explained in this [article](https://docs.aws.amazon.com/streams/latest/dev/building-producers.html) from AWS.

There is a small producer in this repository written in Python and deployed as a Docker Container. This producer creates random data sending it to the Kinesis Data Stream. The data uses a schema registered as "producer2" and its code is in [this](producers/producer2) folder.

To start this producer locally, run the following code in the repository root:

```shell
cd producers/producer2/
./run.sh
```