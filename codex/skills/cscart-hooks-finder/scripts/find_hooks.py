#!/usr/bin/env python3
"""Find and rank relevant CS-Cart hooks by query keywords."""

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List


@dataclass
class HookMatch:
    kind: str
    name: str
    file: str
    line: int
    score: int


def keywords(text: str) -> List[str]:
    return [item for item in re.split(r'[^a-zA-Z0-9_]+', text.lower()) if len(item) > 2]


def iter_files(root: Path) -> Iterable[Path]:
    for path in root.rglob('*'):
        if not path.is_file():
            continue
        if path.suffix.lower() not in {'.php', '.tpl'}:
            continue
        if '/vendor/' in str(path).replace('\\', '/'):
            continue
        yield path


def score(name: str, terms: List[str]) -> int:
    lowered = name.lower()
    return sum(3 for term in terms if term in lowered)


def find_hooks(project_root: Path, query: str) -> List[HookMatch]:
    terms = keywords(query)
    matches: List[HookMatch] = []

    php_pattern = re.compile(r"fn_set_hook\(\s*'([^']+)'")
    tpl_pattern = re.compile(r'{hook\s+name="([^"]+)"')

    for path in iter_files(project_root):
        try:
            lines = path.read_text(encoding='utf-8').splitlines()
        except UnicodeDecodeError:
            continue

        for idx, line in enumerate(lines, start=1):
            php_match = php_pattern.search(line)
            if php_match:
                hook_name = php_match.group(1)
                hook_score = score(hook_name, terms)
                if hook_score > 0 or not terms:
                    matches.append(HookMatch('php', hook_name, str(path), idx, hook_score))

            tpl_match = tpl_pattern.search(line)
            if tpl_match:
                hook_name = tpl_match.group(1)
                hook_score = score(hook_name, terms)
                if hook_score > 0 or not terms:
                    matches.append(HookMatch('tpl', hook_name, str(path), idx, hook_score))

    matches.sort(key=lambda item: (-item.score, item.kind, item.name, item.file, item.line))
    return matches


def print_report(matches: List[HookMatch], limit: int) -> None:
    if not matches:
        print('No hooks matched query.')
        return

    print('Suggested hooks (sorted by relevance):')
    for item in matches[:limit]:
        print(f"{item.kind.upper()} -> {item.name} -> {item.file}:{item.line} -> score={item.score}")


def main() -> None:
    parser = argparse.ArgumentParser(description='Find CS-Cart hooks by feature query.')
    parser.add_argument('--project-root', required=True, help='CS-Cart project root.')
    parser.add_argument('--query', required=True, help='Feature description for hook matching.')
    parser.add_argument('--limit', type=int, default=40, help='Max lines in report.')
    args = parser.parse_args()

    project_root = Path(args.project_root).resolve()
    if not project_root.exists():
        raise SystemExit(f'Project root not found: {project_root}')

    matches = find_hooks(project_root, args.query)
    print_report(matches, max(1, args.limit))


if __name__ == '__main__':
    main()
