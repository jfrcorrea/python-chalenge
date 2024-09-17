"""
Implementation for Producer 2.

This producer randomly adds an error in the data to assess the "Event Processor".
"""

import json
import random
import time
import typing
from datetime import UTC, datetime
from uuid import uuid4

import boto3

AWS_DEFAULT_REGION = "us-east-1"


def add_field(data: dict[str, typing.Any]) -> dict[str, typing.Any]:
    """Add a field in the data received, to emulate an schema error.

    Args:
        data (dict[str, typing.Any]): Data to be modified.

    Returns:
        dict[str, typing.Any]: Data after modification.
    """
    return {**data, "xpto": "Added field"}


def change_field(data: dict[str, typing.Any]) -> dict[str, typing.Any]:
    """Change a field in the data received, to emulate an schema error.

    Args:
        data (dict[str, typing.Any]): Data to be modified.

    Returns:
        dict[str, typing.Any]: Data after modification.
    """
    new_data = data
    new_data["value"] = str(new_data["value"])
    return new_data


def main() -> None:
    """Execute the main code."""
    kinesis_client = boto3.client(
        "kinesis",
        region_name=AWS_DEFAULT_REGION,
    )
    random.seed()
    while True:
        data = {
            "id": str(uuid4()),
            "value": random.random() * 100,
            "created_at": int(datetime.now(UTC).timestamp() * 1000),
            "producer": "producer2",
        }
        # Randomly force an error
        if random.randint(0, 10) == 0:
            # Coin flip
            if random.randint(0, 1):
                # When false, add an unexpected field
                data = add_field(data)
                print("add an unexpected field")
            else:
                # When true, change a field type
                data = change_field(data)
                print("change a field type")
        kinesis_client.put_record(
            StreamName="SourceStream",
            Data=json.dumps(data),
            PartitionKey=data["id"],
        )
        print("record sent")
        time.sleep(0.1)


if __name__ == "__main__":
    main()
