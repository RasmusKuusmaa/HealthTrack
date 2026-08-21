from app.security.passwords import hash_password, needs_rehash, verify_password


def test_hash_uses_argon2id() -> None:
    hashed = hash_password("correct horse battery staple")
    assert hashed.startswith("$argon2id$")


def test_verify_succeeds_with_correct_password() -> None:
    hashed = hash_password("correct horse battery staple")
    assert verify_password("correct horse battery staple", hashed) is True


def test_verify_fails_with_wrong_password() -> None:
    hashed = hash_password("correct horse battery staple")
    assert verify_password("wrong password", hashed) is False


def test_hashes_are_salted_and_unique() -> None:
    first = hash_password("same password")
    second = hash_password("same password")
    assert first != second


def test_current_hash_does_not_need_rehash() -> None:
    hashed = hash_password("correct horse battery staple")
    assert needs_rehash(hashed) is False
