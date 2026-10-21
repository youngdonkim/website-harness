---
name: design-system
description: Tailwind + shadcn 위의 3단 토큰 계층(foundation→semantic→component) + 조립 계층(frame·pattern) 디자인 시스템 방법론.
  화면·컴포넌트에 색/간격/글자/그림자를 적용할 때, Tailwind 클래스를 고를 때, CSS·토큰 파일을 만들거나 수정할 때,
  shadcn 부품을 추가·수정할 때, 새 컴포넌트·화면을 만들 때, 새 프로젝트에 토큰 시스템을 도입할 때, 새 토큰을 추가할 때,
  참고 디자인(사이트·스크린샷·색 값·프리셋)에서 색·서체를 뽑을 때 사용.
---

# 디자인 시스템 — 계층 아키텍처

모든 시각 값은 CSS 변수(토큰)를 거쳐서만 쓴다. 스택은 Tailwind + shadcn 고정이라, 제품 코드는 토큰을 **클래스 이름으로 고른다** (`bg-primary`·`p-4`·`text-b1`). hex·px·대괄호 임의 값(`p-[13px]`) 금지.

**토큰 계층 (CSS 파일 — 진입 CSS가 `@import "tailwindcss"` 다음에 1→2→3 순서로 불러온다):**

1. **foundation** (`1-foundation/`) — 기본 값: 색 램프(oklch)·타입 스케일 원본·그리드. `@theme`이 아니라 `:root`에 둔다 — 그래야 램프 이름이 클래스(`bg-brand-600`)로 새지 않는다. 교체 가능 (브랜드/DS 변경 = 이 층 교체)
2. **semantic** (`2-semantic.css`) — 의미: shadcn 변수 이름(`--background`·`--primary`·`--primary-foreground`·`--radius` …)으로 1층을 다시 잇는다. 같은 파일에 `.dark` 블록과 `@theme inline` 블록(여기 적은 이름만 Tailwind 클래스가 된다)을 둔다. Tailwind 기본 팔레트는 여기서 끈다. **화면·컴포넌트 코드가 참조하는 유일한 층**
3. **component** — 부품: 코드는 `components/ui/*.tsx`(shadcn 복사본, 범용)와 `components/*.tsx`(전용). `3-components.css`는 클래스로 못 푸는 전용 스타일과 전역 기본 규칙(body 기본 스타일·동작 줄이기 — [references/bootstrap-project.md](references/bootstrap-project.md) §1.4)만 담는 보조 파일

**조립 계층 (방법론 — 파일 없음):**

4. **frame** — 뼈대: 셸 + 영역 + 크기 예산(size budget). 셸 분류·파생 규칙은 [references/layout-frames.md](references/layout-frames.md) 
5. **pattern** — 검증된 조합: 프레임+컴포넌트를 화면 유형별로 묶은 템플릿 (한 프레임 위에 패턴 여러 개 가능)

**screen (실제 화면)** = 패턴 + 콘텐츠 — 패턴의 인스턴스

## 시작하기 전에 (필수)

**시작 전 브랜치 확인** — 파일을 바꾸기 전에 지금 어느 브랜치인지 먼저 본다.

```bash
git branch --show-current
```

**main이면 `/new-task`를 직접 호출해 작업 브랜치를 연 뒤 진행한다.** main에서 파일을 바꾸면 `auto-wip-commit` 훅이 안 돌아 자동 저장이 안 되고(되돌릴 지점이 안 남는다), 나중에 `no-main-push` 훅에 막혀 올리지도 못한다.

프로젝트의 AGENTS.md에서 **프로젝트 연결 정보(adapter)**를 확인한다 — 항목은 [references/bootstrap-project.md](references/bootstrap-project.md) §4가 정한 adapter 항목(적용 규칙 요약 포함).
없으면 [references/bootstrap-project.md](references/bootstrap-project.md)로 도입부터.

## 철칙

0. **컴포넌트-우선**: 커버하는 기존 컴포넌트/클래스가 있으면 반드시 그걸 쓴다. 새로 만드는 건 최후.
1. 제품 코드(화면·컴포넌트)의 색은 **semantic 이름 클래스만** 쓴다 (`bg-primary`·`text-muted-foreground`). 간격·둥글기·글자는 theme 스케일 클래스를 쓴다 (`p-4`·`rounded-card`·`text-b1`). 대괄호 임의 값(`p-[13px]`)과 괄호 변수(`bg-(--x)`)로 이 이름들을 건너뛰지 않는다.
2. 원시 값(램프 변수·oklch·hex·px 매직넘버)은 **1·2층 CSS 안에서만** 쓴다.
3. foundation은 **read-only** — 수정이 아니라 교체의 대상.
4. 진입 CSS의 로딩 순서는 **`tailwindcss` → 1 → 2 → 3 고정** (순서가 바뀌면 변수 참조가 깨진다).

## 강조색은 어디에 쓰나

강조색(2층 `primary`, 그리고 같은 색에서 진하게·옅게 뽑은 2층 이름)은 **세 자리에만** 쓴다.

1. **화면마다 그 화면의 주 행동 하나** — 강조색으로 꽉 찬 주 버튼. 한 화면에 하나다.
2. **지금 선택된 것** — 고른 칩, 지금 탭, 지금 메뉴 항목의 표시.
3. **키보드 포커스 표시** — 2층 `ring`.

그 밖(장식 선·제목 글자·로고·아이콘·태그·배경 무늬)에는 쓰지 않는다. 서비스를 알리는 색은 강조색이 아니라 아래 「브랜드 색은 어디에 쓰나」의 브랜드 색이 맡는다.

**왜 이렇게 좁히나** — 강조색은 사람에게 「여기를 누르세요」, 「지금 여기 있습니다」라고 알리는 신호다. 장식·제목·로고에도 같은 색이 흩어지면 신호가 여러 곳에서 동시에 켜진 셈이라, 사람은 「지금 무엇을 눌러야 하나」를 찾지 못한다. 반대로 주 행동이 있는 화면에 강조색 주 버튼이 없으면 신호가 아예 꺼져 있어, 사람이 화면을 다 읽고 나서야 할 일을 찾는다. 세 자리에만 쓰면 강조색이 보이는 곳이 곧 「누를 곳·지금 자리」라서, 처음 온 사람도 화면을 훑자마자 다음 행동을 안다.

- **주 행동은 전용 부품이 맡아도 된다** — 주 행동은 `Button`이 아니라 전용 부품(찍기 단추·보내기 막대 등)이 맡아도 된다 — 그때는 그 부품 하나가 강조색 자리다. 여러 걸음으로 된 화면(가입 1→2처럼)은 걸음마다 주 버튼 하나다.
- **그 화면만의 주 행동이 없으면 상단 메뉴의 대표 행동이 주 버튼이 된다** — 예: 목록을 훑기만 하는 화면에서는 상단 메뉴의 「새로 만들기」가 강조색 주 버튼이다. 그 화면만의 주 행동이 있는 화면에서는 상단 메뉴의 대표 행동을 테두리 버튼으로 낮춰, 한 화면에 강조색 주 버튼이 하나만 남게 한다.
- **화면마다 주 행동이 무엇인지는 프로젝트가 정한다** — idea-to-mvp 프로젝트는 `mvp/feature-list.md` 6절 화면 목록의 「주 행동」 칸이 정본이다.
- **shadcn의 `accent`는 강조색이 아니다** — shadcn 이름 세트의 `--accent`는 마우스를 올렸을 때의 옅은 바탕이다. 이 절의 강조색은 `primary` 쪽이다.
- **밝은 강조색을 진하게·옅게 나눠 쓸 때도 자리는 이 셋이다** — 나누는 법은 [visual-polish.md](references/visual-polish.md) D4.
- **상태 색(성공·위험)은 강조색이 아니다** — 그 뜻을 알릴 때만 쓴다 (아래 안티패턴 표).

## 브랜드 색은 어디에 쓰나

브랜드 색(2층 `brand-surface`와 그 짝 `brand-surface-foreground`)은 「이 서비스다」를 알리는 색이다. 강조색이 「여기를 누르세요」를 알리는 신호라면, 브랜드 색은 분위기다. 둘이 섞이지 않게 **모양으로 가른다** — 브랜드 색은 화면 폭을 가로지르는 넓은 면에만 쓰고, 버튼처럼 작은 덩어리에는 쓰지 않는다.

쓰는 자리는 프로젝트가 정한 목록뿐이다. 기본 목록은 다섯이다.

1. 첫 화면 맨 위 띠 — 화면 폭 전체, 높이는 화면의 3분의 1 이하
2. 빈 상태 그림의 바탕
3. 완료 화면의 위쪽 면
4. 로그인·가입 화면의 한쪽 면(넓은 화면) 또는 맨 위 띠(폰) — 입력칸·버튼이 놓인 면은 빼고
5. 로고·파비콘 안의 모양

- **버튼·칩·태그·아이콘·제목 글자에는 쓰지 않는다** — 작은 색 덩어리는 사람이 「누를 곳」으로 읽는다.
- **한 화면에 브랜드 색 면은 하나다.**
- **면 위 주 버튼은 면과 대비 3:1 이상**(WCAG 1.4.11), 면 위 글자는 4.5:1 이상이다. 못 맞추면 버튼을 면 밖으로 내리거나 면 값을 옅게 한다.
- **프로젝트가 브랜드 색을 정하지 않았으면 쓰지 않는다** — 이 이름이 2층에 없으면 지금처럼 강조색 세 자리 규칙만 있다.
- 자리 목록을 더하거나 빼는 결정과 그 이유는 프로젝트가 기록한다 — idea-to-mvp 프로젝트는 `mvp/design-brief.md` 「13. 개성」이 정본이다.

## 결정 트리

**새 화면이 필요하다** (frame-first — 콘텐츠부터 쓰지 말 것)
1. 셸 선택: 프레임 인벤토리 검색 → 그대로 맞으면 재사용 · 뼈대(영역 구성·예산)는 같고
   표현만 다르면 셸 부품의 `variant` · 영역 구성부터 다르면 독립 셸 신설
   → [references/layout-frames.md](references/layout-frames.md) §2.1
   ⚠️ 여럿이 공유하는 셸의 기본 규칙 직접 수정 금지 — 사용처 전부가 같이 바뀐다
2. 기존 패턴에 맞나? 맞으면 패턴 재사용, 콘텐츠만 교체
3. 그다음에야 컴포넌트·토큰 선택으로 내려간다

**새 UI 요소가 필요하다** (component-first)
1. 컴포넌트 인벤토리 검색 — 동의어로도 (예: "모달?" → Dialog 항목)
2. 있다 → 재사용. 살짝 다르면 그 부품의 cva(class-variance-authority)에 `variant`를 더한다 (새 부품 금지). 모양이 기본과 다를 때 고치는 차례는 [references/component-taxonomy.md](references/component-taxonomy.md) §4
3. 없다 → shadcn 부품 목록에서 찾아 `npx shadcn add <이름>`으로 받는다. 같은 파일이 이미 있으면 `--diff`로 먼저 비교하고, `--overwrite`는 쓰지 않는다. 받은 직후 클래스 합치기 import와 누르는 영역 크기를 고친다 ([references/bootstrap-project.md](references/bootstrap-project.md) §1.1 5번)
4. shadcn에도 없다 → 역할 분류 + 범용/전용 판정 후 `components/`에 전용 부품 신규 생성 → [references/component-taxonomy.md](references/component-taxonomy.md)
5. 인벤토리에 등록 — 적기 전에 한 줄 색인 형식([references/component-taxonomy.md](references/component-taxonomy.md) §6)인지 확인. 값·사용법·변경 이력은 인벤토리가 아니라 부품 파일 머리 주석·git log 몫이다

**값(색·간격·모서리…)이 필요하다** (semantic-first)
1. semantic에 의미가 맞는 토큰이 있나? → [references/naming-taxonomy.md](references/naming-taxonomy.md) 유형표로 탐색
2. 있다 → 쓴다
3. 없다 → semantic에 추가 → [references/naming-taxonomy.md](references/naming-taxonomy.md) §5
4. foundation에 기본 값 자체가 없다? → 그때만 foundation 확장 검토 (드묾, 신중히)

간격·둥글기·글자처럼 theme 스케일에 이미 있는 값은 그 클래스(`p-4`·`rounded-card`·`text-b1`)를 쓴다 — 새 토큰을 만들지 않는다.

## 안티패턴

| ✗ 금지 | ✓ 대신 |
|---|---|
| hex/rgb 하드코딩 (`bg-[#333]`, `style={{ color: "#fff" }}`) | semantic 이름 클래스 (`bg-primary`·`text-primary-foreground`) |
| px 매직넘버 간격 (`p-[13px]`) | theme 스케일 클래스 (`p-3`) |
| px 매직넘버 글자크기 (`text-[15px]`) | 글 스케일 클래스(`text-b1`), 안 맞으면 `typography/component` 토큰 새로 만들기 (naming-taxonomy.md §2) |
| 3층·제품 코드에 모션 값(ms·곡선) 직접 쓰기 (`duration-300`, `duration-[250ms]`, `cubic-bezier(…)`, `ease-out`) | 1층 모션 토큰을 2층 이름 클래스로 (`duration-base`·`ease-standard`). Tailwind 기본 곡선 이름(`ease-out` 등)은 끄지 않지만 제품 코드에서 쓰지 않는다 — `ease-standard` 같은 우리 이름만. 동작 줄이기는 전역 규칙 한 번 — [bootstrap-project.md](references/bootstrap-project.md) §1.4 |
| Tailwind 팔레트 이름 (`bg-blue-500`) | semantic 이름 클래스 — 기본 팔레트는 2층에서 꺼 둔다 ([bootstrap-project.md](references/bootstrap-project.md) §1.2) |
| 괄호 변수로 이름 클래스 건너뛰기 (`bg-(--primary)`, `bg-[var(--x)]`) | `@theme inline` 블록에 이름을 올려 클래스로 (`bg-primary`) — naming-taxonomy.md §5.3 |
| 색 있는 배경 위 글자색 하드코딩 | `-foreground` 짝 (`bg-primary text-primary-foreground`) — 배경이 바뀌면 글자도 따라가야 함 |
| 화면에서 부품 겉모양을 `className`으로 덮어쓰기 (`<Button className="bg-… rounded-…">`) | 2층 값 → `variant` → 부품 파일 수정 차례로 ([component-taxonomy.md](references/component-taxonomy.md) §4). 화면이 부품에 주는 `className`은 배치(바깥 여백·폭·flex·grid)만 |
| margin 주려고 wrapper div로 감싸기 | 부품의 `className`에 배치 클래스(`mt-4`) |
| 개념이 같은데 새 부품 생성 (예: `Dialog` 있는데 `Popup` 신설) | 인벤토리 정본 재사용 + `variant` |
| 목록 항목마다 카드로 감싸기 / 카드 중첩 | 밀집 데이터는 행(row)으로 |
| 상태색(danger/success)을 장식용으로 사용 | 상태색은 의미 전달에만 |
| 강조색을 장식·제목·로고·아이콘에 칠함 | 강조색은 주 버튼 하나·선택된 것·포커스 표시에만 — 「강조색은 어디에 쓰나」 |
| 브랜드 색을 버튼·칩·태그·아이콘에 칠하거나, 한 화면에 브랜드 색 면을 둘 이상 둠 | 브랜드 색은 프로젝트가 정한 넓은 면 자리에만, 화면당 하나 — 「브랜드 색은 어디에 쓰나」 |
| 주 행동이 있는 화면에 강조색 주 버튼이 없음 (또는 둘 이상) | 그 화면의 주 행동 하나를 강조색 주 버튼으로, 나머지는 테두리·글자 버튼 — 그 화면만의 주 행동이 없으면 상단 메뉴의 대표 행동이 주 버튼 |
| 글자 크기를 계속 줄여 위계 표현 (14px 밑으로) | 굵기(`font-medium` 등)+명도(`text-muted-foreground` 등) 위계로 표현, 가장 옅은 단계도 대비 4.5:1 유지 ([naming-taxonomy.md](references/naming-taxonomy.md)) |
| 통짜 폰트 파일 로딩 / CDN `<link>`로 웹폰트 불러오기 | 구글 폰트는 `next/font/google`, npm 폰트는 조각화 CSS `@import` ([references/font-loading.md](references/font-loading.md) §4) |
| 하단 상시 요소(버튼 막대·입력창·탭바)를 화면에 붙여 띄우고 본문 끝을 어림 여백으로 비우기 | 셸 설계 때 하단 영역을 정하고 거기 흐름대로 — 스크롤은 본문 영역만 ([references/layout-frames.md](references/layout-frames.md) §2.2) |
| 안내 문구(placeholder)를 라벨 대신 씀 | 이름을 따로 단다 — [common-patterns.md](references/common-patterns.md) §2 (WCAG 3.3.2) |
| 글 입력란 글자가 16px 아래거나 `user-scalable=no`로 확대를 막음 | 16px 이상, 확대 허용 — 같은 문서 §2 (WCAG 1.4.4) |
| 엔터로 확정하는 입력란에 한글 조합 가드가 없음 | 조합 중 엔터는 무시 — 같은 문서 §3 |
| 제목 입력란에서 엔터를 누르면 글이 그대로 올라감 | 본문으로 넘기거나 막는다 — 같은 문서 §3 |
| 사용자가 쓴 글을 저장 형식으로 변환하고 미리보기로 메움 | 쓴 것이 그대로 올라가게 — 같은 문서 §6 |
| 댓글·채팅 입력을 한 줄 입력(`<input>`)으로 | 쓰는 만큼 늘어나는 글 입력란 — 같은 문서 §5 |
| 홈 최상단을 추천 슬라이드·기획전 배너로 연다 | 검색·카테고리 같은 탐색 진입점을 먼저 — 같은 문서 §1 (관찰 37곳 중 0곳) |
| 게시판 커뮤니티 홈에 자동으로 도는 배너를 넣는다 | 커뮤니티엔 두지 않는다 — 같은 문서 §1 (관찰 18곳 중 0곳) |

## 동심원 radius 규칙

패딩 있는 컨테이너 안의 요소 모서리는 `max(0px, 바깥 radius − padding)`.
(카드 안 버튼이 어색하게 각져 보이는 문제 방지. 하드코딩으로 어긋나게 하지 말 것.)
shadcn이 `--radius` 하나에서 `calc(var(--radius) - 2px)`처럼 sm~xl을 파생하는 것도 같은 생각이다.

## 어느 문서를 언제 읽나

- **값(색·간격·모서리…) 이름을 정하거나 새 토큰을 추가할 때** — [naming-taxonomy.md](references/naming-taxonomy.md) (shadcn 이름 문법·유형표 + 새 토큰을 `:root`·`.dark`·`@theme inline`에 잇는 절차)
- **새 UI 컴포넌트를 받거나 만들거나 인벤토리에 등록할 때** — [component-taxonomy.md](references/component-taxonomy.md) (컴포넌트 역할·범용/전용·shadcn 이름 규칙·cva variant 작성·고치는 차례)
- **홈 첫 화면에 무엇을 먼저 둘지 정할 때** — [common-patterns.md](references/common-patterns.md) §1 (SaaS / 커머스 / 마켓플레이스 / O2O / 커뮤니티 / SNS / 사람 매칭 / 혼자 쓰는 기록·도구형 여덟 유형의 최상단 차례와 로그인 전후 갈래 · 관찰 37곳+51곳 · 관례는 기본값이고 사용자 결정이 우선, 다르게 정하면 이유와 함께 기록)
- **댓글창·게시글 에디터처럼 글을 써서 올리는 입력란을 만들 때** — [common-patterns.md](references/common-patterns.md) §2~§7 (접근성 체크 목록 · 컴포저 · 에디터)
- **새 화면·레이아웃을 설계할 때** — [layout-frames.md](references/layout-frames.md) (frame-first 절차, 셸 분류, 컨테이너 정책)
- **참고 사이트·스크린샷에서 스타일 값을 뽑을 때, 또는 그렇게 뽑아 브리프에 적어 둔 값을 토큰으로 옮길 때** — [reference-analysis.md](references/reference-analysis.md) (고르는 법·갤러리 · 입력 네 종류와 값 뽑는 법 · 분석 항목표 · 분석값 → 1층 램프·2층 shadcn 변수 · 금지)
- **화면 생김새를 개선할 때** — [visual-polish.md](references/visual-polish.md) (위계·글자·간격·색·부품·폰 화면으로 옮기기 점검 항목과 지시 문장 예 · 규칙을 디자인 시스템 페이지에 먼저 올리고 비교안을 만들게 한다)
- **개성(그림 소재·브랜드 색 면·제목 서체·로고·사진 톤·대표 장면)을 입힐 때** — [visual-polish.md](references/visual-polish.md) I 개성 묶음과 위 「브랜드 색은 어디에 쓰나」
- **「[서비스 이름] 디자인 시스템」 페이지를 만들거나 고칠 때, 비교안 값을 지금 값과 나란히 보일 때** — [bootstrap-project.md](references/bootstrap-project.md) §6 (보여 주는 것 · 값은 브라우저 계산값으로 · 정본이 아니라 거울 · 범위 클래스로 비교안 값 나란히 · 틀은 `.claude/templates/mockup-canvas/`)
- **폰트를 새로 넣거나 바꿀 때** — [font-loading.md](references/font-loading.md) (조각화·자체 호스팅 원리, Next.js 로딩 결정표 — 구글 폰트·npm 폰트 갈래, `--font-sans`에서 합치기, 빌드 검증 관문 3종)
- **새 프로젝트에 도입할 때** — [bootstrap-project.md](references/bootstrap-project.md)를 순서대로 따른다. 이 절차는 도중에 세 문서를 함께 읽는다: 토큰 3층 단계에서 font-loading.md(폰트 선정·로딩 방식을 같이 정한다 — 미루면 foundation을 다시 갈아엎는다), 인벤토리 생성에서 component-taxonomy.md §6(인벤토리 한 줄 형식), 프레임 정의에서 layout-frames.md §4(웹·앱 통합이면 canvas·gutter 플랫폼 차이)
