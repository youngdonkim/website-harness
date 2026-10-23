#!/usr/bin/env bash
# design-check.sh — 3단계 배포 전 「검사 ① 디자인 규칙 검사」의 grep 17개를 한 번에 돌린다.
#
# 판정 기준의 정본: .claude/skills/idea-to-mvp/references/3-frontend-build.md §2.5 「검사 ①」
#   (통과 조건·잡는 예·못 잡는 예·예외 처리는 그 문서를 본다. 이 스크립트는 명령만 실행하고 판정은 하지 않는다.)
#
# 쓰는 법 (프로젝트 최상위 폴더에서):
#   bash .claude/scripts/design-check.sh                      # 17개 전부 (13번은 --allowed 없으면 건너뜀)
#   bash .claude/scripts/design-check.sh --only 1,2,7,12      # 골라서
#   bash .claude/scripts/design-check.sh --allowed "0 1 2 3 4 6 8 12 16"   # 13번 허용 간격 단계(Tailwind 숫자)
#
# 경로·이름은 기본값을 쓰고 환경변수로 덮는다 (여러 경로는 공백으로 구분):
#   PRODUCT_DIRS="src/app src/components"  제품 코드 (ui 폴더는 뺀다)
#   CSS3=src/styles/3-components.css       FOUNDATION_DIR=src/styles/1-foundation
#   SEMANTIC_CSS=src/styles/2-semantic.css ENTRY_CSS=src/app/globals.css
#   STYLES_DIR=src/styles                  PARTS_DIR=src/components
#   INVENTORY=docs/components.md           FEATURE_LIST=mvp/feature-list.md
#   APP_DIR=src/app                        (6번 앱 설정 경로, 12·14번 화면 폴더 찾는 곳)
#   BTN=Button BTN_FN=buttonVariants PRIMARY=default   (12번: 버튼 부품·클래스 함수·주 버튼 variant)
#   AGENTS_MD=AGENTS.md                    (15번: 연결 정보의 `BRAND_PARTS:` 줄을 읽는 곳)
#   BRAND_PARTS="src/components/hero-band.tsx …"   (15번: 주면 AGENTS_MD 대신 이 목록을 쓴다)
#   HEAVY_LIBS="이름 …" HEAVY_PARTS="파일 …"       (16번: 연결 정보의 `HEAVY_LIBS:`·`HEAVY_PARTS:` 줄 대신 주는 목록. 라이브러리 이름은 스크립트에 없다)
#   STAY_PALETTE="src/lib/scene-palette.ts" STAY_PARTS="파일 …"  (17번: 연결 정보의 `STAY_PALETTE:`·`STAY_PARTS:` 줄 대신 주는 목록)
#   LIB_DIR=src/lib                        (17번: 공간 팔레트 파일(`*-palette.ts`)을 찾는 곳)
#
# 1·11번은 주석 속 숫자를 세지 않는다(scan — 2026-10-21 시험에서 「44px」 설명 주석이 하드코딩으로 잡혔다). 15·16·17번은 대상이 아직 없으면 「해당 없음」으로 따로 적는다 — 통과와 다르다.
# 늘 exit 0 이다. 걸린 줄을 어떻게 볼지는 문서 기준으로 사람·메인이 판정한다.
# bash 3.2(macOS 기본)에서 돌고, zsh에서 `bash …`로 불러도 낱말이 바르게 쪼개진다.

ONLY=""
ALLOWED=""
while [ $# -gt 0 ]; do
  case "$1" in
    --only) ONLY="$2"; shift 2 ;;
    --allowed) ALLOWED="$2"; shift 2 ;;
    *) echo "알 수 없는 인자: $1 (쓰는 법은 이 파일 맨 위 주석)"; exit 0 ;;
  esac
done

PRODUCT_DIRS="${PRODUCT_DIRS:-src/app src/components}"
CSS3="${CSS3:-src/styles/3-components.css}"
FOUNDATION_DIR="${FOUNDATION_DIR:-src/styles/1-foundation}"
SEMANTIC_CSS="${SEMANTIC_CSS:-src/styles/2-semantic.css}"
ENTRY_CSS="${ENTRY_CSS:-src/app/globals.css}"
STYLES_DIR="${STYLES_DIR:-src/styles}"
PARTS_DIR="${PARTS_DIR:-src/components}"
INVENTORY="${INVENTORY:-docs/components.md}"
FEATURE_LIST="${FEATURE_LIST:-mvp/feature-list.md}"
APP_DIR="${APP_DIR:-src/app}"
BTN="${BTN:-Button}"
BTN_FN="${BTN_FN:-buttonVariants}"
PRIMARY="${PRIMARY:-default}"
AGENTS_MD="${AGENTS_MD:-AGENTS.md}"
LIB_DIR="${LIB_DIR:-src/lib}"

g() { command grep "$@"; }

# scan line|only 정규식 경로... : grep -rnE 결과에서 주석을 걷어 낸 뒤에도 정규식이 맞는 줄만 남긴다.
#   걷어 내는 것 — `/* … */`·`{/* … */}`, 공백 뒤 `//`부터 줄 끝(주소의 `https://`는 남는다),
#   ` * `로 시작하는 여러 줄 주석의 가운데 줄, 닫히지 않은 `/*`부터 줄 끝.
#   못 걷는 것 — ` * ` 없이 쓴 여러 줄 주석의 가운데 줄(그 줄은 그대로 나온다).
#   line: 걸린 줄을 그대로 / only: 주석 밖에서 맞은 조각만 「파일:줄:조각」으로 (grep -o와 같은 모양)
scan() {
  local mode="$1" re="$2"; shift 2
  g -rnHE --exclude-dir=ui -- "$re" "$@" | MODE="$mode" RE="$re" perl -ne '
    chomp; my ($h, $c) = /^(.*?:[0-9]+:)(.*)$/ or next;
    my $s = $c;
    $s =~ s{\{?/\*.*?\*/\}?}{}g;
    $s =~ s{(^|\s)//.*$}{$1};
    $s =~ s{^\s*\*(\s+[^\s\{]|/|$).*$}{};
    $s =~ s{/\*.*$}{};
    my $re = $ENV{RE};
    if ($ENV{MODE} eq "only") { while ($s =~ /($re)/g) { print "$h$1\n" } }
    elsif ($s =~ /$re/) { print "$h$c\n" }'
}

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT

# 낱말 쪼개기는 여기 한 곳에서만 한다 (zsh/bash 공통으로 안전하게 read -a)
read -r -a PRODUCT <<< "$PRODUCT_DIRS"

# ex 이름... : 주어진 경로 중 있는 것만 EX 배열에 담고, 없는 건 「경로 없음」으로 찍는다
EX=()
ex() {
  EX=()
  local p
  for p in "$@"; do
    if [ -e "$p" ]; then EX+=("$p"); else echo "경로 없음: $p"; fi
  done
}

want() {
  [ -z "$ONLY" ] && return 0
  case ",$ONLY," in *",$1,"*) return 0 ;; esac
  return 1
}

# ---------- 검사 함수 ----------
c1() {
  ex "$CSS3" "${PRODUCT[@]}"; [ ${#EX[@]} -eq 0 ] && return
  # 주석 속 숫자(예: 「누르는 영역 44px」 설명)는 세지 않는다 — scan이 주석을 걷고 본다
  # 2-3 비교안 판 폴더(`(dev)/…/_bold|_innov|_leap/`)와 2-4 공간 비교안 폴더(`_stay/`) 안 .ts 값 파일({수단}.ts·motion.ts·{수단}-palette.ts)은 보지 않는다 —
  #   고르면 제품 코드 밖 lib/로 옮겨질 값 파일이라, 그 안의 색 변환 도우미(`rgb(`)·공간 팔레트의 색 값이 오탐이 된다(2026-10-22 시험). .tsx는 그대로 본다.
  { scan line '#([0-9a-fA-F]{3}|[0-9a-fA-F]{4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})|rgba?\(|hsla?\(|oklch\(|oklab\(' "${EX[@]}"
    scan line '[0-9]+px' "${EX[@]}"; } | g -vE '\(dev\)/([^:]*/)?_(bold|innov|leap|stay)/[^/:]+\.ts:[0-9]+:'
}

c2() {
  ex "$FOUNDATION_DIR" "$CSS3" "${PRODUCT[@]}"
  [ -e "$FOUNDATION_DIR" ] || return
  g -rhoE '^[[:space:]]*--[A-Za-z0-9-]+' "$FOUNDATION_DIR" \
    | sed -E 's/^[[:space:]]*//' | sort -u > "$T/foundation-vars.txt"
  [ -s "$T/foundation-vars.txt" ] || { echo "  (참고) 1층에서 변수를 하나도 못 찾음"; return; }
  local t=(); local p
  for p in "$CSS3" "${PRODUCT[@]}"; do [ -e "$p" ] && t+=("$p"); done
  [ ${#t[@]} -eq 0 ] && return
  # 주석 줄(`//`·`/*`·`*`로 시작)은 세지 않는다 — 「1층 --curve-out과 같은 곡선」 같은 설명 주석이 걸렸다(2026-10-22 시험)
  g -rnwF --exclude-dir=ui -f "$T/foundation-vars.txt" "${t[@]}" | g -vE '^[^:]+:[0-9]+:[[:space:]]*(//|/\*|\*)'
}

c3() {
  ex "$CSS3" "${PRODUCT[@]}"; [ ${#EX[@]} -eq 0 ] && return
  g -rnE --exclude-dir=ui '@media[^{]*(width|height|orientation|aspect-ratio)' "${EX[@]}"
  local q=(); local p
  for p in "${PRODUCT[@]}"; do [ -e "$p" ] && q+=("$p"); done
  [ ${#q[@]} -eq 0 ] && return
  g -rnoE --exclude-dir=ui '(^|[^a-z0-9@-])(max-)?(sm|md|lg|xl|2xl):[a-z[!-]' "${q[@]}"
}

c4() {
  ex "$INVENTORY" "$PARTS_DIR" "$CSS3"
  [ -e "$INVENTORY" ] && [ -e "$PARTS_DIR" ] || return
  sed -n '/^## 전체 부품 색인/,$p' "$INVENTORY" > "$T/inventory-index.txt"
  [ -s "$T/inventory-index.txt" ] || echo "미등록 확인 불가: $INVENTORY 에 「## 전체 부품 색인」 구간이 없음"
  find "$PARTS_DIR" -name '*.tsx' | sort > "$T/parts.txt"
  local f c
  while read -r f; do g -qxF -- "$f" "$T/inventory-index.txt" || echo "미등록 부품: $f"; done < "$T/parts.txt"
  [ -e "$CSS3" ] || return
  g -rhoE '^\.[A-Za-z][A-Za-z0-9_-]*' "$CSS3" | sed 's/^\.//' | sort -u > "$T/classes.txt"
  while read -r c; do g -qxF -- "$c" "$T/inventory-index.txt" || echo "미등록 클래스: $c"; done < "$T/classes.txt"
}

c5() {
  ex "${PRODUCT[@]}"; [ ${#EX[@]} -eq 0 ] && return
  # 같은 줄에 isComposing 확인(e.isComposing · e.nativeEvent.isComposing 꼴)이 있으면 가드로 보고 뺀다
  g -rn --exclude-dir=ui 'key === "Enter"' "${EX[@]}" | g -v 'isComposing'
}

c6() {
  ex "$APP_DIR" "$SEMANTIC_CSS"
  local a=0 b=0
  if [ -e "$APP_DIR" ]; then
    g -rn "viewportFit\|viewport-fit" "$APP_DIR" | sed 's/^/  (참고) /'
    a=$(g -rn "viewportFit\|viewport-fit" "$APP_DIR" | wc -l | tr -d ' ')
  fi
  if [ -e "$SEMANTIC_CSS" ]; then
    g -rn "safe-area-inset" "$SEMANTIC_CSS" | sed 's/^/  (참고) /'
    b=$(g -rn "safe-area-inset" "$SEMANTIC_CSS" | wc -l | tr -d ' ')
  fi
  [ "$a" -gt 0 ] && [ "$b" -eq 0 ] && echo "하단 안전 영역 변수 없음: viewport-fit 설정은 ${a}줄인데 safe-area-inset 은 0건 (하단이 홈 막대에 깔림)"
}

c7() {
  ex "${PRODUCT[@]}"; [ ${#EX[@]} -eq 0 ] && return
  g -rnoE --exclude-dir=ui '[a-z0-9]-\[[^]" ]+\]:?' "${EX[@]}" | g -vE '\]:$'
}

c8() {
  ex "$SEMANTIC_CSS"
  [ -e "$SEMANTIC_CSS" ] || return
  echo "결과: $(g -cE -- '--color-\*:[[:space:]]*initial' "$SEMANTIC_CSS")"
}

c9() {
  ex "${PRODUCT[@]}"; [ ${#EX[@]} -eq 0 ] && return
  g -rnoE --exclude-dir=ui '[a-z]-\((--|[a-z-]+:--)[A-Za-z0-9-]*\)' "${EX[@]}"
}

c10() {
  ex "$ENTRY_CSS" "$STYLES_DIR"; [ ${#EX[@]} -eq 0 ] && return
  local r; r=$(g -rln 'prefers-reduced-motion' "${EX[@]}")
  [ -n "$r" ] && echo "$r" | sed 's/^/  (참고) /'
  if [ -n "$r" ]; then echo "결과: $(echo "$r" | wc -l | tr -d ' ')"; else echo "결과: 0"; fi
}

c11() {
  ex "$CSS3" "${PRODUCT[@]}"; [ ${#EX[@]} -eq 0 ] && return
  scan only '(duration|delay|ease)-\[[^]]+\]|(duration|delay)-[0-9]+|[0-9]+ms|cubic-bezier\(|(^|[^a-z-])ease-(linear|in-out|in|out)\b' "${EX[@]}"
}

# 12번 못 세는 모양: 조건식 variant(`variant={started ? "secondary" : "default"}`)는 주 버튼으로 세지 않는다 — 0개로 나오면 눈으로 본다.
# 위에 뜨는 창(확인 창 등)이 여는 화면과 같은 폴더에 있으면 그 창의 주 버튼까지 더해 2개로 나온다 — 문서 통과 조건으로 설명한다.
c12() {
  ex "$FEATURE_LIST" "$APP_DIR"
  echo "  (참고) 12-가. 화면 목록의 주 행동 칸 (MVP 포함 = O)"
  if [ -e "$FEATURE_LIST" ]; then
    awk -F'|' '/^## 6\./{f=1;next} /^## /{f=0} f && $2 ~ /S-[0-9]/ && $9 ~ /^ *O *$/ {gsub(/^ +| +$/,"",$8); gsub(/^ +| +$/,"",$11); gsub(/ /,"",$2); print "  (참고) " $2 " · 주 행동: " $8 " · 주소: " $11}' "$FEATURE_LIST"
  fi
  [ -e "$APP_DIR" ] || return
  echo "  (참고) 12-나. 화면 폴더마다 주 버튼 수 — 1개가 아닌 폴더만 나온다"
  find "$APP_DIR" \( -name page.tsx -o -name not-found.tsx -o -name error.tsx \) -not -path '*/(dev)/*' \
    | while read -r f; do dirname "$f"; done | sort -u > "$T/screens.txt"
  local d n
  while read -r d; do
    n=$(find "$d" -maxdepth 1 -name '*.tsx' -exec cat {} + | BTN="$BTN" BTN_FN="$BTN_FN" PRIMARY="$PRIMARY" perl -0777 -ne '
      my $b = qr/(\{(?:[^{}]++|(?-1))*\})/;
      my $v = qr/\bvariant\s*[=:]\s*\{?\s*["\x27]\Q$ENV{PRIMARY}\E["\x27]/;
      my $c = 0;
      while (/<\Q$ENV{BTN}\E\b((?:[^>{}]|$b)*)>/g) { my $a = $1; $c++ if $a !~ /\bvariant\s*=/ || $a =~ $v }
      while (/\b\Q$ENV{BTN_FN}\E\(((?:[^()]|\([^()]*\))*)\)/g) { my $a = $1; $c++ if $a !~ /\bvariant\s*:/ || $a =~ $v }
      print $c')
    [ "$n" = 1 ] || echo "주 버튼 ${n}개: $d"
  done < "$T/screens.txt"
}

c13() {
  if [ -z "$ALLOWED" ]; then echo "  (참고) 허용 단계를 모름 — --allowed를 주세요"; return; fi
  ex "${PRODUCT[@]}"; [ ${#EX[@]} -eq 0 ] && return
  g -rnoE --exclude-dir=ui '(^|[^a-z0-9-])-?([pm][xytrblse]?|gap(-[xy])?|space-[xy])-[0-9]+(\.[0-9]+)?' "${EX[@]}" \
    | awk -v ok="0 $ALLOWED" 'BEGIN{n=split(ok,a," "); for(i=1;i<=n;i++) s[a[i]]=1} {m=$0; sub(/^[^:]*:[0-9]+:/,"",m); if (match(m,/-[0-9]+(\.[0-9]+)?$/)) {v=substr(m,RSTART+1,RLENGTH-1); if(!(v in s)) print}}'
}

# 14번: 화면 폴더에서 <h1 직접 사용 — 화면 제목 부품(PageHeader·TabHeading)이 h1을 맡는다. (dev) 묶음은 뺀다(부품 폴더는 APP_DIR 밖이라 안 본다)
c14() {
  ex "$APP_DIR"; [ ${#EX[@]} -eq 0 ] && return
  g -rn --exclude-dir='(dev)' '<h1' "$APP_DIR"
}

# 15번: brand-surface(브랜드 색 면)를 쓴 파일이 연결 정보의 자리 부품 목록(BRAND_PARTS) 밖에 있으면 찍는다.
# 개발용 묶음 (dev)은 뺀다 — 디자인 시스템 페이지 견본과 2-3 비교안이 쓴다.
# 세 갈래를 가른다:
#   ① 브랜드 색을 아직 안 들임(2층 :root에 --brand-surface 값 없음 · 제품 코드에 쓴 곳 없음 · 목록 줄 없음) → 「해당 없음」 (걸린 줄로 세지 않는다)
#   ② 들였는데 목록 줄이 없음(:root 값이나 쓴 파일은 있는데 BRAND_PARTS 줄 없음) → 「목록 줄 없음」 (걸린 줄)
#   ③ 목록이 있음 → 목록 밖 파일만 찍는다. 목록에 있는데 파일이 없으면 (참고)로 알린다
NA_LIST=""
c15() {
  ex "${PRODUCT[@]}"; [ ${#EX[@]} -eq 0 ] && return
  local list="${BRAND_PARTS:-}"
  if [ -z "$list" ] && [ -e "$AGENTS_MD" ]; then
    list=$(g -m1 'BRAND_PARTS:' "$AGENTS_MD" | sed -E 's/.*BRAND_PARTS:[[:space:]]*//' | tr -d '`')
  fi
  g -rlE --exclude-dir=ui --exclude-dir='(dev)' 'brand-surface' "${EX[@]}" | sort -u > "$T/brand-files.txt"
  local rootval=0
  if [ -e "$SEMANTIC_CSS" ]; then
    # 2층에서 선택자가 :root인 블록 안의 --brand-surface 값만 센다(비교안 범위 블록 .draft-… 안의 값은 빼고)
    rootval=$(awk '
      { line=$0; sub(/\/\*.*\*\//, "", line) }
      depth==0 && line ~ /\{/ { sel=line; sub(/\{.*/, "", sel); gsub(/^[ \t]+|[ \t]+$/, "", sel) }
      { o=gsub(/\{/, "{", line); c=gsub(/\}/, "}", line) }
      depth+o>0 && sel ~ /^:root/ && line ~ /--brand-surface[[:space:]]*:/ { n++ }
      { depth+=o-c; if (depth<=0) { depth=0 } }
      END { print n+0 }' "$SEMANTIC_CSS")
  fi
  if [ -z "$list" ]; then
    if [ ! -s "$T/brand-files.txt" ] && [ "$rootval" = 0 ]; then
      echo "  (참고) 해당 없음 — 브랜드 색 면을 아직 들이지 않았다(2층 :root에 --brand-surface 값 없음, 제품 코드에 쓴 곳 없음, 연결 정보에 BRAND_PARTS 줄 없음)"
      NA_LIST="$NA_LIST 15"
      return
    fi
    echo "목록 줄 없음: 브랜드 색 면을 들였는데($([ "$rootval" != 0 ] && echo '2층 :root에 값 있음')$([ -s "$T/brand-files.txt" ] && echo ' 제품 코드에 쓴 파일 있음')) $AGENTS_MD 연결 정보에 BRAND_PARTS: 줄이 없다 — 줄을 빠뜨린 것"
  fi
  local parts=() p f ok
  [ -n "$list" ] && read -r -a parts <<< "$list"
  if [ ${#parts[@]} -gt 0 ]; then
    for p in "${parts[@]}"; do [ -e "$p" ] || echo "  (참고) 목록에 있는데 파일이 없음: $p"; done
  fi
  [ -s "$T/brand-files.txt" ] || return
  while read -r f; do
    ok=0
    if [ ${#parts[@]} -gt 0 ]; then
      for p in "${parts[@]}"; do [ "$f" = "$p" ] && ok=1; done
    fi
    [ "$ok" = 1 ] || echo "자리 부품 목록 밖: $f"
  done < "$T/brand-files.txt"
}

# 16번: 무거운 라이브러리(3D·지도 등)를 연결 정보의 부품 목록(HEAVY_PARTS) 밖 파일에서 불러오면 찍는다.
# 라이브러리 이름은 스크립트에 없다 — 연결 정보의 `HEAVY_LIBS:`(이름 목록)와 `HEAVY_PARTS:`(불러도 되는 파일 목록) 두 줄을 읽는다.
# 개발용 묶음 (dev)은 뺀다 — 비교안 폴더는 무거운 라이브러리를 부르는 자리다. import·동적 import(import("…"))·require 모두 본다.
# 세 갈래를 가른다:
#   ① 안 들임(HEAVY_LIBS 줄 없음 · 제품 코드에 패키지를 동적 import한 곳도 없음) → 「해당 없음」 (걸린 줄로 세지 않는다)
#   ② 들였는데 목록 줄이 없음(HEAVY_LIBS 줄 없는데 패키지를 동적 import한 파일이 있음 / HEAVY_LIBS는 있는데 HEAVY_PARTS 줄 없음) → 「목록 줄 없음」 (걸린 줄)
#      비교안 폴더에서만 쓰고 본 부품이 아직 없으면 `HEAVY_PARTS: (없음)`으로 적는다 — 빈 목록으로 읽고 걸지 않는다
#   ③ 두 목록이 다 있음 → 목록 밖 파일만 찍는다. 목록에 있는데 파일이 없으면 (참고)로 알린다
c16() {
  ex "${PRODUCT[@]}"; [ ${#EX[@]} -eq 0 ] && return
  local libs="${HEAVY_LIBS:-}" list="${HEAVY_PARTS:-}"
  if [ -e "$AGENTS_MD" ]; then
    [ -z "$libs" ] && libs=$(g -m1 'HEAVY_LIBS:' "$AGENTS_MD" | sed -E 's/.*HEAVY_LIBS:[[:space:]]*//' | tr -d '`')
    [ -z "$list" ] && list=$(g -m1 'HEAVY_PARTS:' "$AGENTS_MD" | sed -E 's/.*HEAVY_PARTS:[[:space:]]*//' | tr -d '`')
  fi
  if [ -z "$libs" ]; then
    # 이름을 모르니, 패키지(상대 경로·@/ 별칭이 아닌 이름)를 동적 import한 파일이 있는지로 「들였나」를 짐작한다 — 무거운 라이브러리는 동적으로 부르는 게 원칙이다
    g -rlE --exclude-dir=ui "import\([[:space:]]*[\"'][^./@][^\"']*[\"']|import\([[:space:]]*[\"']@[a-z0-9-]+/" "${EX[@]}" | sort -u > "$T/heavy-dyn.txt"
    if [ ! -s "$T/heavy-dyn.txt" ]; then
      echo "  (참고) 해당 없음 — 무거운 라이브러리를 아직 들이지 않았다(연결 정보에 HEAVY_LIBS 줄 없음, 패키지를 동적 import한 곳 없음)"
      NA_LIST="$NA_LIST 16"
      return
    fi
    # 동적 import는 무거운 라이브러리가 아니어도 쓰일 수 있어 위반으로 세지 않고 참고로만 알린다 — 사람이 보고 HEAVY 줄을 더할지 정한다
    echo "  (참고) 확인 필요 — 패키지를 동적 import한 파일이 있는데($(wc -l < "$T/heavy-dyn.txt" | tr -d ' ')개) $AGENTS_MD 연결 정보에 HEAVY_LIBS:·HEAVY_PARTS: 줄이 없다. 무거운 라이브러리(3D·지도 등)면 두 줄을 더한다"
    sed 's/^/  (참고) 동적 import 파일: /' "$T/heavy-dyn.txt"
    NA_LIST="$NA_LIST 16"
    return
  fi
  # `HEAVY_PARTS: (없음)` — 비교안 폴더에서만 쓰고 본 부품이 아직 없을 때 적는 값. 줄은 있는 것으로 보고 빈 목록으로 읽는다
  local none=0
  case "$list" in "(없음)"|"없음"|"-") none=1; list="" ;; esac
  [ -z "$list" ] && [ $none -eq 0 ] && echo "목록 줄 없음: HEAVY_LIBS는 있는데 $AGENTS_MD 연결 정보에 HEAVY_PARTS: 줄이 없다 — 줄을 빠뜨린 것"
  local alt re
  alt=$(printf '%s\n' $libs | sed -E 's/[][\\.*^$+?(){}|]/\\&/g' | paste -sd'|' -)
  re="(from|import|require)[[:space:]]*\\(?[[:space:]]*[\"'](${alt})(/[^\"']*)?[\"']"
  g -rlE --exclude-dir=ui --exclude-dir='(dev)' "$re" "${EX[@]}" | sort -u > "$T/heavy-files.txt"
  local parts=() p f ok
  [ -n "$list" ] && read -r -a parts <<< "$list"
  if [ ${#parts[@]} -gt 0 ]; then
    for p in "${parts[@]}"; do [ -e "$p" ] || echo "  (참고) 목록에 있는데 파일이 없음: $p"; done
  fi
  [ -s "$T/heavy-files.txt" ] || return
  while read -r f; do
    ok=0
    if [ ${#parts[@]} -gt 0 ]; then
      for p in "${parts[@]}"; do [ "$f" = "$p" ] && ok=1; done
    fi
    [ "$ok" = 1 ] || echo "무거운 라이브러리 자리 밖: $f"
  done < "$T/heavy-files.txt"
}

# 17번: 공간 팔레트(2-4 머무는 공간의 물건 제 색 — 연결 정보의 STAY_PALETTE 파일)를 공간 부품 목록(STAY_PARTS) 밖 파일에서 불러오면 찍는다.
# 물건 제 색이 공간 밖 화면으로 번지는 것을 막는다. 개발용 묶음 (dev)은 뺀다 — 디자인 시스템 페이지 견본과 2-4 비교안이 쓴다.
# 불러오기는 팔레트 파일 이름(확장자 뺀 것)으로 끝나는 import·require 경로로 찾는다(예: `@/lib/scene-palette`).
# 세 갈래를 가른다:
#   ① 안 들임(STAY_PALETTE 줄 없음 · LIB_DIR에 *-palette.ts 파일 없음) → 「해당 없음」 (걸린 줄로 세지 않는다)
#   ② 들였는데 목록 줄이 없음(STAY_PALETTE 줄 없는데 *-palette.ts가 있음 / STAY_PALETTE는 있는데 STAY_PARTS 줄 없음) → 「목록 줄 없음」 (걸린 줄)
#   ③ 두 목록이 다 있음 → 목록 밖 파일만 찍는다. 목록에 있는데 파일이 없으면 (참고)로 알린다
c17() {
  ex "${PRODUCT[@]}"; [ ${#EX[@]} -eq 0 ] && return
  local pal="${STAY_PALETTE:-}" list="${STAY_PARTS:-}"
  if [ -e "$AGENTS_MD" ]; then
    [ -z "$pal" ] && pal=$(g -m1 'STAY_PALETTE:' "$AGENTS_MD" | sed -E 's/.*STAY_PALETTE:[[:space:]]*//' | tr -d '`')
    [ -z "$list" ] && list=$(g -m1 'STAY_PARTS:' "$AGENTS_MD" | sed -E 's/.*STAY_PARTS:[[:space:]]*//' | tr -d '`')
  fi
  if [ -z "$pal" ]; then
    local found=""
    [ -e "$LIB_DIR" ] && found=$(find "$LIB_DIR" -name '*-palette.ts' | sort)
    if [ -z "$found" ]; then
      echo "  (참고) 해당 없음 — 공간 팔레트를 아직 들이지 않았다(연결 정보에 STAY_PALETTE 줄 없음, $LIB_DIR 에 *-palette.ts 없음)"
      NA_LIST="$NA_LIST 17"
      return
    fi
    echo "목록 줄 없음: 공간 팔레트 파일이 있는데($(echo "$found" | paste -sd' ' -)) $AGENTS_MD 연결 정보에 STAY_PALETTE: 줄이 없다 — 줄을 빠뜨린 것"
    return
  fi
  local none=0
  case "$list" in "(없음)"|"없음"|"-") none=1; list="" ;; esac
  [ -z "$list" ] && [ $none -eq 0 ] && echo "목록 줄 없음: STAY_PALETTE는 있는데 $AGENTS_MD 연결 정보에 STAY_PARTS: 줄이 없다 — 줄을 빠뜨린 것"
  local p alt="" re
  for p in $pal; do
    [ -e "$p" ] || echo "  (참고) 팔레트 목록에 있는데 파일이 없음: $p"
    p=$(basename "$p"); p="${p%.*}"
    alt="${alt:+$alt|}$(printf '%s' "$p" | sed -E 's/[][\\.*^$+?(){}|]/\\&/g')"
  done
  [ -z "$alt" ] && return
  re="(from|import|require)[[:space:]]*\\(?[[:space:]]*[\"']([^\"']*/)?(${alt})(\\.ts)?[\"']"
  g -rlE --exclude-dir=ui --exclude-dir='(dev)' "$re" "${EX[@]}" | sort -u > "$T/stay-files.txt"
  local parts=() f ok
  [ -n "$list" ] && read -r -a parts <<< "$list"
  if [ ${#parts[@]} -gt 0 ]; then
    for p in "${parts[@]}"; do [ -e "$p" ] || echo "  (참고) 목록에 있는데 파일이 없음: $p"; done
  fi
  [ -s "$T/stay-files.txt" ] || return
  while read -r f; do
    ok=0
    if [ ${#parts[@]} -gt 0 ]; then
      for p in "${parts[@]}"; do [ "$f" = "$p" ] && ok=1; done
    fi
    [ "$ok" = 1 ] || echo "공간 부품 목록 밖: $f"
  done < "$T/stay-files.txt"
}

# ---------- 실행 ----------
HIT_LIST=""
VAL_LIST=""

run() { # 번호 이름 함수 종류(h=걸린 줄 수, v=값)
  want "$1" || return
  echo "== $1 $2"
  "$3" > "$T/out" 2>&1
  cat "$T/out"
  local n
  if [ "$4" = v ]; then
    n=$(sed -n 's/^결과: //p' "$T/out" | head -1)
    [ -z "$n" ] && n="확인불가"
    VAL_LIST="$VAL_LIST $1=$n"
  else
    n=$(g -cvE '^(경로 없음|  \(참고\))' "$T/out")
    if [ "$4" = c12 ]; then
      n=$(g -c '^주 버튼 ' "$T/out")
      VAL_LIST="$VAL_LIST 12=${n}개화면"
    elif [ "$n" -gt 0 ]; then
      HIT_LIST="$HIT_LIST $1(${n}줄)"
    fi
  fi
}

run 1  "3층·제품 코드 색·px 하드코딩" c1 h
run 2  "3층의 1층 변수 직접 참조" c2 h
run 3  "뷰포트 분기" c3 h
run 4  "부품·클래스 인벤토리 등록" c4 h
run 5  "엔터 확정 입력란 한글 조합 가드" c5 h
run 6  "하단 안전 영역" c6 h
run 7  "대괄호 임의 값" c7 h
run 8  "Tailwind 기본 팔레트 꺼짐" c8 v
run 9  "괄호 변수 직접 사용" c9 h
run 10 "동작 줄이기 전역 규칙" c10 v
run 11 "모션 값 하드코딩" c11 h
run 12 "화면마다 주 버튼 수" c12 c12
run 13 "간격 허용 단계 밖" c13 h
run 14 "화면의 h1 직접 사용" c14 h
run 15 "브랜드 색 면 자리 부품 밖 사용" c15 h
run 16 "무거운 라이브러리 자리 밖 사용" c16 h
run 17 "공간 팔레트 자리 밖 사용" c17 h

echo
echo "걸린 검사:${HIT_LIST:- 없음} / 기준 확인이 필요한 검사: 8·10(1 이상이어야 통과), 12(1개가 아닌 화면은 주 행동 칸과 맞대 판정) —${VAL_LIST:- 해당 없음}"
[ -n "$NA_LIST" ] && echo "해당 없음(검사할 대상이 아직 없음 — 통과와 다르다):$NA_LIST"
exit 0
