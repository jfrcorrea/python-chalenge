"""Lambda Function's main module."""

import base64
import json

import models

# Producers schema registry
producers = {
    "producer1": models.Producer1,
    "producer2": models.Producer2,
}


def handler(event, context):
    """Entrypoint of the Lambda Function."""
    output = []

    # Loop over all incoming records
    for record in event["records"]:
        print("recordId: " + record["recordId"])

        # Decode the current record and parse it as a dict
        payload = base64.b64decode(record["data"]).decode("utf-8")
        payload_dict = json.loads(payload)
        if not isinstance(payload_dict, dict):
            # Mark record as failed when payload is not a JSON object
            data_dict = {"payload": payload, "errors": "Payload is not a JSON object"}
            output_record = {
                "recordId": record["recordId"],
                "result": "ProcessingFailed",
                "data": base64.b64encode(json.dumps(data_dict).encode("utf-8")).decode("utf-8"),
            }
            output.append(output_record)
            continue

        producer_name = payload_dict.get("producer")
        if not producer_name:
            data_dict = {**payload_dict, "errors": "The key `producer`  not found in payload"}
            output_record = {
                "recordId": record["recordId"],
                "result": "ProcessingFailed",
                "data": base64.b64encode(json.dumps(data_dict).encode("utf-8")).decode("utf-8"),
            }
            output.append(output_record)
            continue

        validator = producers.get(producer_name)
        if not validator:
            data_dict = {**payload_dict, "errors": "Producer not registered"}
            output_record = {
                "recordId": record["recordId"],
                "result": "ProcessingFailed",
                "data": base64.b64encode(json.dumps(data_dict).encode("utf-8")).decode("utf-8"),
            }
            output.append(output_record)
            continue
        try:
            # Validate payload schema
            validator(**{key: value for key, value in payload_dict.items() if key not in ("producer")})
            result = "Ok"
        except AssertionError as e:
            payload_dict["errors"] = str(e)
            result = "ProcessingFailed"

        output_record = {
            "recordId": record["recordId"],
            "result": result,
            "data": base64.b64encode(json.dumps(payload_dict).encode("utf-8")).decode("utf-8"),
        }
        output.append(output_record)

    print("Successfully processed {} records.".format(len(event["records"])))

    return {"records": output}
