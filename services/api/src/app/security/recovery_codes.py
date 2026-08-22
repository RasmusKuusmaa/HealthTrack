import secrets

_ALPHABET = "abcdefghjkmnpqrstuvwxyz23456789"  # no 0/o/1/l/i ambiguity
_GROUP_SIZE = 5
_GROUPS = 2


def generate_recovery_code() -> str:
    """A human-typeable single-use code, e.g. 'k3n7q-8h2mz'."""
    groups = [
        "".join(secrets.choice(_ALPHABET) for _ in range(_GROUP_SIZE))
        for _ in range(_GROUPS)
    ]
    return "-".join(groups)


def normalize_recovery_code(code: str) -> str:
    """Case/whitespace-insensitive comparison key for a submitted code."""
    return code.strip().lower()
