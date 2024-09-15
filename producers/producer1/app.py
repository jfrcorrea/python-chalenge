"""Implementation for Producer 1."""

import json
import random
import string
from datetime import datetime, UTC
from uuid import uuid4


def main() -> None:
    """Execute the main code."""
    chars = string.ascii_uppercase + string.digits
    while True:
        data = {
            "id": str(uuid4()),
            "name": "".join(random.choice(chars) for _ in range(random.randrange(6, 19))),
            "created_at": int(datetime.now(UTC).timestamp() * 1000),
        }
        print(json.dumps(data))


if __name__ == "__main__":
    main()
