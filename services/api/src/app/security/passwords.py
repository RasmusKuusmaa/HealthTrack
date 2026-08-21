from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

# Tuned above argon2-cffi's library defaults per OWASP's Argon2id guidance
# (minimum m=19 MiB, t=2, p=1) — sized for a single request thread, not a
# batch job, so parallelism stays low while memory cost stays high.
_hasher = PasswordHasher(
    time_cost=3,
    memory_cost=65536,  # 64 MiB
    parallelism=2,
    hash_len=32,
    salt_len=16,
)


def hash_password(password: str) -> str:
    return _hasher.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    try:
        return _hasher.verify(password_hash, password)
    except VerifyMismatchError:
        return False


def needs_rehash(password_hash: str) -> bool:
    """True if the hash was made with different parameters than the current
    tuning — callers should rehash on next successful login."""
    return _hasher.check_needs_rehash(password_hash)
