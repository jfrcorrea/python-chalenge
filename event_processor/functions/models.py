"""
Producers schema registry.

All producers must be registered here as a Pydantic model.
"""

from pydantic import BaseModel


class Producer1(BaseModel):
    """Schema for the producer "Producer1"."""

    id: str  # The unique identifier for the Producer 1
    name: str  # A random name for each ID
    created_at: int  # Timestamp at creation time, in milliseconds since Unix Epoch.


class Producer2(BaseModel):
    """Schema for the producer "Producer2"."""

    id: str  # The unique identifier for the Producer 2
    value: float  # A random number between 0 and 100.0
    created_at: int  # Timestamp at creation time, in milliseconds since Unix Epoch.
