"""
Producers schema registry.

All producers must be registered here as a Pydantic model.
"""

from dataclasses import dataclass


@dataclass
class Producer1:
    """Schema for the producer "Producer1"."""

    id: str  # The unique identifier for the Producer 1
    name: str  # A random name for each ID
    created_at: int  # Timestamp at creation time, in milliseconds since Unix Epoch.

    def __post_init__(self):
        """Validate the instance for Producer 1."""
        assert isinstance(self.id, str), "`id` is not a str"
        assert isinstance(self.name, str), "`name` is not a str"
        assert isinstance(self.created_at, int), "`created_at` is not an int"


@dataclass
class Producer2:
    """Schema for the producer "Producer2"."""

    id: str  # The unique identifier for the Producer 2
    value: float  # A random number between 0 and 100.0
    created_at: int  # Timestamp at creation time, in milliseconds since Unix Epoch.

    def __post_init__(self):
        """Validate the instance for Producer 1."""
        assert isinstance(self.id, str), "`id` is not a str"
        assert isinstance(self.value, float), "`value` is not a float"
        assert isinstance(self.created_at, int), "`created_at` is not an int"
