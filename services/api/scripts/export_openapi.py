"""Writes the API's OpenAPI schema to packages/contracts/openapi.json.

The mobile (and eventually web) client is generated from this file — see
`apps/mobile`'s `chore: generate dart api client` task. Re-run this whenever
a router or schema changes, then regenerate the client.
"""

import json
from pathlib import Path
from typing import Any

from app.main import app

OUTPUT_PATH = Path(__file__).resolve().parents[3] / "packages" / "contracts" / "openapi.json"


def _simplify_for_dart_client(schema: dict[str, Any]) -> None:
    """Works around two openapi-generator (dart-dio) template bugs that
    otherwise produce Dart that fails to parse:

    - A `const: true` boolean field (from a Pydantic `Literal[True]`, e.g.
      `MfaRequiredResponse.mfa_required`) is generated as a broken
      single-value string enum instead of a plain bool. Dropping `const`
      keeps the field a plain `bool`.
    - An `anyOf` array-item schema with no object properties (`ValidationError
      .loc`, whose items are `str | int`) generates an empty class with a
      broken `==`/`hashCode`. Narrowing it to `string` loses the int-vs-str
      distinction for path segments, which nothing here needs.
    """
    schemas = schema.get("components", {}).get("schemas", {})

    def strip_boolean_const(node: Any) -> None:
        if isinstance(node, dict):
            if node.get("type") == "boolean" and "const" in node:
                del node["const"]
            for value in node.values():
                strip_boolean_const(value)
        elif isinstance(node, list):
            for item in node:
                strip_boolean_const(item)

    strip_boolean_const(schemas)

    loc = schemas.get("ValidationError", {}).get("properties", {}).get("loc")
    if loc is not None:
        loc["items"] = {"type": "string"}


def main() -> None:
    schema = app.openapi()
    _simplify_for_dart_client(schema)
    OUTPUT_PATH.write_text(json.dumps(schema, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
