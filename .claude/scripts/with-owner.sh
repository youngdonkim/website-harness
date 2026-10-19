#!/usr/bin/env bash
# with-owner.sh — 이 프로젝트 소유의 계정 장부를 불러 명령을 실행한다.
#
# 쓰는 법 (프로젝트 최상위 폴더에서):
#   .claude/scripts/with-owner.sh <명령...>     장부의 키를 환경변수로 넣고 명령을 실행(exec)
#   .claude/scripts/with-owner.sh --check       키 값 없이 소유·장부 자리·키 이름·gh 계정만 보여 줌
#   .claude/scripts/with-owner.sh --git-credential
#                                               git 자격 증명 도우미 전용 — git에게만 토큰을 건넴
#
# 소유 선언: <프로젝트>/.claude/owner 의 한 줄  owner=personal | company | org-<영문 짧은 이름>
# 장부:      ~/.config/harness/<소유>.env  (폴더 700, 파일 600, git 저장소 밖)
#            한 줄에 이름=값 하나. 쓰는 이름: GH_LOGIN GH_TOKEN GIT_USER_NAME GIT_USER_EMAIL
#            VERCEL_TEAM VERCEL_TOKEN SUPABASE_ORG SUPABASE_ACCESS_TOKEN
# 프로젝트 전용 키: 장부를 읽은 뒤 프로젝트의 .env.cli(git 미추적)에서 장부가 다루지 않는 이름만
#            더 읽는다(SUPABASE_PROJECT_REF·SUPABASE_DB_PASSWORD처럼 프로젝트마다 다른 값).
#            장부가 다루는 이름이 .env.cli에 있으면 읽지 않고 옮기라고 알린다.
# 옛 프로젝트 호환: 소유 파일이나 장부 파일이 없고 프로젝트에 .env.cli가 있으면 그것을 통째로 읽는다.
# 한 번만 다른 소유로: HARNESS_OWNER=<소유> 를 앞에 두면 .claude/owner 대신 그 값을 쓴다
#   (소유 이전 중 새 소유 쪽 키를 확인할 때만 — transfer-ownership).
#
# 지키는 것: 어떤 경우에도 키 값을 화면(stdout·stderr)에 내지 않는다.
#            --git-credential만 값을 내보내는데, 출력이 터미널이면 거절한다(git이 받을 때만).
#            장부는 셸 코드로 실행(source)하지 않고 한 줄씩 읽어 이름=값만 받는다.
# 맥 기본 bash 3.2·리눅스·윈도우 Git Bash에서 돈다(연관 배열·mapfile 등을 쓰지 않는다).

set -euo pipefail

SCRIPT_DIR=$(cd -P "$(dirname "$0")" && pwd)
PROJECT_DIR=$(cd -P "$SCRIPT_DIR/../.." && pwd)
OWNER_FILE="$PROJECT_DIR/.claude/owner"
LEDGER_DIR="$HOME/.config/harness"
OLD_FILE="$PROJECT_DIR/.env.cli"

# 장부가 다룰 수 있는 키 — 부모 셸에서 물려받은 같은 이름 값은 먼저 지운다
# (다른 소유의 토큰이 환경에 남아 있으면 그 계정으로 돌기 때문이다).
CLEAR_NAMES="GH_TOKEN GITHUB_TOKEN GH_LOGIN GIT_USER_NAME GIT_USER_EMAIL VERCEL_TEAM VERCEL_TOKEN SUPABASE_ORG SUPABASE_ACCESS_TOKEN"

say() { printf 'with-owner: %s\n' "$*" >&2; }

usage() {
  cat >&2 <<'MSG'
쓰는 법:
  .claude/scripts/with-owner.sh <명령...>       예) .claude/scripts/with-owner.sh gh pr status
  .claude/scripts/with-owner.sh --check
  .claude/scripts/with-owner.sh --git-credential   (git 자격 증명 도우미 전용)
MSG
}

is_windows() {
  case "$(uname -s 2>/dev/null || echo unknown)" in
    MINGW*|MSYS*|CYGWIN*) return 0 ;;
    *) return 1 ;;
  esac
}

# --- 소유 읽기 -------------------------------------------------------------
OWNER=""
OWNER_PROBLEM=""
OWNER_FROM=".claude/owner"
if [ -n "${HARNESS_OWNER:-}" ] || [ -f "$OWNER_FILE" ]; then
  if [ -n "${HARNESS_OWNER:-}" ]; then
    OWNER=$(printf '%s' "$HARNESS_OWNER" | tr -d '\r[:space:]')
    OWNER_FROM="HARNESS_OWNER — 이번 한 번만"
  else
    OWNER=$(sed -n 's/^owner=//p' "$OWNER_FILE" | head -1 | tr -d '\r[:space:]')
  fi
  case "$OWNER" in
    personal|company) ;;
    org-*)
      if ! printf '%s' "${OWNER#org-}" | grep -Eq '^[a-z0-9][a-z0-9-]*$'; then
        OWNER_PROBLEM="소유 값이 형식과 다릅니다 ($OWNER_FROM: org- 뒤는 영문 소문자·숫자·하이픈)"
        OWNER=""
      fi
      ;;
    "") OWNER_PROBLEM=".claude/owner에 owner= 줄이 없습니다" ;;
    *)
      OWNER_PROBLEM="소유 값이 형식과 다릅니다 ($OWNER_FROM: personal·company·org-<이름> 중 하나)"
      OWNER=""
      ;;
  esac
else
  OWNER_PROBLEM=".claude/owner 파일이 없습니다"
fi

LEDGER_FILE=""
[ -n "$OWNER" ] && LEDGER_FILE="$LEDGER_DIR/$OWNER.env"

# --- 어느 파일을 읽을지 -----------------------------------------------------
SOURCE_FILE=""
SOURCE_KIND=""   # ledger | old
if [ -n "$LEDGER_FILE" ] && [ -f "$LEDGER_FILE" ]; then
  SOURCE_FILE="$LEDGER_FILE"
  SOURCE_KIND="ledger"
elif [ -z "${HARNESS_OWNER:-}" ] && [ -f "$OLD_FILE" ]; then
  SOURCE_FILE="$OLD_FILE"
  SOURCE_KIND="old"
fi

# --- 파일을 한 줄씩 읽어 이름=값을 환경변수로 넣는다 ---------------------------
LOADED_NAMES=""
STALE_NAMES=""
load_file() {
  local f="$1" mode="${2:-all}" line name value
  [ "$mode" = "all" ] && for name in $CLEAR_NAMES; do unset "$name"; done
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}
    case "$line" in ''|'#'*) continue ;; esac
    case "$line" in *=*) ;; *) continue ;; esac
    name=${line%%=*}
    value=${line#*=}
    name=$(printf '%s' "$name" | sed -E 's/^[[:space:]]*(export[[:space:]]+)?//; s/[[:space:]]+$//')
    printf '%s' "$name" | grep -Eq '^[A-Z_][A-Z0-9_]*$' || continue
    if [ "$mode" = "project" ]; then
      case " $CLEAR_NAMES " in *" $name "*)
        case " $STALE_NAMES " in *" $name "*) ;; *) STALE_NAMES="${STALE_NAMES:+$STALE_NAMES }$name" ;; esac
        continue ;;
      esac
    fi
    # 앞뒤를 감싼 따옴표 한 쌍은 벗긴다
    case "$value" in
      \"*\") value=${value#\"}; value=${value%\"} ;;
      \'*\') value=${value#\'}; value=${value%\'} ;;
    esac
    [ -z "$value" ] && continue
    export "$name=$value"
    case " $LOADED_NAMES " in *" $name "*) ;; *) LOADED_NAMES="${LOADED_NAMES:+$LOADED_NAMES }$name" ;; esac
  done < "$f"
}

load_all() {
  load_file "$SOURCE_FILE"
  if [ "$SOURCE_KIND" = "ledger" ] && [ -f "$OLD_FILE" ]; then
    load_file "$OLD_FILE" project
  fi
}

perm_warning() {
  local f="$1"
  is_windows && return 0
  if [ -n "$(find "$f" \( -perm -040 -o -perm -004 \) -print 2>/dev/null)" ]; then
    say "장부 파일을 다른 사용자도 읽을 수 있습니다 — chmod 600 \"$f\" 로 막으세요"
  fi
}

# --- --git-credential ------------------------------------------------------
if [ "${1:-}" = "--git-credential" ]; then
  # git이 보내는 질문(host=… 등)을 끝까지 받아 둔다. 터미널에서 직접 부르면 값을 내지 않는다.
  if [ -t 0 ] || [ -t 1 ]; then
    say "--git-credential은 git 자격 증명 도우미 전용입니다 — 화면에는 값을 내지 않습니다"
    exit 64
  fi
  host=""
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}
    [ -z "$line" ] && break
    case "$line" in host=*) host=${line#host=} ;; esac
  done
  case "$host" in ""|github.com) ;; *) exit 0 ;; esac
  [ -n "$SOURCE_FILE" ] || exit 0
  load_file "$SOURCE_FILE"
  [ -n "${GH_TOKEN:-}" ] || exit 0
  printf 'username=x-access-token\npassword=%s\n' "$GH_TOKEN"
  exit 0
fi

# --- --check ---------------------------------------------------------------
if [ "${1:-}" = "--check" ]; then
  problems=0
  echo "프로젝트: $PROJECT_DIR"
  if [ -n "$OWNER" ]; then
    echo "소유: $OWNER ($OWNER_FROM)"
  else
    echo "소유: 없음 — $OWNER_PROBLEM"
    problems=1
  fi
  if [ -n "$LEDGER_FILE" ]; then
    if [ -f "$LEDGER_FILE" ]; then
      echo "장부 파일: $LEDGER_FILE (있음)"
    else
      echo "장부 파일: $LEDGER_FILE (없음)"
      problems=1
    fi
  fi
  case "$SOURCE_KIND" in
    ledger)
      perm_warning "$SOURCE_FILE"
      ;;
    old)
      echo "읽은 파일: $OLD_FILE (옛 방식) — 장부로 옮기세요(project-init 동기화)"
      problems=1
      ;;
    *)
      echo "읽은 파일: 없음 — 장부 파일도 옛 .env.cli도 없습니다"
      exit 1
      ;;
  esac
  load_all
  [ "$SOURCE_KIND" = "ledger" ] && [ -f "$OLD_FILE" ] && echo "프로젝트 전용 키 파일: $OLD_FILE (있음)"
  if [ -n "$STALE_NAMES" ]; then
    echo "주의: .env.cli에 장부가 다루는 키가 남아 있어 읽지 않았습니다($STALE_NAMES) — project-init 동기화로 장부로 옮기세요"
    problems=1
  fi
  echo "있는 키: ${LOADED_NAMES:-(없음)}"
  if [ -n "${GH_TOKEN:-}" ]; then
    if ! command -v gh >/dev/null 2>&1; then
      echo "gh 계정: 확인 못 함 — gh가 설치돼 있지 않습니다"
      problems=1
    elif login=$(gh api user --jq .login 2>/dev/null); then
      if [ -n "${GH_LOGIN:-}" ] && [ "$login" != "$GH_LOGIN" ]; then
        echo "gh 계정: $login — 장부의 GH_LOGIN($GH_LOGIN)과 다릅니다"
        problems=1
      else
        echo "gh 계정: $login"
      fi
    else
      echo "gh 계정: 확인 실패 — 토큰이 만료·폐기됐거나 네트워크 문제입니다"
      problems=1
    fi
  else
    echo "gh 계정: GH_TOKEN이 없어 확인하지 않았습니다"
  fi
  exit "$problems"
fi

# --- 명령 실행 --------------------------------------------------------------
if [ "$#" -eq 0 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 64
fi

case "$SOURCE_KIND" in
  ledger)
    perm_warning "$SOURCE_FILE"
    ;;
  old)
    say "옛 .env.cli를 읽었습니다 — 장부로 옮기세요(project-init 동기화)"
    ;;
  *)
    if [ -n "$LEDGER_FILE" ]; then
      say "장부 파일이 없습니다: $LEDGER_FILE — github-connect(GitHub)나 4단계 준비가 키를 채웁니다"
    else
      say "$OWNER_PROBLEM — project-init이 소유를 정해 이 파일을 씁니다"
    fi
    exit 66
    ;;
esac

load_all
[ -n "$STALE_NAMES" ] && say ".env.cli의 $STALE_NAMES 는 장부가 다루는 키라 읽지 않았습니다 — project-init 동기화로 옮기세요"
exec "$@"
