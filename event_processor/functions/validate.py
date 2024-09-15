from pydantic import ValidationError


def handler(events, context):
    print(f"events: {events}")
    print(f"context: {context.__dict__}")
