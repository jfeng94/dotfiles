#!/usr/bin/env python3
"""ordered_grep.py — Grep for multiple patterns and show matches in the order patterns were given.

Usage:
    echo "..." | python3 ordered_grep.py pattern1 pattern2 ...
    grep -r something . | python3 ordered_grep.py pattern1 pattern2 ...
    cat file | python3 ordered_grep.py pattern1 pattern2 ...
"""
import re
import sys


def main():
    if len(sys.argv) < 2:
        print(__doc__, file=sys.stderr)
        sys.exit(1)

    patterns = sys.argv[1:]
    compiled = [re.compile(p) for p in patterns]

    # Bucket lines by first matching pattern
    buckets: dict[int, list[str]] = {i: [] for i in range(len(patterns))}
    unmatched: list[str] = []

    for line in sys.stdin:
        matched = False
        for i, pat in enumerate(compiled):
            if pat.search(line):
                buckets[i].append(line)
                matched = True
                break
        if not matched:
            unmatched.append(line)

    for i, pat in enumerate(patterns):
        for line in buckets[i]:
            sys.stdout.write(line)


if __name__ == "__main__":
    main()
