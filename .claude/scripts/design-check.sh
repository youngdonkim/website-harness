#!/usr/bin/env bash
# design-check.sh — 3단계 배포 전 「검사 ① 디자인 규칙 검사」의 grep 13개를 한 번에 돌린다.
#
# 판정 기준의 정본: .claude/skills/idea-to-mvp/references/3-frontend-build.md §2.5 「검사 ①」
#   (통과 조건·잡는 예·못 잡는 예·예외 처리는 그 문서를 본다. 이 스크립트는 명령만 실행하고 판정은 하지 않는다.)
#
# 쓰는 법 (프로젝트 최상위 폴더에서):
#   bash .claude/scripts/design-check.sh                      # 13개 전부 (13번은 --allowed 없으면 건너뜀)
#   bash .claude/scripts/design-check.sh --only 1,2,7,12      # 골라서
#   bash .claude/scripts/design-check.sh --allowed "0 1 2 3 4 6 8 12 16"   # 13번 허용 간격 단계(Tailwind 숫자)
#
# 경로·이름은 기본값을 쓰고 환경변수로 덮는다 (여러 경로는 공백으로 구분):
#   PRODUCT_DIRS="src/app src/components"  제품 코드 (ui 폴더는 뺀다)
#   CSS3=src/styles/3-components.css       FOUNDATION_DIR=src/styles/1-foundation
#   SEMANTIC_CSS=src/styles/2-semantic.css ENTRY_CSS=src/app/globals.css
#   STYLES_DIR=src/styles                  PARTS_DIR=src/components
#   INVENTORY=docs/components.md           FEATURE_LIST=mvp/feature-list.md
#   APP_DIR=src/app                        (6번 앱 설정 경로, 12번 화면 폴더 찾는 곳)
#   BTN=Button BTN_FN=buttonVariants PRIMARY=default   (12번: 버튼 부품·클래스 함수·주 버튼 variant)
#
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

g() { command grep "$@"; }

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
  g -rnE --exclude-dir=ui '#([0-9a-fA-F]{3}|[0-9a-fA-F]{4}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})|rgba?\(|hsla?\(|oklch\(|oklab\(' "${EX[@]}"
  g -rnE --exclude-dir=ui '[0-9]+px' "${EX[@]}"
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
  g -rnwF --exclude-dir=ui -f "$T/foundation-vars.txt" "${t[@]}"
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
  g -rn --exclude-dir=ui 'key === "Enter"' "${EX[@]}"
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
  g -rnoE --exclude-dir=ui '(duration|delay|ease)-\[[^]]+\]|(duration|delay)-[0-9]+|[0-9]+ms|cubic-bezier\(|(^|[^a-z-])ease-(linear|in-out|in|out)\b' "${EX[@]}"
}

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

echo
echo "걸린 검사:${HIT_LIST:- 없음} / 기준 확인이 필요한 검사: 8·10(1 이상이어야 통과), 12(1개가 아닌 화면은 주 행동 칸과 맞대 판정) —${VAL_LIST:- 해당 없음}"
exit 0
