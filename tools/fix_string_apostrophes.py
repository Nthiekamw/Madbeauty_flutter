"""Escape French apostrophes inside single-quoted Dart string literals."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "lib"
TARGETS = [
    ROOT / "core" / "constants" / "strings",
    ROOT / "features" / "messaging" / "logic" / "chat_message_templates.dart",
]

STRING_START_BEFORE = "=,(?: \t?!+-|&"


def is_closing_quote(text: str, index: int) -> bool:
    rest = text[index + 1 :]
    if not rest:
        return True
    ch = rest[0]
    if ch in ";,).]}\n\r":
        return True
    if rest.startswith(" :") or rest.startswith(":"):
        return True
    if ch in " \t" and (len(rest) == 1 or rest[1] in ";,)+"):
        return True
    if ch == "+" and rest[1:].lstrip().startswith("'"):
        return True
    return False


def may_start_string(text: str, index: int) -> bool:
    if index == 0:
        return True
    prev = text[index - 1]
    return prev in STRING_START_BEFORE


def fix_single_quoted_string(text: str, start: int) -> tuple[str, int]:
    i = start + 1
    parts = ["'"]
    while i < len(text):
        ch = text[i]
        if ch == "\\" and i + 1 < len(text):
            parts.append(text[i : i + 2])
            i += 2
            continue
        if ch == "$" and i + 1 < len(text) and text[i + 1] == "{":
            depth = 1
            parts.append("${")
            i += 2
            while i < len(text) and depth:
                c = text[i]
                if c == "{":
                    depth += 1
                elif c == "}":
                    depth -= 1
                parts.append(c)
                i += 1
            continue
        if ch == "'":
            if is_closing_quote(text, i):
                parts.append("'")
                return "".join(parts), i + 1
            parts.append("\\'")
            i += 1
            continue
        parts.append(ch)
        i += 1
    return "".join(parts), i


def fix_line(line: str) -> str:
    stripped = line.lstrip()
    if stripped.startswith("//") or stripped.startswith("///"):
        return line

    out: list[str] = []
    i = 0
    n = len(line)
    while i < n:
        ch = line[i]
        if ch == "'" and (i == 0 or line[i - 1] != "\\") and may_start_string(line, i):
            if i > 0 and line[i - 1] in "rR":
                out.append(ch)
                i += 1
                continue
            fixed, end = fix_single_quoted_string(line, i)
            out.append(fixed)
            i = end
            continue
        out.append(ch)
        i += 1
    return "".join(out)


def fix_content(text: str) -> str:
    return "\n".join(fix_line(line) for line in text.splitlines()) + (
        "\n" if text.endswith("\n") else ""
    )


def iter_dart_files() -> list[Path]:
    files: list[Path] = []
    for target in TARGETS:
        if target.is_file():
            files.append(target)
        elif target.is_dir():
            files.extend(target.rglob("*.dart"))
    return files


def main() -> None:
    changed: list[Path] = []
    for path in iter_dart_files():
        original = path.read_text(encoding="utf-8")
        updated = fix_content(original)
        if updated != original:
            path.write_text(updated, encoding="utf-8", newline="\n")
            changed.append(path)

    print(f"Fixed {len(changed)} files")
    for path in sorted(changed):
        print(path.relative_to(ROOT.parent))


if __name__ == "__main__":
    main()
