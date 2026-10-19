# 새 프로젝트에 이 시스템 도입하기

이 스킬은 website-harness 하네스에 들어 있어서, 하네스를 적용한 프로젝트에서는 따로
복사할 필요 없이 바로 쓸 수 있다. 새 프로젝트에 이 디자인 시스템을 도입할 때는 아래
순서를 따른다. 스택은 Tailwind + shadcn 고정이다.

CSS 3층만으로(`3-components.css`가 부품 코드가 들어 있는 구조) 이미 지은 프로젝트는 그대로 둔다 —
이 절차는 새 프로젝트에 적용한다.

## 목차

0. [목업 가져오기 — 보여 주기용 틀 걷어 내기](#0-목업-가져오기--보여-주기용-틀-걷어-내기)
1. [토큰 3층 구축 — shadcn 위에](#1-토큰-3층-구축--shadcn-위에)
   - [1.1 순서](#11-순서)
   - [1.2 2층 파일의 모양](#12-2층-파일의-모양)
   - [1.3 진입 CSS](#13-진입-css)
   - [1.4 모션 토큰과 동작 줄이기 규칙](#14-모션-토큰과-동작-줄이기-규칙)
   - [1.5 클래스 합치기 함수에 우리 이름 알려 주기](#15-클래스-합치기-함수에-우리-이름-알려-주기)
   - [1.6 받은 부품의 누르는 영역을 바닥선에 맞추기](#16-받은-부품의-누르는-영역을-바닥선에-맞추기)
2. [컴포넌트 인벤토리(사전) 생성](#2-컴포넌트-인벤토리사전-생성)
3. [프레임 정의](#3-프레임-정의)
4. [AGENTS.md에 프로젝트 연결 정보(adapter) 기록](#4-agentsmd에-프로젝트-연결-정보adapter-기록)
5. [다크모드 대비 노트](#5-다크모드-대비-노트)
6. [디자인 시스템 페이지](#6-디자인-시스템-페이지)
   - [6.1 보여 주는 것](#61-보여-주는-것)
   - [6.2 정본이 아니라 거울](#62-정본이-아니라-거울)
   - [6.3 비교안 값을 나란히 보이기](#63-비교안-값을-나란히-보이기)

---

## 0. 목업 가져오기 — 보여 주기용 틀 걷어 내기

외부 목업 도구에서 만들어진 목업·프로토타입을 이식해 시작하는 경우에만 필요한 선행 단계.
백지에서 시작한다면 이 절은 건너뛰고 1로. idea-to-mvp로 진행하는 프로젝트는 2단계부터 화면을
이 스택의 리액트로 바로 짓기 때문에 이 절을 건너뛴다 — 예외는 아티팩트 캔버스로 진행하다
리액트로 옮겨 오는 프로젝트다 (idea-to-mvp `2-0-dev-setup.md` §2.7).

목업 생성 도구는 결과물을 화면 하나로 보여주는 게 아니라 **"보여 주기용 틀"**까지
함께 만들어낸다 — 기기 프레임, 가짜 상태바, 고정 크기 화면 틀 같은 것들. 이걸 가져오는 시점에
걷어내지 않으면 이후 몇 주에 걸쳐 화면을 만질 때마다 하나씩 발견하며 뒤늦게 재작업하게 된다.
첫날 한 번에 걷어내는 편이 훨씬 싸다.

**이렇게 들어온 목업인지 확인하기**: 예를 들어 "모바일 앱 디자인" 같은 템플릿으로 뽑은 목업은
아래 보여 주기용 틀을 달고 온다. 마크업에 기기 프레임
래퍼, 상태바·다이나믹 아일랜드 마크업, 고정 px 화면 크기, 목업에 통째로 들어 있는 폰트·이미지가
보이면 이 절차부터 거친다.

**보여 주기용 틀 체크리스트**:

- **기기 프레임 래퍼 상자**: 뷰포트 안에 '폰'을 연출하는 다중 래퍼
  (`min-height: 100vh` → `relative` `100vh` → `overflow: hidden` …)를 화면 절대배치
  컨테이너 1겹으로 축소한다.
- **가짜 기기 크롬**: 상태바(시계·배터리)·다이나믹 아일랜드·홈 인디케이터 마크업은
  `display: none`이어도 삭제한다. 그 공간 예약값(상단 고정 px, 하단 고정 px)도 함께 삭제하고,
  실기기 안전영역은 `env(safe-area-inset-*)` 토큰으로 대체한다.
- **`display: none` 전수 수색**: 마크업은 죽었는데 예약 공간·상자만 남은 것들을 찾는다.
- **번들 자산**: 목업에 통째로 들어 있는 폰트(수 MB)는 CDN이 아니라 `next/font`(구글 폰트) 또는
  조각화 CSS(npm 폰트)로 옮긴다 ([font-loading.md](font-loading.md) §4). 이미지는 최적화된 경로로 옮긴다.
- **고정 화면 크기**(예: 430×884)를 반응형 계약으로 전환한다.
- **인라인 스타일의 혈통 인지**: 생성 목업은 반복 요소와 1회성 요소를 구분하지 않고 전부
  인라인으로 찍어낸다. "모양만 다른 중복"(같은 버튼이 여러 화면에 복붙된 경우)이 많으므로,
  이후 2에서 부품 승격 감사를 전제로 진행한다.
- 목업 원본 파일은 정본 참조용으로 로컬에는 보관하되 레포 추적은 해제한다.

이 단계가 끝나면 1로 진행한다.

## 1. 토큰 3층 구축 — shadcn 위에

```
src/app/globals.css     ← 진입 CSS: import 줄만 (§1.3)
src/styles/
  1-foundation/         ← 원시 토큰: 색 램프(oklch), 타입 스케일 원본, 그리드, 그림자, 모션(길이·곡선) — :root에
  2-semantic.css        ← shadcn 이름 + .dark + `@theme inline` 블록. 값은 전부 1층 변수 참조
  3-components.css      ← 보조: 클래스로 못 푸는 전용 스타일, body 기본 스타일, 동작 줄이기 전역 규칙(§1.4)
src/components/ui/      ← 3층 부품 코드(범용): shadcn이 복사해 준 부품
src/components/         ← 3층 부품 코드(전용): 이 서비스만 쓰는 부품
```

### 1.1 순서

1. **`npx shadcn init`** — `components.json`·`lib/utils.ts`(`cn()`)·진입 CSS의 변수 블록과 import 줄이 생긴다.
   `components.json`의 CSS 경로(`tailwind.css` 항목)는 진입 CSS(`globals.css`)로 둔다. init이 진입 CSS에
   써 넣은 `:root`·`.dark`·`@theme inline` 블록은 2층 파일로 옮기고, 이후 부품을 받을 때 진입 CSS에
   덧붙는 변수(예: sidebar·chart 부품의 변수)도 2층으로 옮긴다 — 도입 때 실측으로 확정한다. init이 넣은
   import 줄은 지우지 않고 §1.3 순서 안에 둔다.
   그다음 **클래스 합치기 함수(`cn()`)에 우리 이름을 알려 준다** (§1.5) — 2층에 우리 글자 이름·둥글기 이름을
   만들자마자 필요하다.
2. **1층 램프** — 채택한 디자인 시스템(또는 자체 브랜드)의 원시 값을 oklch로 채운다. `:root`에 둔다 —
   `@theme`에 두면 `bg-brand-600` 같은 램프 클래스가 생겨 2층을 건너뛰는 길이 열린다. 이 층은 read-only 취급 —
   이후 브랜드가 바뀌면 이 층을 통째로 교체한다.
   모션 기본 값도 이때 1층에 자리를 잡는다 (§1.4).
3. **2층을 shadcn 이름으로 다시 잇기** — init이 넣은 이름 세트(`--background`·`--card`·`--popover`·`--primary`·
   `--secondary`·`--muted`·`--accent`·`--destructive`·`--border`·`--input`·`--ring`·`--chart-*`·`--sidebar-*` …와
   각자의 `-foreground` 짝)를 지우지 말고 전부 1층 변수로 다시 잇는다(§1.2). 이름 세트를 shadcn이 정해 주니
   받은 부품이 그대로 돈다.
4. **진입 CSS의 import 순서를 고정한다** (§1.3).
5. **필요한 부품을 받는다** — `npx shadcn add <이름>`. 받은 부품은 2층 값만으로 브랜드 색·모양이 그대로 적용된다 — 색·모양을 위한 수정은 0줄이
   정상이다. 파일을 고쳐야 하면 먼저 2층 값으로 풀 수 있는지 보고, 그래도 고쳤으면 adapter의 「고친 shadcn 부품
   목록」(§4)에 파일과 이유를 한 줄 적는다. **받은 직후 두 가지는 매번 고친다** — 둘 다 2층 값으로는 못 풀어
   부품 파일을 고치는 일이고, 고친 것은 그 목록에 적는다.
   - **클래스 합치기 import** — 받은 부품이 `cn`을 `@/lib/utils`가 아닌 곳(shadcn이 쓰는 합치기 패키지)에서
     바로 불러오면 `@/lib/utils`로 바꾼다 (§1.5).
   - **누르는 영역 크기** — 버튼·입력칸·고르기 칸·탭·체크 상자의 누르는 영역을 접근성 바닥선에 맞춘다 (§1.6).
6. **2층 파일 맨 끝에 「비교안」 블록 자리를 만들어 둔다** — `2-semantic.css` 맨 끝에 주석 한 줄
   (`/* 비교안 — 화면 개선 비교 동안만. 이 아래에 범위 클래스를 둔다 (bootstrap-project.md §6.3) */`)만 두고
   비워 둔다. 화면 개선 단계(idea-to-mvp 2-2)가 이 자리에 비교안 범위 클래스를 넣고, 고른 뒤 비운다 —
   자리가 처음부터 있어야 비교안 값이 2층 본 값 사이로 섞여 들어가지 않는다.

- **폰트 선정 + 로딩 방식 결정도 이 단계에서 함께** 한다. 색 팔레트만 정하고 폰트를 뒤로 미루면
  나중에 foundation을 다시 갈아엎게 된다 ([font-loading.md](font-loading.md)).

### 1.2 2층 파일의 모양

값은 자리표시자다. 1층 이름(`--gray-*`·`--brand-*`·`--b1-base` 등)은 1층이 정한다.

```css
/* src/styles/2-semantic.css — 의미 이름. 값은 전부 1층 변수만 가리킨다 */
:root {
  --background: var(--gray-0);
  --foreground: var(--gray-900);
  --primary: var(--brand-600);
  --primary-foreground: var(--gray-0);
  --muted-foreground: var(--gray-600);   /* 가장 옅은 글자 — 배경과 4.5:1 이상 */
  --destructive: var(--red-600);         /* 상태 의미 전용, 장식 금지 */
  --border: var(--gray-200);
  --radius: var(--radius-base);          /* 하나에서 sm~xl을 파생 */
}
.dark {                                  /* 다크 모드 교체점 — 전환 장치는 아직 두지 않는다 */
  --background: var(--gray-950);
  --foreground: var(--gray-50);
  --primary: var(--brand-400);
  --primary-foreground: var(--gray-950);
}
@theme inline {                          /* `@theme inline` 블록 — 여기 적은 이름만 클래스가 된다 */
  --color-*: initial;                    /* Tailwind 기본 팔레트를 끈다 — bg-blue-500 같은 클래스가 아예 안 생긴다 */
  --color-white: oklch(1 0 0);           /* shadcn 복사본의 text-white·bg-black/50이 안 깨지게 둘만 남긴다 */
  --color-black: oklch(0 0 0);
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);

  --radius-sm: calc(var(--radius) - 4px);
  --radius-md: calc(var(--radius) - 2px);
  --radius-lg: var(--radius);
  --radius-control: calc(var(--radius) - 2px);   /* 용도 이름 — rounded-control. 제품 코드는 이쪽을 먼저 */
  --radius-card: var(--radius);                  /* rounded-card */

  --font-sans: var(--font-base), var(--font-pretendard), "Apple SD Gothic Neo", sans-serif;
                                         /* 구글 폰트(next/font 변수)와 npm 폰트(패밀리 이름)를 여기서만 합친다 */

  --text-b1: var(--b1-base);             /* 우리 글 스케일 — text-b1. 제품 코드는 이 이름을 먼저 */
  --text-b1--line-height: var(--b1-line);
  --text-sm: var(--b2-base);             /* Tailwind 기본 이름을 우리 값으로 다시 정의 — 복사본의 text-sm이 우리 스케일을 쓴다 */
  --text-sm--line-height: var(--b2-line);
  --text-xs: var(--b2-base);             /* 복사본의 text-xs도 글자 바닥선(14px) 아래로 내려가지 않게 */
  --text-xs--line-height: var(--b2-line);
}
```

- **1층 램프는 `@theme`이 아니라 `:root`에 둔다.** 그래야 램프 이름 클래스가 아예 생기지 않는다.
- **`@theme inline` 블록에서 `inline`이 필요한 이유**: `--font-base`는 `next/font`가 `<html>`에 붙이는 변수라 `:root`
  시점엔 없다. `inline`이면 클래스가 그 자리에서 값을 찾는다.
- **기본 팔레트를 끄는 줄(`--color-*: initial`)은 빼지 않는다.** 빠지면 `bg-blue-500` 같은 팔레트 클래스가
  다시 살아나 2층을 건너뛰는 길이 열린다. 3단계 배포 전 검사의 디자인 규칙 검사가 이 줄이 있는지 확인한다.
- **글 스케일은 우리 이름(`text-b1` 등)을 먼저 쓴다.** Tailwind 기본 이름(`text-sm`·`text-xs`)은 막지 않고
  우리 값으로 다시 정의해 둔다 — 막으면 shadcn 복사본의 `text-sm`이 사라져 부품이 깨진다. 복사본이 쓰는
  기본 이름이 더 있으면 같은 식으로 다시 정의한다.
- **둥글기는 용도 이름(`rounded-card`)을 먼저 쓴다.** 크기 이름(`rounded-md`)도 허용한다 — shadcn 복사본이
  쓰는 이름이다.

### 1.3 진입 CSS

진입 CSS(`globals.css`)는 import 줄만 둔다:

```css
@import "tailwindcss";
@import "tw-animate-css";                /* shadcn init이 넣는 줄 — 받은 그대로 둔다 */
@import "shadcn/tailwind.css";           /* shadcn init이 넣는 부품 상태 스타일 줄(예: `data-open:` 같은 상태 접두어) — 받은 그대로 둔다 */
@import "pretendard/dist/web/variable/pretendardvariable-dynamic-subset.css";
                                         /* npm 폰트를 쓸 때만 — 조각화 CSS (font-loading.md §4) */
@import "../styles/1-foundation/index.css";
@import "../styles/2-semantic.css";
@import "../styles/3-components.css";

@custom-variant dark (&:is(.dark *));    /* shadcn init이 넣는 줄 — import 줄 뒤에 둔다 */
```

- `body`의 `bg-background text-foreground` 같은 기본 스타일은 `3-components.css` 맨 위로 옮긴다.
- 로딩 순서 `tailwindcss` → 1 → 2 → 3은 바꾸지 않는다.
- **shadcn이 넣는 import 줄은 판마다 이름이 다를 수 있다** — 위 `tw-animate-css`·`shadcn/tailwind.css`는 예다. 도입할 때 init이 진입 CSS에 실제로
  넣은 import 줄과 shadcn 문서(설치 안내의 CSS 절)를 대조해, 그 줄들을 `tailwindcss` 바로 다음·폰트와 1층 앞에 그대로 둔다. 빼면 부품의
  열림·닫힘 같은 상태 모양이 조용히 사라진다. 이 순서는 연결 정보(§4)의 import 순서에 그대로 적는다.

### 1.4 모션 토큰과 동작 줄이기 규칙

움직임 값도 색처럼 1층 기본 값 → 2층 이름으로 전달된다. 길이 세 단계(빠름·보통·느림)와 가속 곡선(easing) 두세 개면
충분하다. 값 몇 개만 바꾸면 앱 전체 움직임의 느낌이 같이 바뀌게 하려는 것이다. 이름은
[naming-taxonomy.md](naming-taxonomy.md) 유형표 motion 행을 따른다. 값은 자리표시자다 —
idea-to-mvp 3단계면 `mvp/design-brief.md` 「8. 모션·인터랙션 방향」의 분석 결과로 채운다.

```css
/* 1층 — src/styles/1-foundation/motion.css */
:root {
  --motion-fast: 120ms;
  --motion-base: 200ms;
  --motion-slow: 320ms;
  --curve-out: cubic-bezier(0.2, 0, 0, 1);            /* 끝에서 부드럽게 멈춤 */
  --curve-spring: cubic-bezier(0.34, 1.56, 0.64, 1);  /* 끝에서 살짝 튐 — 생동감이 필요할 때만 */
}

/* 2층 — src/styles/2-semantic.css */
:root {
  --duration-fast: var(--motion-fast);
  --duration-base: var(--motion-base);
  --duration-slow: var(--motion-slow);
}
@theme inline {
  --transition-duration-fast: var(--duration-fast);   /* → duration-fast */
  --transition-duration-base: var(--duration-base);   /* → duration-base */
  --transition-duration-slow: var(--duration-slow);   /* → duration-slow */
  --ease-standard: var(--curve-out);                  /* → ease-standard */
  --ease-emphasis: var(--curve-spring);               /* → ease-emphasis */
  --default-transition-duration: var(--duration-fast);         /* transition-colors 같은 클래스의 기본 길이 */
  --default-transition-timing-function: var(--ease-standard);  /* 기본 곡선 — 같은 블록의 2층 이름을 가리킨다 */
}

/* 전역 — src/styles/3-components.css 맨 위, body 기본 스타일 옆. 예외 없음 */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0s !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0s !important;
    scroll-behavior: auto !important;
  }
}
```

- **길이 클래스(`duration-fast` 등)는 `@theme inline` 블록의 `--transition-duration-*` 이름으로 만든다.** Tailwind가 길이 클래스를
  찾는 이름 자리가 `--transition-duration-*`이라, `--duration-*`을 `@theme inline` 블록에 그대로 올리면 클래스가 생기지 않는다.
  이렇게 만든 `duration-fast`는 Tailwind의 `duration-150`과 같은 모양(`--tw-duration` 변수 + `transition-duration`)으로
  나와서, CSS 전환과 tw-animate-css 등장 효과(`animate-in`이 `--tw-duration`을 읽는다) 둘 다에 길이가 적용된다.
  곡선은 `@theme inline` 블록의 `--ease-*` 이름이 바로 클래스가 된다(1층 변수를 가리켜도 된다).
- **기본 길이·곡선(`--default-transition-*`)은 2층 이름을 가리킨다.** 같은 `@theme inline` 블록 안 이름(`--ease-standard`)을
  가리켜도 `transition-colors` 같은 클래스가 그 값을 쓴다.
- 실측: Tailwind v4.3.3, 2026-10-06 (tw-animate-css 1.4.0과 함께 빌드해 결과 CSS로 확인).
- **동작 줄이기(prefers-reduced-motion)** — 운영체제 설정에서 움직임을 줄여 달라고 켜 둔 사람에게는 움직임을 끈다.
  화면마다 분기하지 않고 위 전역 규칙 한 번으로 처리한다. 값을 `0s`로 적는 건 3단계 디자인 규칙 검사의 ms 하드코딩 검사에
  걸리지 않게 하려는 것이다. JS로 돌리는 움직임(예: `motion` 라이브러리)은 이 규칙이 못 끄니, 들였으면 그
  라이브러리의 전역 동작 줄이기 설정을 앱 맨 바깥에 한 번 건다.
- **3층·제품 코드에는 ms 값과 곡선을 적지 않는다** — `duration-300`·`duration-[250ms]`·`cubic-bezier(…)` 대신
  `duration-base`·`ease-standard`. Tailwind 기본 곡선 이름(`ease-out` 등)은 끄지 않지만 제품 코드에서 쓰지 않는다 —
  `ease-standard` 같은 우리 이름만. 3단계 디자인 규칙 검사 11번 grep이 잡는다.

### 1.5 클래스 합치기 함수에 우리 이름 알려 주기

shadcn 부품은 받은 `className`을 자기 클래스와 합칠 때 클래스 합치기 함수를 쓴다(`cn()` — 겹치는 클래스 중 뒤의 것만 남긴다).
이 함수 안의 합치기 도구(`tailwind-merge`, 또는 shadcn이 새로 쓰는 `cn` 패키지)는 **Tailwind 기본 이름만 안다.** 그래서 우리 2층 이름을
모르는 채로 두면 이런 일이 생긴다.

- `cn("text-b2 text-muted-foreground")` — 도구는 `text-b2`를 글자색 클래스로 잘못 알고, 뒤의 `text-muted-foreground`와 겹친다고 보아
  **`text-b2`를 지운다.** 글자 크기가 조용히 기본값으로 돌아간다.
- `cn("rounded-card", className)`에 화면이 `rounded-control`을 넘겨도 — 도구는 두 이름이 같은 종류인 줄 몰라 둘 다 남기고, 어느 쪽이 이길지는
  CSS 순서에 달린다.

그래서 **우리 이름을 알려 준 합치기 함수를 `src/lib/utils.ts`에 두고, `components/ui/` 부품이 모두 그것을 쓰게 한다.**

```ts
// src/lib/utils.ts — 우리 2층 이름을 알려 준 클래스 합치기
// shadcn이 `cn` 패키지를 쓰면 이 모양, `tailwind-merge`를 쓰면 같은 설정을 `extendTailwindMerge`에 넘긴다.
import { createCn } from "cn/config"

export const cn = createCn({
  extend: {
    theme: {
      radius: ["card", "control"],          // rounded-card · rounded-control
      container: ["content", "reading"],    // max-w-content · max-w-reading
      ease: ["standard", "emphasis"],       // ease-standard · ease-emphasis
    },
    classGroups: {
      "font-size": [{ text: ["h1", "h2", "h3", "h4", "b1", "b2"] }],   // text-h1 … text-b2 — 글자색이 아니라 글자 크기
      duration: [{ duration: ["fast", "base", "slow"] }],             // duration-fast …
    },
  },
})
```

- **알려 줄 이름은 2층 `@theme inline` 블록에 우리가 더한 이름 전부다** — 글자 크기·둥글기·컨테이너 폭·간격·움직임. 이름 목록은 위가 아니라
  이 프로젝트의 2층 파일이 정본이다. 2층에 이름을 더하거나 지우면 `utils.ts`도 같이 고친다.
- **설정 모양은 그때 쓰는 도구의 문서로 확인한다** — `tailwind-merge`와 `cn` 패키지는 같은 `{ extend: { theme, classGroups } }` 모양을 받는다.
  `package.json`에 어느 쪽이 들어 있는지 보고 그 도구의 설정 함수를 쓴다.
- **부품이 모두 이 함수를 쓰게 한다** — 받은 부품이 합치기 패키지에서 바로 `cn`을 불러오면(`import { cn } from "cn"` 같은 줄) `@/lib/utils`로
  바꾼다. `components.json`의 `utils` 별칭을 `@/lib/utils`로 두어도 받은 부품이 패키지를 바로 부를 수 있으니, 받을 때마다 확인한다.
- **새 부품을 받을 때마다 차례** — ① `npx shadcn add <이름>` → ② 아래 명령으로 패키지를 바로 부르는 부품 파일을 찾는다 → ③ 나온 파일의 import 줄을
  `import { cn } from "@/lib/utils"`로 바꾼다 → ④ 다시 돌려 0건인지 본다.

  ```bash
  grep -rlE "from ['\"](cn|tailwind-merge)['\"]" src/components/ui
  ```

- **연결 정보에 적는다** — 「고친 shadcn 부품 목록」(§4)에 「`components/ui/*.tsx` 전부 — `cn` import를 `@/lib/utils`로 바꿈. 새로 받은 부품도
  같은 줄을 바꾼다」 한 줄을 둔다. 부품을 다시 받으면 이 줄 때문에 import가 원래대로 돌아간다는 것을 알 수 있다.

### 1.6 받은 부품의 누르는 영역을 바닥선에 맞추기

shadcn 기본 부품의 높이는 접근성 바닥선보다 낮은 것이 많다 — 입력칸·고르기 칸·탭은 32px 안팎, 체크 상자는 16px 안팎이다. 손가락으로
누르는 요소는 누르는 영역이 44px 이상이어야 한다(idea-to-mvp는 `mvp/design-brief.md` 「9. 접근성 바닥선」이 정한 값).

- **받은 직후 부품 파일에서 고친다** — 버튼·입력칸·고르기 칸(Select의 누르는 칸)·탭·체크 상자·라디오처럼 누르는 요소가 있는 부품을 받으면
  그 자리에서 높이(또는 누르는 영역)를 바닥선에 맞춘다. 화면에서 `className="h-11"`처럼 덮어쓰지 않는다 — 화면이 부품에 주는 클래스는
  배치뿐이고([component-taxonomy.md](component-taxonomy.md) §4), 화면마다 덮어쓰면 덮어쓰지 않은 화면에서 바닥선이 깨진다.
- **보이는 크기와 누르는 영역은 따로 맞춰도 된다** — 체크 상자처럼 보이는 네모를 키우면 어색한 부품은, 네모는 두고 누르는 영역만 넓힌다
  (부품 안의 바깥 여백이나 라벨까지 누르는 영역으로 묶기).
- **작은 크기(`size="sm"` 등)도 같은 바닥선이다** — 누르는 요소에 바닥선 밑 크기를 남겨 두지 않는다.
- **연결 정보에 적는다** — 고친 부품과 고친 내용을 「고친 shadcn 부품 목록」(§4)에 한 줄씩 적는다.
- **부품 모양 값이 바닥선과 부딪히면 바닥선이 이긴다** — 예: 브리프의 부품 모양에 「버튼 높이 40」이 있고 바닥선이 44면 44로 만들고, 부딪힌 것을
  보고에 적어 사람이 브리프를 고치게 한다.

## 2. 컴포넌트 인벤토리(사전) 생성

프로젝트 문서(예: `docs/components.md`)에 새로 작성:
- 등록 단위는 **부품 파일**이다. 구분은 둘 — `components/ui/`(범용, shadcn에서 받은 것)와 `components/`(전용)
- §1.1에서 받은 범용 부품을 등록하고, 앞으로 받거나 만드는 부품은 그때마다 등록한다
- 문서 끝에 「## 전체 부품 색인」 구간까지 만든다 — 부품을 더하거나 지울 때마다 다시 만든다
- 형식·규칙은 [component-taxonomy.md](component-taxonomy.md) §6

## 3. 프레임 정의

frame-first로 셸·영역·크기 예산을 먼저 정하고, 예산은 layout/frame-budget 토큰으로 적는다.
웹·앱 통합 개발이면 canvas·gutter의 플랫폼별 차이까지 이때 결정한다
([layout-frames.md](layout-frames.md) §4).
화면 아래에 늘 보여야 하는 요소(주 동작 버튼 막대·탭바 등)의 자리도 이때 정한다 —
공통 셸은 하단 고정 요소가 아직 없어도 헤더/본문/하단 세 영역으로 시작한다
([layout-frames.md](layout-frames.md) §2.2).

## 4. AGENTS.md에 프로젝트 연결 정보(adapter) 기록

스킬은 범용, 프로젝트는 제각각 — 둘을 이어주는 **이 프로젝트만의 연결 정보**를 AGENTS.md에 기록한다:
- 진입 CSS와 세 층 파일 경로, import 순서 (shadcn이 넣은 import 줄 포함 — §1.3)
- `components.json` 위치와 경로 별칭(예: `@/components/ui`)
- 컴포넌트 인벤토리 위치 (두 곳 — `components/ui/`·`components/`)
- 프레임 인벤토리·화면 패턴 목록 위치
- **고친 shadcn 부품 목록** — 받은 뒤 직접 고친 `components/ui/` 파일과 고친 이유 한 줄씩. 부품을 다시 받을 때
  `--diff`로 비교하고 이 목록대로 다시 고친다(`--overwrite` 금지). 목록이 없으면 다시 받는 순간 우리 수정이
  조용히 사라진다. 받을 때마다 하는 두 가지(클래스 합치기 import — §1.5, 누르는 영역 바닥선 — §1.6)도 이 목록에 둔다
- 디자인 규칙 검사 예외 줄 (3단계 배포 전 검사 중 디자인 규칙 검사의 grep에 걸리지만 남길 값 — 예: `1px` 테두리)과 프로젝트 고유 함정 토큰. 일찍 시작한 프로젝트의 `AGENTS.md`에는 옛 이름 「관문 ① 예외 줄」로 남아 있을 수 있는데, 같은 항목이다
- 철칙 요약 (짧게 — 항상 컨텍스트에 있어야 하는 안전장치)
- **적용 규칙 요약** — 부품 값을 고를 때 매번 필요한 규칙을 구조 규칙 옆에 몇 줄로 요약한다. 항목은 스킬이 정하고, 값은 프로젝트가 채운다: ① 글자 크기 바닥선과 예외 자리 ② 역할 한정 토큰 목록(어느 토큰이 어느 자리 전용인지). 왜 여기 두나 — 스킬 본문은 자동 주입이 아니라서, 지시서만 받는 서브 에이전트는 AGENTS.md에 없는 적용 규칙을 알 길이 없다. 그리고 「토큰을 썼는가」만 보는 구조 검사는 「그 토큰을 맞는 자리에 썼는가」(예: 본문에 캡션용 작은 글자 토큰을 씀)를 잡지 못한다 — 쓸 때 규칙을 아는 수밖에 없다.

## 5. 다크모드 대비 노트

지금 다크모드를 만들지 않더라도, **2층의 `.dark` 블록이 교체점이 되도록** 설계해 둔다:
- 색은 반드시 semantic 이름 클래스를 거치게 (제품 코드에 램프 직접 참조 금지 — 철칙 1·2가 곧 다크모드 대비다)
- 색 배경 위 글자는 `-foreground` 짝으로 분리
- 이후 다크모드 = `.dark` 블록의 값을 다크용 램프 단계로 채우는 작업으로 끝난다. 전환 장치(예: `next-themes`)는
  다크모드를 실제로 만들 때 붙인다

## 6. 디자인 시스템 페이지

도입(§1~§4)을 마치면 **「[서비스 이름] 디자인 시스템」 페이지**(서비스 이름을 그대로 넣는다)를 하나 둔다.
실제 토큰과 실제 부품으로 그린 개발용 페이지로, 토큰·부품이 지금 어떻게 보이는지를 한 페이지에서 본다.
「규칙 페이지」라고 부르지 않는다.

- **자리** — 주소 `/dev/design-system`(`src/app/(dev)/dev/design-system/page.tsx`). 개발용 묶음 `src/app/(dev)/` 아래라
  개발 서버에서만 열리고 실서비스 빌드에서는 404다 — `(dev)/layout.tsx`가 막는다.
- **틀** — 하네스의 `.claude/templates/mockup-canvas/`에 뼈대가 있다(쓰는 법은 그 폴더 `README.md`). 목업 캔버스
  (`/dev/canvas` — 만든 화면을 데스크톱 폭·폰 폭으로 나란히 띄워 보는 개발용 페이지)와 함께 들어 있다. 복사하면서 끝의
  `.template`을 떼고, `{{…}}` 자리에 서비스 이름과 이 프로젝트의 2층 이름·글자 이름·부품을 채운다. idea-to-mvp는
  2단계 개발환경 준비에서 넣는다 (`2-0-dev-setup.md` §2.6).
- **이 페이지의 코드도 철칙을 지킨다** — 2층 이름 클래스와 theme 단계 클래스만 쓰고, hex·px·대괄호 임의 값을 쓰지 않는다.
  본 코드(본 화면·`src/components/`)가 개발용 묶음을 불러오지 않는다.

### 6.1 보여 주는 것

| 칸 | 무엇을 | 어떻게 |
|---|---|---|
| 글자 단계 | 우리 글자 이름(`text-h1`~`text-b2`)마다 견본 문장, 크기·굵기·줄 간격, 쓰는 자리 | 견본에 클래스를 입히고 계산값을 읽는다 |
| 색 역할 | 2층 이름(`primary`·`highlight`·`emphasis` 등)마다 견본과 쓰는 자리 | 견본 상자의 계산값(`getComputedStyle`)을 읽어 보인다 |
| 간격 | 간격 단계(Tailwind 단계)마다 견본 막대 | 같은 방식 |
| 둥글기 | 용도 이름(`rounded-card`·`rounded-control`)과 크기 이름 | 같은 방식 |
| 격자 | 단 수·본문 최대 폭·칸 사이·긴 글 폭(`max-w-content`·`max-w-reading` 등) | 같은 방식 |
| 부품 다섯 상태 | 버튼(variant별)·칩·입력칸·탭 등의 평소·마우스 올림·누름·비활성·포커스 | 평소와 비활성은 그대로 그린다(`disabled`). 마우스 올림·누름은 사람이 직접 올리고 눌러 보는 칸, 포커스는 Tab 키로 옮겨 보는 칸으로 둔다 — 상태를 억지로 고정하려고 부품에 개발용 속성을 더하지 않는다 |
| 폰 배치 메모 | 어느 폭에서 무엇이 접히는지(칸 수·메뉴가 접히는 폭·목록 한 줄에서 덜어내는 것) | 글로 적는다 |

- **값은 코드에 적지 않는다** — 브라우저가 계산한 값을 읽어 보여 준다. 그래야 이 페이지가 hex·px 검사에 걸리지 않고,
  토큰 값이 바뀌어도 페이지를 고치지 않고 저절로 따라온다.
- **언제 고치나** — 토큰 값만 바뀌면 손댈 것이 없다. 2층 이름·글자 이름·variant·부품을 새로 더하거나 지우면 이
  페이지 목록에도 한 줄 더하거나 지운다 — 컴포넌트 인벤토리(§2)에 등록할 때 같이 한다.

### 6.2 정본이 아니라 거울

이 페이지는 토큰의 정본(1·2층 CSS)과 부품 파일을 비춰 보여 주는 거울이다. 값의 정본은 1층, 이름의 정본은 2층,
부품 모양의 정본은 부품 파일이다. 「어디에 어떻게 쓰나」 같은 규칙 결정의 정본은 프로젝트가 정한 기록 자리다 —
idea-to-mvp 프로젝트면 `mvp/design-brief.md` 「12. 화면 규칙」. 페이지와 CSS가 다르게 보이면 CSS가 맞다 — 값을 고치려면
1·2층 CSS를 고치고, 페이지에는 값을 적지 않는다.

### 6.3 비교안 값을 나란히 보이기

화면 개선(idea-to-mvp 2-2)처럼 토큰 값을 바꿔 보는 동안은 「지금 값」 칸과 「비교안 값」 칸을 나란히 둔다.

1. **범위 클래스를 2층 파일 맨 끝에 둔다** — `2-semantic.css` 맨 끝, 도입 때 만들어 둔 「비교안」 주석(§1.1 6번) 아래에
   비교안 이름의 클래스(예: `.draft-home-b`)를 둔다. 주석이 없으면 그 자리에 먼저 만든다. 그 안에서는 **2층 변수 덮어쓰기만** 한다 — 새 토큰 이름을
   만들지 않는다. 증감은 1층 원본 변수 기준으로 적는다([naming-taxonomy.md](naming-taxonomy.md) §2 「화면/섹션 단위로 토큰을
   비례 조정할 때」와 같은 방식, 같은 이유로 3층이 아니라 2층 파일에 둔다). 덮어쓸 중간 변수가 없으면(예: `--text-b1`이 1층을
   바로 가리킴) 지금과 값이 같은 중간 변수를 `:root`에 더한다 — 지금 화면의 값은 바뀌지 않는다.
2. **같은 견본을 두 번 그린다** — 페이지의 견본 묶음을 한 부품으로 묶고, 하나는 그대로(「지금 값」), 하나는 범위 클래스로
   감싸(「비교안 값」) 나란히 둔다. 계산값을 읽는 방식이라 비교안 칸에는 덮어쓴 값이 저절로 보인다. 비교안 화면도 같은
   범위 클래스로 감싼다.
3. **고른 뒤** — 고른 비교안의 덮어쓴 값을 2층 `:root`(필요하면 1층)로 옮기고 그 범위 블록을 지운다. 「비교안」 주석은 남겨 다음 비교 때 쓴다. 페이지는 「지금 값」
   하나로 돌아간다. 고르지 않은 비교안의 범위 블록은 그 비교안을 지울 때 같이 지운다(idea-to-mvp는 3단계
   `화면 대조 끝:` 때). 본 코드(본 화면·`src/components/`)에는 범위 클래스가 남지 않아야 한다.
