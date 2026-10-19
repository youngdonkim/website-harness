#!/bin/bash
# owner-runner-guard.sh — PreToolUse(Bash) guard
#
# 키가 필요한 CLI(gh·vercel·supabase 클라우드 명령)를 실행기 없이 부르면 막는다.
#
# 왜: gh·vercel·supabase의 로그인은 컴퓨터 전체에 하나다. github-connect가 장부 토큰을
#   꺼내려고 gh에 로그인하면 그 로그인이 남는다. 실행기(.claude/scripts/with-owner.sh)를
#   빼고 부르면 장부가 아니라 그 남은 로그인으로 돌아, 소유가 다른 프로젝트(개인·회사)가
#   한 컴퓨터에 있을 때 PR·배포가 조용히 다른 계정으로 만들어진다.
#   (실측 2026-10-19: 하네스 저장소 PR을 실행기 없이 기본 gh 로그인으로 만듦 — 계정이
#   같아 사고는 아니었지만 규칙 문장만으로는 안 막혔다)
#
# 막는 것 — 명령 조각의 첫 실행 낱말이 아래이고, 실행기를 앞에 붙이지 않은 경우:
#   - gh <무엇이든>            예외: gh auth …(github-connect가 전역 로그인을 다룸)·
#                               gh --version·gh version·gh help·인자 없는 gh
#   - vercel <무엇이든>         예외: --version·-v·help·인자 없는 vercel
#   - supabase 클라우드 명령    login·link·projects·orgs·secrets·functions·branches·
#                               inspect·db push|pull|dump·migration list|repair|fetch,
#                               또는 --linked·--project-ref 가 붙은 명령.
#                               로컬 스택(start·stop·status·db reset·migration new 등)은 통과.
#   npx·npm exec·fnm exec … --·env·command·exec·time·NAME=값 접두는 건너뛰고 본다.
#
# 통과시키는 것:
#   - 조각이 실행기로 시작 (…/with-owner.sh 명령…) — 접두를 건너뛴 뒤의 첫 낱말 기준
#   - 조각 앞에 GH_TOKEN=·VERCEL_TOKEN=·SUPABASE_ACCESS_TOKEN= 를 직접 준 경우
#     (github-connect가 새로 받은 토큰을 장부에 넣기 전에 한 번 확인하는 자리)
#   - 명령이 실행될 폴더에 .claude/scripts/with-owner.sh 가 없는 경우(하네스 밖 폴더)
#   - jq가 없을 때(검사를 못 하니 통과 — main push는 no-main-push가 따로 막는다)
#
# 정밀화: 따옴표 안 글(커밋 메시지 등)과 리다이렉션을 먼저 지우고, shell separator
#   (&&, ||, ;, |, &, $( , ( , ), 백틱)로 조각을 나눠 조각마다 첫 실행 낱말만 본다.
#   `cd <폴더>` 조각은 뒤 조각의 「명령이 실행될 폴더」를 바꾼다.
#   bash -c "…" 처럼 따옴표 안에 숨긴 명령은 못 본다(놓치는 쪽 — 규칙 문장이 같이 막는다).

set -euo pipefail

INPUT=$(cat)
command -v jq >/dev/null 2>&1 || exit 0

COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
HOOK_CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // empty' 2>/dev/null || echo "")
BASE_DIR="${HOOK_CWD:-${CLAUDE_PROJECT_DIR:-.}}"

[ -z "$COMMAND" ] && exit 0

# 따옴표 안 글 → 빈 따옴표, 리다이렉션 지우기, 조각 나누기
STRIPPED=$(printf '%s' "$COMMAND" \
  | sed -E "s/'[^']*'/''/g" \
  | sed -E 's/"([^"\\]|\\.)*"/""/g' \
  | sed -E 's/[0-9]*[<>]&[0-9-]+//g; s/[0-9]*>>?[[:space:]]*[^[:space:];&|]+//g')
NORMALIZED=$(printf '%s' "$STRIPPED" | sed -E 's/(&&|\|\||;|\||&|\$\(|\(|\)|`)/\n/g')

blocked=""
while IFS= read -r sub; do
  tokens=()
  IFS=$' \t' read -r -a tokens <<< "$sub" || true
  n=${#tokens[@]}
  [ "$n" -eq 0 ] && continue

  if [ "${tokens[0]}" = "cd" ]; then
    cd_to="${tokens[1]:-$HOME}"
    cd_to="${cd_to/#\~/$HOME}"
    case "$cd_to" in
      /*) BASE_DIR="$cd_to" ;;
      *)  BASE_DIR="$BASE_DIR/$cd_to" ;;
    esac
    continue
  fi

  [ -f "$BASE_DIR/.claude/scripts/with-owner.sh" ] || continue

  # 접두 건너뛰기
  i=0
  explicit_token=0
  while [ "$i" -lt "$n" ]; do
    t="${tokens[$i]}"
    case "$t" in
      GH_TOKEN=*|VERCEL_TOKEN=*|SUPABASE_ACCESS_TOKEN=*)
        explicit_token=1; i=$((i + 1)) ;;
      env|command|exec|time|npx)
        i=$((i + 1)) ;;
      -u|--unset)
        i=$((i + 2)) ;;
      -*)
        # env -i, npx -y/--yes 같은 접두 옵션
        i=$((i + 1)) ;;
      npm)
        [ "${tokens[$((i + 1))]:-}" = "exec" ] && i=$((i + 2)) || break ;;
      fnm)
        # fnm exec … -- 명령
        k=$((i + 1))
        while [ "$k" -lt "$n" ] && [ "${tokens[$k]}" != "--" ]; do k=$((k + 1)); done
        [ "$k" -lt "$n" ] && i=$((k + 1)) || break ;;
      *)
        if [[ "$t" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]]; then i=$((i + 1)); else break; fi ;;
    esac
  done
  [ "$i" -ge "$n" ] && continue

  cmd="${tokens[$i]##*/}"
  [ "$cmd" = "with-owner.sh" ] && continue
  [ "$explicit_token" -eq 1 ] && continue

  a1="${tokens[$((i + 1))]:-}"
  a2="${tokens[$((i + 2))]:-}"
  case "$cmd" in
    gh)
      case "$a1" in
        ""|auth|--version|version|help|--help) : ;;
        *) blocked="gh $a1"; break ;;
      esac ;;
    vercel)
      case "$a1" in
        ""|--version|-v|help|--help) : ;;
        *) blocked="vercel $a1"; break ;;
      esac ;;
    supabase)
      remote=0
      case "$a1" in
        login|link|projects|orgs|secrets|functions|branches|inspect) remote=1 ;;
        db) case "$a2" in push|pull|dump) remote=1 ;; esac ;;
        migration|migrations) case "$a2" in list|repair|fetch) remote=1 ;; esac ;;
      esac
      for t in "${tokens[@]:$i}"; do
        case "$t" in --linked|--project-ref|--project-ref=*) remote=1 ;; esac
      done
      [ "$remote" -eq 1 ] && { blocked="supabase $a1${a2:+ $a2}"; break; } ;;
  esac
done <<EOF
$NORMALIZED
EOF

[ -z "$blocked" ] && exit 0

cat >&2 <<MSG
BLOCKED: 「${blocked}」는 실행기를 앞에 붙여 부르세요 — .claude/scripts/with-owner.sh ${blocked} …

이유: gh·vercel·supabase 로그인은 컴퓨터 전체에 하나라, 실행기 없이 부르면 이
프로젝트 소유의 계정 장부(~/.config/harness/<소유>.env)가 아니라 컴퓨터에 남은
로그인 계정으로 돕니다. 소유가 다른 프로젝트가 한 컴퓨터에 있으면 PR·배포가 다른
계정으로 만들어집니다.

npx·fnm을 쓰는 명령은 실행기가 맨 앞입니다:
  .claude/scripts/with-owner.sh fnm exec --using=.nvmrc -- npx vercel …
지금 어느 소유·계정으로 도는지는 .claude/scripts/with-owner.sh --check 로 봅니다.
MSG
exit 2
