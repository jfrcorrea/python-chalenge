#!/usr/bin/env python3
"""Create the Event Processor app."""
import aws_cdk as cdk

from event_processor.event_processor_stack import EventProcessorStack


app = cdk.App()
EventProcessorStack(app, "EventProcessorStack")

app.synth()
