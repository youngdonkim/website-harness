#!/usr/bin/env bash
# new-project.sh — 하네스를 적용할 새 프로젝트 폴더를 만든다.
#
# 왜 필요한가: 클로드 코드는 세션을 열 때 있던 .claude/skills/·.claude/agents/ 폴더만 지켜본다.
#   그 폴더가 없이 열린 세션에는 도중에 넣은 스킬·에이전트가 끝까지 잡히지 않는다.
#   빈 폴더만이라도 먼저 있으면 도중에 넣은 것이 몇 초 뒤 잡힌다. 그래서 세션을 열기 전에 이 스크립트로 만든다.
#
# 쓰는 법:  ~/dev/website-harness/new-project.sh <새 프로젝트 폴더 경로>
#   만드는 것: 그 폴더, 빈 .claude/skills/·agents/·hooks/, 내용이 {} 뿐인 .claude/settings.json
#   폴더가 비어 있지 않으면(.git만 있는 건 빈 것으로 본다) 아무것도 하지 않고 1로 끝난다.
# 맥 기본 bash 3.2·리눅스·윈도우 Git Bash에서 돈다(연관 배열·mapfile 등을 쓰지 않는다).

set -euo pipefail

usage() {
  echo "쓰는 법: $0 <새 프로젝트 폴더 경로>" >&2
  echo "  예: $0 ~/dev/my-service" >&2
  echo "  폴더가 없으면 만들고, 있으면 비어 있어야 합니다(.git만 있는 건 괜찮습니다)." >&2
}

if [ "$#" -ne 1 ] || [ -z "$1" ]; then
  usage
  exit 1
fi

TARGET=$1

if [ -e "$TARGET" ] && [ ! -d "$TARGET" ]; then
  echo "폴더가 아닌 파일이 이미 있습니다: $TARGET" >&2
  usage
  exit 1
fi

if [ -d "$TARGET" ]; then
  # .git 말고 다른 것이 하나라도 있으면 비어 있지 않은 폴더다.
  other=$(find "$TARGET" -mindepth 1 -maxdepth 1 ! -name .git 2>/dev/null | head -n 1)
  if [ -n "$other" ]; then
    echo "비어 있지 않은 폴더입니다: $TARGET" >&2
    usage
    exit 1
  fi
fi

mkdir -p "$TARGET/.claude/skills" "$TARGET/.claude/agents" "$TARGET/.claude/hooks"

if [ ! -e "$TARGET/.claude/settings.json" ]; then
  printf '{}\n' > "$TARGET/.claude/settings.json"
fi

echo "새 프로젝트 폴더를 만들었습니다: $TARGET"
echo "이 폴더에서 새 세션을 열고 『하네스 적용해줘』라고 하세요."
