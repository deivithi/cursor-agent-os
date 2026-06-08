"""
Schema utilities for document extraction.

Converts Pydantic models to flat JSON schemas suitable for LLM-based
structured extraction. Absorbed from LandingAI ADE — pure Python, zero cost.
"""

import copy
import json
from typing import Any, Dict, Type

from pydantic import BaseModel


def _resolve_refs(obj: Any, defs: Dict[str, Any]) -> Any:
    """
    Resolve JSON Schema $refs to create a flat schema.

    Recursively replaces all $ref references with their definitions
    from the $defs section, producing a self-contained schema.
    """
    if isinstance(obj, dict):
        if "$ref" in obj and isinstance(obj["$ref"], str):
            ref_name = obj["$ref"].split("/")[-1]
            return _resolve_refs(copy.deepcopy(defs[ref_name]), defs)
        return {k: _resolve_refs(v, defs) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [_resolve_refs(item, defs) for item in obj]
    return obj


def pydantic_to_json_schema(model: Type[BaseModel]) -> str:
    """
    Convert a Pydantic model to a flat JSON schema string.

    All $refs are resolved inline, producing a schema that any LLM
    can consume directly without needing a JSON Schema resolver.

    Args:
        model: A Pydantic BaseModel subclass defining the extraction target.

    Returns:
        JSON string with all references resolved.

    Example:
        >>> from pydantic import BaseModel, Field
        >>> class Invoice(BaseModel):
        ...     number: str = Field(description="Numero da fatura")
        ...     total: float = Field(description="Valor total")
        >>> schema = pydantic_to_json_schema(Invoice)
    """
    if not hasattr(model, "model_json_schema"):
        raise TypeError("model must be a Pydantic BaseModel subclass")

    schema = model.model_json_schema()
    defs = schema.pop("$defs", {})
    schema = _resolve_refs(schema, defs)
    return json.dumps(schema)
