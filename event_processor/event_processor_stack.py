"""Create the infrastructure."""

import os
import aws_cdk as cdk
from aws_cdk import (
    aws_iam as iam,
    aws_kinesis as kinesis,
    aws_lambda as lambda_,
    aws_pipes as pipes,
    aws_sqs as sqs,
    Stack,
)
from constructs import Construct

# Load environment-specific configuration
THIS_FOLDER = os.path.dirname(os.path.realpath(__file__))
LAMBDA_PYTHON_VALIDATION = os.path.join(THIS_FOLDER, "functions/validate.py")


def load_file(path: str) -> str:
    """Return the file content.

    Args:
        path (str): Path to the file.

    Returns:
        str: File content.
    """
    with open(path, "r") as file:
        return file.read()


class EventProcessorStack(Stack):
    """Create the Event Processor infrastructure."""

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        """
        Initialize the Stack class.

        Args:
            scope (Construct): App of this stack.
            construct_id (str): The construct ID of this stack. This id will be used to determine the physical ID of the
              stack.
        """
        super().__init__(scope, construct_id, **kwargs)

        # Resources
        source_stream = kinesis.Stream(self, "SourceStream", shard_count=3)
        dlq = sqs.Queue(self, "DLQ")
        validate_function = lambda_.Function(
            self,
            "Function",
            runtime=lambda_.Runtime.PYTHON_3_12,
            handler="index.handler",
            timeout=cdk.Duration.seconds(60),
            code=lambda_.InlineCode(code=load_file(LAMBDA_PYTHON_VALIDATION)),
        )

        target_stream = kinesis.Stream(self, "TargetStream", shard_count=1)

        # IAM
        pipe_role = iam.Role(self, "PipeRole", assumed_by=iam.ServicePrincipal("pipes.amazonaws.com"))
        source_stream.grant_read(pipe_role)
        dlq.grant_send_messages(pipe_role)
        validate_function.grant_invoke(pipe_role)
        target_stream.grant_write(pipe_role)

        # Pipe
        pipe = pipes.CfnPipe(
            self,
            "Pipe",
            role_arn=pipe_role.role_arn,
            source=source_stream.stream_arn,
            source_parameters=pipes.CfnPipe.PipeSourceParametersProperty(
                kinesis_stream_parameters=pipes.CfnPipe.PipeSourceKinesisStreamParametersProperty(
                    starting_position="TRIM_HORIZON",
                    dead_letter_config=pipes.CfnPipe.DeadLetterConfigProperty(arn=dlq.queue_arn),
                    maximum_retry_attempts=1,
                    batch_size=2,
                ),
            ),
            enrichment=validate_function.function_arn,
            target=target_stream.stream_arn,
            target_parameters=pipes.CfnPipe.PipeTargetParametersProperty(
                kinesis_stream_parameters=pipes.CfnPipe.PipeTargetKinesisStreamParametersProperty(
                    partition_key="target-partition-key-0"
                )
            ),
        )

        # Outputs
        cdk.CfnOutput(self, "PipeName", value=pipe.ref)
        cdk.CfnOutput(self, "SourceStreamName", value=source_stream.stream_name)
        cdk.CfnOutput(self, "DlqUrl", value=dlq.queue_url)
        cdk.CfnOutput(self, "DlqName", value=dlq.queue_name)
        cdk.CfnOutput(self, "ValidateFunctionName", value=validate_function.function_name)
        cdk.CfnOutput(self, "TargetStreamName", value=target_stream.stream_name)
        cdk.CfnOutput(self, "RoleName", value=pipe_role.role_name)
