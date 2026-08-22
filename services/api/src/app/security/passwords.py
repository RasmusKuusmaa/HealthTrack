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


# A precomputed hash with no matching password, verified against on login
# when the given email doesn't match a user — so a nonexistent account
# still pays the same Argon2 cost as a real one, closing the timing gap
# that would otherwise reveal whether an email address is registered.
DUMMY_PASSWORD_HASH = hash_password("dummy-password-for-timing-safety")
