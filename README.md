# Python Challenge

## Introduction
This is an app to process data events sent by several "Event Producers" and deliver to a "Sender" responsible for spread the processed events to subscribed clients.

## Architecture overview

## Prerequisites

### Dev environment
Make sure you have Python 3.12 installed.

To create a dev environment, you need to install [Poetry](https://python-poetry.org/docs/#installation).

Them install Python libraries and activate the virtual environment:
```shell
poetry install
poetry shell
```

### LocalStack
Start LocalStack using `docker-compose`:
```shell
docker compose up
```

## Instructions
You can create the AWS infrastructure on LocalStack by running:
```shell
bin/deploy.sh
```

### Using the application

### Run integration tests
Once all resource are created on LocalStack, you can run the automated integration tests.
```shell
pytest tests/
```
