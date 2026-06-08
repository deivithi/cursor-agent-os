"""
Markdown chunker for document extraction.

Splits markdown output (from MarkItDown) into typed chunks,
replicating ADE's chunk classification without bounding boxes.
"""

import re
import uuid
from dataclasses import dataclass, field, asdict
from typing import List


@dataclass
class Chunk:
    id: str
    type: str
    markdown: str
    line_start: int
    line_end: int


@dataclass
class ChunkedDocument:
    markdown: str
    chunks: List[Chunk]
    metadata: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        return {
            "markdown": self.markdown,
            "chunks": [asdict(c) for c in self.chunks],
            "metadata": self.metadata,
        }


# --- Patterns ---

_TABLE_ROW = re.compile(r"^\s*\|.+\|\s*$")
_TABLE_SEP = re.compile(r"^\s*\|[-:| ]+\|\s*$")
_HEADING = re.compile(r"^(#{1,6})\s+(.+)$")
_IMAGE = re.compile(r"!\[([^\]]*)\]\(([^)]+)\)")
_LIST_ITEM = re.compile(r"^\s*[-*+]|\s*\d+\.\s")
_CODE_FENCE = re.compile(r"^```")


def chunk_markdown(markdown: str, source: str = "unknown") -> ChunkedDocument:
    """
    Split markdown into typed chunks.

    Chunk types:
        chunkTitle   — headings (# to ######)
        chunkTable   — markdown tables (| ... |)
        chunkFigure  — image references ![alt](url)
        chunkList    — bullet or numbered lists
        chunkCode    — fenced code blocks
        chunkText    — everything else (paragraphs)

    Args:
        markdown: Raw markdown string (typically from MarkItDown).
        source: Filename or URI of the original document.

    Returns:
        ChunkedDocument with typed chunks and metadata.
    """
    lines = markdown.split("\n")
    chunks: List[Chunk] = []
    i = 0
    total = len(lines)

    def _make_id() -> str:
        return uuid.uuid4().hex[:12]

    def _flush_buffer(buf: List[str], chunk_type: str, start: int, end: int):
        text = "\n".join(buf).strip()
        if text:
            chunks.append(Chunk(
                id=_make_id(),
                type=chunk_type,
                markdown=text,
                line_start=start,
                line_end=end,
            ))

    buffer: List[str] = []
    buf_type = "chunkText"
    buf_start = 0

    while i < total:
        line = lines[i]

        # --- Code fence ---
        if _CODE_FENCE.match(line):
            _flush_buffer(buffer, buf_type, buf_start, i - 1)
            buffer = [line]
            buf_start = i
            i += 1
            while i < total and not _CODE_FENCE.match(lines[i]):
                buffer.append(lines[i])
                i += 1
            if i < total:
                buffer.append(lines[i])
                i += 1
            _flush_buffer(buffer, "chunkCode", buf_start, i - 1)
            buffer = []
            buf_type = "chunkText"
            buf_start = i
            continue

        # --- Heading ---
        heading_m = _HEADING.match(line)
        if heading_m:
            _flush_buffer(buffer, buf_type, buf_start, i - 1)
            chunks.append(Chunk(
                id=_make_id(),
                type="chunkTitle",
                markdown=line.strip(),
                line_start=i,
                line_end=i,
            ))
            buffer = []
            buf_type = "chunkText"
            buf_start = i + 1
            i += 1
            continue

        # --- Table ---
        if _TABLE_ROW.match(line):
            _flush_buffer(buffer, buf_type, buf_start, i - 1)
            table_lines = []
            table_start = i
            while i < total and (_TABLE_ROW.match(lines[i]) or _TABLE_SEP.match(lines[i])):
                table_lines.append(lines[i])
                i += 1
            _flush_buffer(table_lines, "chunkTable", table_start, i - 1)
            buffer = []
            buf_type = "chunkText"
            buf_start = i
            continue

        # --- Image ---
        if _IMAGE.search(line) and line.strip().startswith("!"):
            _flush_buffer(buffer, buf_type, buf_start, i - 1)
            chunks.append(Chunk(
                id=_make_id(),
                type="chunkFigure",
                markdown=line.strip(),
                line_start=i,
                line_end=i,
            ))
            buffer = []
            buf_type = "chunkText"
            buf_start = i + 1
            i += 1
            continue

        # --- List ---
        if _LIST_ITEM.match(line):
            if buf_type != "chunkList":
                _flush_buffer(buffer, buf_type, buf_start, i - 1)
                buffer = []
                buf_type = "chunkList"
                buf_start = i
            buffer.append(line)
            i += 1
            continue

        # --- Text (default) ---
        if buf_type == "chunkList" and not _LIST_ITEM.match(line) and line.strip():
            _flush_buffer(buffer, buf_type, buf_start, i - 1)
            buffer = []
            buf_type = "chunkText"
            buf_start = i

        if buf_type != "chunkList":
            buf_type = "chunkText"
        buffer.append(line)
        i += 1

    _flush_buffer(buffer, buf_type, buf_start, total - 1)

    return ChunkedDocument(
        markdown=markdown,
        chunks=chunks,
        metadata={
            "source": source,
            "total_chunks": len(chunks),
            "chunk_types": dict(_count_types(chunks)),
        },
    )


def _count_types(chunks: List[Chunk]) -> List[tuple]:
    counts: dict = {}
    for c in chunks:
        counts[c.type] = counts.get(c.type, 0) + 1
    return sorted(counts.items())
