# 목업 캔버스 뼈대

화면을 한 판에 펼쳐 보는 **목업 캔버스**와, 토큰·부품을 실제 코드로 보여 주는 **디자인 시스템 페이지**의 코드 틀이다. 개발 서버에서만 열리고, 실서비스 빌드에서는 404다(내 컴퓨터에서만 켜는 예외는 아래 「실서비스 빌드로 빠르게 보기」).

목업 캔버스는 무한 캔버스(끝없이 넓은 판을 끌고 확대해 보는 화면)다.

- **열면 모든 화면이 한눈에 작게 펼쳐진다** — 화면은 왼쪽에서 오른쪽으로 흐름 순서, 한 화면의 기본 모양·상태(`?state=`)·비교안은 위에서 아래로 놓인다. 화면마다 데스크톱 창(1440)과 폰 창(390)이 한 쌍이다(휴대폰에서만 쓰는 화면은 목록 파일에 「폰 폭만」을 적어 폰 창만 띄운다 — 아래 「목록 파일」). 왼쪽 목록에서 흐름 묶음 하나만 고르거나 전체를 본다.
- **멀리서는 그림, 가까이서는 실제 화면** — 작게 보일 때는 미리 찍어 둔 그림(없으면 화면 이름 카드)을 보여 준다. 확대해서 창이 충분히 커지고 화면 안에 들어오면 그 창만 실제 화면(iframe — 페이지 안에 다른 페이지를 띄우는 창)으로 바뀐다. 실제 창은 한 번에 하나씩 차례로 불러오고, 동시에 떠 있는 수에 상한이 있고, 멀어지면 내린다. 개발 서버는 주소를 처음 열 때 그 화면을 만들기 때문에, 창 수십 개를 한꺼번에 띄우면 느려지거나 멈춘다 — 그래서 이렇게 나눈다.
- **키 안내는 접속한 운영체제의 키로만 보인다** — 캔버스가 브라우저에서 운영체제를 알아내, 맥이면 「⌘+C」「Option(⌥)+클릭」, 윈도우와 그 밖이면 「Ctrl+C」「Alt+클릭」으로 적는다.
- **크게 보기** — 창을 두 번 누르거나 창 이름 옆 「크게」를 누르면 그 화면 하나를 창 가득 실제 크기로 띄운다. 여기서는 화면을 굴리고 눌러 볼 수 있다. Esc로 돌아온다.
- **요소 복사** — 실제 화면의 요소에 마우스를 올리고 ⌘+C(맥)·Ctrl+C(윈도우)를 누르면 그 요소의 코드 자리(파일:줄)·부품 이름·HTML이 복사된다. Claude 대화창에 붙여 넣으면 어느 코드를 고칠지 바로 짚인다.
- **코멘트 핀** — 오른쪽 위 코멘트 묶음의 「코멘트 달기」 단추(단축키 C)를 켜고 화면을 클릭하면 그 자리에 메모 칸이 뜨고, 적으면 핀이 꽂힌다. 코멘트는 `mvp/canvas-comments.json`에 쌓이고, 대화창에 「코멘트 반영해줘」라고 하면 Claude가 열린 코멘트를 읽어 고친다.

## 파일

| 틀 파일 | 프로젝트에 넣는 자리 |
|---|---|
| `app/(dev)/layout.tsx.template` | `src/app/(dev)/layout.tsx` — 실서비스 빌드에서 `notFound()` |
| `app/(dev)/dev/dev-only.ts.template` | `src/app/(dev)/dev/dev-only.ts` — 개발용 라우트 핸들러의 문지기(실서비스 빌드에서 404) |
| `app/(dev)/dev/canvas/page.tsx.template` | `src/app/(dev)/dev/canvas/page.tsx` — 목업 캔버스 페이지 (`/dev/canvas`) |
| `app/(dev)/dev/canvas/canvas-board.tsx.template` | `src/app/(dev)/dev/canvas/canvas-board.tsx` — 무한 캔버스 화면 |
| `app/(dev)/dev/canvas/canvas-guide.tsx.template` | `src/app/(dev)/dev/canvas/canvas-guide.tsx` — 쓰는 법과 「코멘트 반영해줘」 복사 단추 |
| `app/(dev)/dev/canvas/frame-bridge.ts.template` | `src/app/(dev)/dev/canvas/frame-bridge.ts` — 창 안 문서에 거는 장치(코멘트·핀·Esc·휠) |
| `app/(dev)/dev/canvas/model.ts.template` | `src/app/(dev)/dev/canvas/model.ts` — 창 목록 펴기·창 크기·코멘트 모양 |
| `app/(dev)/dev/canvas/server-paths.ts.template` | `src/app/(dev)/dev/canvas/server-paths.ts` — 그림 폴더·코멘트 파일 자리 |
| `app/(dev)/dev/canvas/screens.ts.template` | `src/app/(dev)/dev/canvas/screens.ts` — 목록 파일의 손 부분(비교안·덮어쓰기·더할 화면) |
| `app/(dev)/dev/canvas/screens.generated.ts.template` | `src/app/(dev)/dev/canvas/screens.generated.ts` — 목록 파일의 자동 부분(`npm run canvas:list`가 다시 쓴다) |
| `app/(dev)/dev/canvas/frames/route.ts.template` | `src/app/(dev)/dev/canvas/frames/route.ts` — 창 목록 (`/dev/canvas/frames`, 그림 찍기 스크립트가 읽는다) |
| `app/(dev)/dev/canvas/shots/route.ts.template` | `src/app/(dev)/dev/canvas/shots/route.ts` — 찍어 둔 그림 목록 (`/dev/canvas/shots`) |
| `app/(dev)/dev/canvas/shots/[file]/route.ts.template` | `src/app/(dev)/dev/canvas/shots/[file]/route.ts` — 그림 한 장 (`/dev/canvas/shots/<창 열쇠>.jpg`) |
| `app/(dev)/dev/canvas/comments/route.ts.template` | `src/app/(dev)/dev/canvas/comments/route.ts` — 코멘트 읽기·쓰기 (`/dev/canvas/comments`) |
| `app/(dev)/dev/react-grab/route.ts.template` | `src/app/(dev)/dev/react-grab/route.ts` — 요소 복사 도구 스크립트 (`/dev/react-grab`) |
| `app/(dev)/dev/design-system/page.tsx.template` | `src/app/(dev)/dev/design-system/page.tsx` — 디자인 시스템 페이지 (`/dev/design-system`) |
| `lib/dev-state.ts.template` | `src/lib/dev-state.ts` — `?state=` 읽기 도우미 |
| `scripts/canvas-list.mjs.template` | `scripts/canvas-list.mjs` — 목록 만들기 스크립트 |
| `scripts/canvas-shots.mjs.template` | `scripts/canvas-shots.mjs` — 그림 찍기 스크립트 |
| `scripts/state-fill.mjs.template` | `scripts/state-fill.mjs` — 상태 표 채우기 스크립트 |

## 프로젝트에 넣는 차례

1. 위 표대로 파일을 같은 경로로 복사하면서 끝의 `.template`을 뗀다(`app/`·`lib/`는 `src/` 아래, `scripts/`는 프로젝트 맨 위).
2. **개발 의존성 둘을 깐다** — 요소 복사 도구 `react-grab`과 그림 찍기에 쓰는 브라우저 자동화 도구 `playwright`. 판을 고정해서 깐다(`npm install -D --save-exact react-grab playwright`). 확대·이동은 틀이 직접 구현해서 따로 깔 것이 없다.
3. **`package.json`에 목록 만들기·그림 찍기·상태 표 채우기 명령을 더한다**:

   ```json
   "scripts": {
     "canvas:list": "node scripts/canvas-list.mjs",
     "canvas:shots": "playwright install --only-shell chromium && node scripts/canvas-shots.mjs",
     "state:fill": "node scripts/state-fill.mjs"
   }
   ```

   `canvas:shots`의 앞 절반은 그림을 찍을 브라우저(크로미움)를 받는 명령이다. 이 브라우저는 프로젝트 폴더가 아니라 **컴퓨터의 공용 자리에 한 벌만 깔리고, 이 컴퓨터의 프로젝트끼리 같이 쓴다**(맥 `~/Library/Caches/ms-playwright`, 윈도우 `%USERPROFILE%\AppData\Local\ms-playwright`, 리눅스 `~/.cache/ms-playwright`). 그래서 이 컴퓨터에서 처음 돌릴 때만 내려받고, 그 뒤엔 다른 프로젝트에서도 이미 있다고 보고 바로 넘어간다. 프로젝트마다 깐 `playwright` 판이 다르면 그 판에 맞는 브라우저를 한 벌 더 받는다.
4. **`.gitignore`에 그림 폴더를 더한다** — 그림은 컴퓨터마다 다시 찍는 것이라 올리지 않는다. 코멘트 파일(`mvp/canvas-comments.json`)은 올린다 — 사람이 남긴 수정 요청 기록이다.

   ```
   # 목업 캔버스 미리보기 그림 (npm run canvas:shots)
   /.canvas-shots/
   # 2-3 비교안 자기 점검이 남기는 임시 결과
   /.draft-checks/
   ```

5. **루트 레이아웃에 요소 복사 도구를 싣는다** — `src/app/layout.tsx`의 `<html>` 안에 `<head>`를 두고(이미 있으면 그 안에) 아래 줄을 넣는다. 개발 서버에서만 실린다.

   ```tsx
   import Script from "next/script"
   // …
   <html lang="ko">
     <head>
       {/* 요소 복사 도구(React Grab) — 개발 서버에서만 싣는다. 요소에 마우스를 올리고 ⌘+C·Ctrl+C를 누르면 코드 자리가 복사된다. */}
       {process.env.NODE_ENV === "development" && (
         <Script src="/dev/react-grab" strategy="beforeInteractive" data-options='{"telemetry":false}' />
       )}
     </head>
     <body>…</body>
   </html>
   ```

   React Grab 공식 안내(Next.js App Router)와 같은 방식이다 — 다만 스크립트를 바깥 주소(CDN)에서 받지 않고, 2번에서 깐 판을 개발용 주소 `/dev/react-grab`이 내보낸다. `data-options`의 `telemetry: false`는 도구가 켜질 때 제작사 서버로 판 번호를 묻는 요청을 끈다. 본 코드에서 개발용 묶음을 불러오는 것이 아니라 주소 하나를 적는 것이라, 실서비스 빌드에는 이 줄째로 빠진다.
6. `{{…}}`를 채운다 — 디자인 시스템 페이지의 서비스 이름, 글자 단계·색 역할·간격·둥글기 목록(프로젝트의 2층 이름으로), 프로젝트에 없는 부품 import 지우기. 「브랜드」 영역의 `{{…}}`(로고·브랜드 색 면·제목 서체·사진 톤)는 비워 둔다 — idea-to-mvp 2-3 개성 입히기가 채우고, 그 전에는 「아직 없음」 한 줄만 보인다.
7. **`<main>`을 셸에 맞춘다** — 틀 페이지의 맨 바깥은 `<div>`다. 셸(루트 레이아웃)이 본문 영역에 `<main>`을 두는 구조가 기본이라서다. 프로젝트 셸이 `<main>`을 두지 않고 화면마다 두는 구조면 두 틀 페이지의 맨 바깥 `<div>`를 `<main>`으로 바꾼다 — 한 페이지에 `<main>`은 하나다(design-system `layout-frames.md` §2.2). 목업 캔버스는 창 전체를 덮는 층이라 셸의 헤더·푸터는 그 뒤에 가려진다.
8. **`next.config.ts`에 `env` 한 줄을 더한다** — `MOCKUP_CANVAS` 값을 빌드 때 브라우저 코드에도 넣어 두는 줄이다(아래 「실서비스 빌드로 빠르게 보기」). 이미 `env`가 있으면 그 안에 항목만 더한다.

   ```ts
   const nextConfig: NextConfig = {
     // 목업 캔버스 흉내 스위치 — 빌드할 때의 MOCKUP_CANVAS 값을 서버·브라우저 코드에 글자 그대로 넣는다(없으면 빈 글자).
     // .env 파일·Vercel 환경변수에는 넣지 않는다 — 넣으면 공개 주소에서 목업 캔버스가 열린다.
     env: {
       MOCKUP_CANVAS: process.env.MOCKUP_CANVAS ?? "",
     },
   }
   ```

9. **2층 파일 맨 끝에 「비교안」 블록 자리를 만들어 둔다** — `src/styles/2-semantic.css` 맨 끝에 주석 한 줄만 두고 비워 둔다. 화면 개선 단계가 이 아래에 비교안 범위 클래스를 넣는다. 모양은 design-system `bootstrap-project.md` §1.1 6번.
10. 목록 파일은 손으로 적지 않는다 — 화면 목록(`mvp/feature-list.md` 6절)의 「주소」 칸을 채운 뒤 `npm run canvas:list`를 돌린다. 화면이 아직 없으면 자동 부분은 빈 목록 그대로 둔다. 자세한 것은 아래 「목록 파일」.
11. 저장·조회 코드(서버 컴포넌트·서버 함수, 또는 브라우저에서 데이터를 읽는 코드)에서 `readDevState`를 불러 빈 결과·느린 응답·오류·권한없음을 흉내 낸다. 지금 로그인한 사람을 읽는 함수는 `readDevGuest`를 먼저 보고, 참이면 「로그인 전」으로 답한다(아래 「목록 파일」의 `?as=guest`). 부르는 예는 `dev-state.ts` 맨 위 주석에 있다. 브라우저에서 도는 코드는 페이지 `searchParams`가 없으니 주소에서 직접 만든다 — `const state = await readDevState(Object.fromEntries(new URLSearchParams(location.search)))`. `readDevGuest`도 같은 식으로 부른다.
12. 빌드·린트·타입 검사를 돌린다 (`npm run build`, `npm run lint`, `npx tsc --noEmit`).
13. 실서비스 모드(`npm run build` 뒤 `npm run start`)에서 개발용 주소가 전부 404인지 `curl -s -o /dev/null -w "%{http_code}" <주소>`로 확인한다 — 페이지(`/dev/canvas`·`/dev/design-system`)와 라우트 핸들러(`/dev/canvas/comments`·`/dev/canvas/frames`·`/dev/canvas/shots`·`/dev/react-grab`) 모두. 배포한 뒤에는 공개 주소로도 같은 확인을 한다.

## 목록 파일

캔버스에 띄울 화면 목록은 두 파일로 나뉜다. 캔버스는 둘을 합친 `screens.ts`의 `SCREENS`를 읽는다.

| 파일 | 누가 쓰나 | 무엇이 들어가나 |
|---|---|---|
| `screens.generated.ts` (자동 부분) | `npm run canvas:list`가 돌릴 때마다 통째로 다시 쓴다. 손으로 고치지 않는다 | 화면 목록에서 읽은 화면 — ID·이름·흐름 묶음·주소·상태 |
| `screens.ts` (손 부분) | 사람(또는 AI)이 고친다. 스크립트는 건드리지 않는다 | 자동 화면 위에 덮어쓸 값(`SCREEN_OVERRIDES`), 화면 목록에 없는 화면(`EXTRA_SCREENS`), 화면 한 개의 모양(`CanvasScreen`) |

**목록 만들기** — 프로젝트 맨 위에서 `npm run canvas:list`. `mvp/feature-list.md`를 이렇게 읽는다:

- **6절 화면 목록 표** — 칸은 번호가 아니라 머리줄의 칸 이름으로 찾는다. 「ID」·「화면 이름」·「MVP 포함」·「주소」 칸은 꼭 있어야 하고, 「흐름 묶음」·「역할」 칸은 있으면 쓴다.
  - `MVP 포함`이 `O`로 시작하고 주소가 있는 행만 올린다. 주소가 빈 화면은 빼고 끝에 그 ID를 알려 준다.
  - 주소는 칸 안 `` `…` `` 속 첫 낱말이다(뒤에 붙은 괄호 설명은 버린다).
  - 주소 칸에 쿼리(`?` 뒤에 붙는 값)가 들어 있어도 그대로 올린다(예: `/login?next=/posts`).
  - 「역할」 칸이 「비로그인 방문자」인 행은 주소 끝에 `?as=guest`가 저절로 붙는다(주소에 이미 `?`가 있으면 `&as=guest`, 이미 `as=`가 있으면 그대로). 목업 캔버스의 창들은 같은 주소라 브라우저 저장소(가짜 로그인 상태 포함)를 같이 쓴다. 그래서 「로그인 전」 모습은 저장소를 바꾸지 않고 주소로 흉내 낸다 — 상태 표시 도우미(`src/lib/dev-state.ts`)의 `readDevGuest()`가 개발 서버에서만 주소 끝 `?as=guest`를 읽어 돌려주고, 저장·조회 코드에서 지금 로그인한 사람을 읽는 함수가 이 값을 먼저 봐서 참이면 「로그인 전」으로 답한다.
  - 흐름 묶음은 「흐름 묶음」 칸에서 온다. 이름은 「역할: 흐름」 꼴이다(예: 「소비자: 찾아보기에서 참가 신청까지」). 칸이 없거나 비면 「역할」 칸 값으로 「<역할>: 흐름 미정」을 만들어 묶는다 — 바꾸려면 `SCREEN_OVERRIDES`에 `group`을 적는다.
  - 순서는 표의 행 순서다. 캔버스는 같은 흐름 묶음끼리 이 순서대로 왼쪽→오른쪽에 놓는다.
- **7절 상태 표** — 첫 칸이 화면 ID로 시작하는 행에서, 칸마다 끝 괄호에 적힌 `?state=` 값(`empty`·`loading`·`error`·`forbidden`)을 모아 그 화면의 `states`로 쓴다.
- **상태 표 칸 채우기** — 7절의 `?state=` 값을 손으로 적으면 화면이 많은 표에서 칸이 한 칸씩 밀리기 쉽다. 그래서 「화면 ID와 상태 값」만 한 줄씩 적은 파일을 만들어 `npm run state:fill -- 상태값.txt`를 돌린다. 스크립트가 머리줄의 칸 이름(빈 상태·로딩·오류·권한없음)으로 칸을 찾아 `O` 칸 끝에 `(?state=…)`를 붙인다.
  - 입력 파일은 한 줄에 화면 하나다: `S-01 empty loading`, `S-02: error forbidden`. `#`로 시작하는 줄은 건너뛴다.
  - `해당없음`이나 `O*` 칸에는 적지 않고 알려 준다. 이미 값이 있는 칸은 건너뛰니 여러 번 돌려도 된다.
  - `npm run state:fill -- --check`는 아무것도 쓰지 않고 점검만 한다 — `O`인데 값이 없는 칸, 값이 있는데 `O`가 아닌 칸을 알려 준다.
  - 손으로 고칠 때는 머리줄에서 칸 이름을 먼저 짚고, 그 이름의 세로줄에서 화면 행을 찾는다. 앞에서부터 `|`를 세지 않는다.
- **화면 목록이나 상태 표를 고칠 때마다 다시 돌린다.** 자동 부분의 화면 ID·주소·상태가 바뀌어도 손 부분은 화면 ID로 붙으니 그대로 따라간다.

**손 부분에 적는 모양** (`screens.ts`):

```ts
export const SCREEN_OVERRIDES = {
  // 비교안 — 화면 개선 단계에서만 붙인다
  "S-02": {
    drafts: [
      { label: "A판", path: "/dev/drafts/posts-a", states: ["empty", "loading"] },
      { label: "B판", path: "/dev/drafts/posts-b", states: ["empty"] },
    ],
  },
  // 화면 목록과 다른 주소·묶음으로 띄울 때
  "S-05": { path: "/login?next=/posts/1", group: "처음 온 사람: 둘러보기에서 가입까지" },
  // 휴대폰에서만 쓰는 화면 — 폰 창만 띄울 때
  "S-07": { widths: ["phone"] },
  // 캔버스에서 뺄 때
  "S-09": { skip: true },
}

export const EXTRA_SCREENS: CanvasScreen[] = [
  // 화면 목록에 없는 화면 — 자동 화면 뒤에 붙는다
  { id: "S-90", name: "운영 대시보드", group: "운영자: 대시보드 보기", path: "/admin", states: ["empty"] },
]
```

- **덮어쓰기** — 적은 필드만 자동 값을 바꾸고, 안 적은 필드는 자동 값 그대로다. `states`를 적으면 자동 상태 목록을 통째로 바꾼다.
- **`states`** — `"empty"`·`"loading"`·`"error"`·`"forbidden"` 중 그 화면이 가진 상태. 기본 모양 아래에 상태마다 창이 한 쌍(데스크톱·폰)씩 더 놓인다.
- **`widths`(폰 폭만)** — 안 적으면 화면마다 데스크톱 창과 폰 창이 한 쌍이다. 휴대폰에서만 쓰는 화면(예: 폰으로 사진을 찍어 올리는 화면)은 `widths: ["phone"]`을 적는다. 그러면 그 화면의 기본 모양·상태·비교안 모두 데스크톱 창 없이 폰 창만 놓이고, 캔버스 자리도 폰 창 폭만큼 좁아진다. 그림 찍기 스크립트도 창 목록을 그대로 받아 폰 그림만 찍는다. 크게 보기의 「데스크톱」 단추는 눌리지 않는다.
- **`drafts`** — 원래 화면 아래에 판마다 줄을 지어 놓인다. 판마다 원래 모양 한 쌍과 상태 창이 뜬다. 2단계 화면은 상태 표에 아직 `?state=` 값이 없어(상태 화면은 3단계가 만든다) 원래 화면의 `states`가 비어 있다. 그래서 비교안 `drafts`에는 보고 싶은 상태(`empty`·`loading`)를 판마다 적는다. 안 적으면 원래 화면과 같다 — 2단계에서는 대개 상태 창이 없다는 뜻이다.
- **고른 뒤** — 고른 판이 본 화면 자리로 옮겨 가면 그 화면의 `drafts`에서 고른 판을 지운다. 고르지 않은 판은 비교안을 지울 때 같이 지운다.
- 캔버스는 `SCREENS`를 창 목록(화면 × 폭 × 상태 × 판)으로 펴서 쓴다(`model.ts`의 `buildFrames` — 폭은 `widths`에 적은 것만). 창마다 열쇠(예: `S-02__main__desktop__empty`)가 붙고, 그림 파일 이름이 이 열쇠다.

## 캔버스 쓰는 법

캔버스 왼쪽 「쓰는 법」이 기능별 묶음으로 같은 내용을 보여 준다(`canvas-guide.tsx`). 처음에는 「코멘트로 고치기」만 펼쳐져 있고, 키는 접속한 운영체제의 것만 키 모양 칩으로 보인다. 고치는 흐름 둘은 「캔버스에서 → Claude Code에서」로 이어진다:

- **코멘트로 고치기** — ① 「코멘트 달기」(C)를 켜고 화면을 클릭(작은 그림이면 크게 열림) ② 메모를 적고 핀 꽂기, 여러 개 모아 둬도 됨 ③ Claude Code 대화창에 「코멘트 반영해줘」 — 문구 옆 「복사」 단추가 클립보드에 넣고 「복사됨」을 알린다 ④ 다 고쳐지면 캔버스를 새로 고침 → 끝난 핀은 목록에서 빠지고, 「끝난 것도 보기」로 처리 메모를 본다. 코멘트는 파일에 저장되니 내용을 복사해 붙일 필요가 없다.
- **바로 말로 고치기(요소 복사)** — ① 확대하거나 크게 보기로 실제 화면을 띄우고 요소에 마우스 ② ⌘+C(맥)·Ctrl+C(윈도우) ③ Claude Code 대화창에 붙여 넣고 「이거 ~하게 고쳐줘」.
- 오른쪽 코멘트 목록 위에는 열린 코멘트가 있으면 열린 코멘트 수와 「Claude Code에 이렇게 말하면 모두 고칩니다」, 같은 복사 단추가, 없으면 남기는 차례가 뜬다.

| 하고 싶은 것 | 하는 법 |
|---|---|
| 판 옮기기 | 빈 곳(또는 그림)을 끌기, Space를 누른 채 끌기(실제 화면 위에서도) |
| 확대/축소 | 휠(오른쪽 아래 「휠」 설정이 「확대」일 때 — 기본값), 트랙패드 두 손가락 벌리기·모으기, ⌘+휠(맥)·Ctrl+휠(윈도우), 오른쪽 아래 −·+ 단추 |
| 휠 동작 바꾸기 | 오른쪽 아래 보기 막대의 「휠: 확대 / 이동」. 「이동」이면 휠·트랙패드 두 손가락 끌기가 판을 옮긴다. 고른 값은 브라우저에 기억된다 |
| 전체 다시 보기 | 오른쪽 아래 「화면에 맞추기」, 또는 왼쪽 목록에서 페이지 다시 고르기 |
| 화면 하나 크게 | 창을 두 번 누르기, 또는 창 이름 옆 「크게」. 데스크톱·폰 바꾸기, 새 탭에서 열기도 여기서. Esc로 돌아온다 |
| 요소 복사 | 실제 화면(확대했거나 크게 보기)의 요소에 마우스를 올리고 ⌘+C(맥)·Ctrl+C(윈도우) → 대화창에 붙여 넣기 |
| 코멘트 남기기 | 오른쪽 위 「코멘트 달기」 단추를 켠다(단축키 C) → 마우스가 십자 모양이 된다 → 화면을 클릭 → 메모를 적고 「핀 꽂기」(⌘+Enter·Ctrl+Enter). 작은 그림을 클릭하면 그 화면이 크게 보기로 열리고 「찍을 자리를 클릭하세요」가 뜬다. 끄려면 C 또는 Esc. 지름길: Option(⌥)+클릭(맥)·Alt+클릭(윈도우) |
| 코멘트 보기·완료 표시 | 오른쪽 위 「코멘트 보기」(옆 동그라미 숫자가 열린 코멘트 수), 또는 화면 위 핀 누르기 |

- 폰 창에서는 앱바 모양이 화면 목록 8절과 맞는지 본다 — 탭 화면은 탭 이름, 쌓이는 화면은 뒤로·제목(셸 틀 `.claude/templates/app-shell/` 「세 모양」).
- 캔버스 위 실제 창에서는 휠이 화면 안을 굴리지 않고 캔버스를 움직인다. 화면을 아래로 굴려 보려면 크게 보기로 연다.
- 휠 동작은 사람이 고른다. 브라우저는 마우스 휠과 트랙패드 두 손가락 끌기를 같은 이벤트로 보내 둘을 확실히 가를 수 없어서다. 트랙패드 벌리기·모으기(브라우저가 Ctrl을 붙여 보낸다)는 어느 설정이든 확대다. 설정은 브라우저 저장소에 적고, 저장소를 못 쓰는 브라우저면 그 탭에서만 기억한다.
- 조작은 기능 묶음 둘로 모았다 — **보기 묶음**(오른쪽 아래 막대: 휠 설정 · 축소 · 배율 · 확대 · 화면에 맞추기)과 **코멘트 묶음**(오른쪽 위: 코멘트 달기 · 코멘트 보기). 묶음 안은 붙이고 묶음 사이는 떨어뜨린다. 왼쪽 아래 모서리는 Next.js 개발 표시(둥근 N 단추)가 뜨는 자리라 비워 둔다.
- 개수 표시(흐름 묶음의 화면 수, 코멘트 수)는 모두 동그라미 안 숫자 배지다. 두 자리 이상이면 알약형으로 늘어나고, 이름이 길어 줄이 바뀌어도 이름 끝 낱말에 붙어 다닌다. 화면 읽기 프로그램에는 「화면 4개」처럼 읽힌다. 「코멘트 달기」 단추에는 단축키를 적지 않고 마우스를 올리면 뜨는 설명과 쓰는 법의 키 표로 알린다.
- 창 위 이름표는 위에서부터 흐름 묶음 → 화면 ID·이름 → 창 이름(폭·상태)과 「크게」 차례로 쌓인다. 창 이름 줄은 줄 사이가 충분히 벌어질 만큼 확대했을 때만 보인다.

## 그림 찍기

캔버스가 멀리서 보여 줄 미리보기 그림을 찍는다. 개발 서버를 띄워 둔 채 프로젝트 맨 위에서:

```bash
npm run canvas:shots                           # http://localhost:3000 의 모든 창
npm run canvas:shots -- http://localhost:3001  # 서버 주소가 다르면
npm run canvas:shots -- S-02 S-05              # 그 화면만 다시 찍기
```

- 스크립트는 서버의 `/dev/canvas/frames`에서 창 목록을 받아, 창마다 그 폭으로 화면을 열어 절반 크기 JPEG로 찍어 `.canvas-shots/<창 열쇠>.jpg`에 둔다. 전체를 찍을 때는 목록에서 빠진 창의 옛 그림을 지운다. 캔버스는 열 때 그림 목록을 받으니, 찍은 뒤 캔버스를 새로 고치면 바뀐 그림이 보인다.
- 동시에 두 창씩 연다. 개발 서버는 주소를 처음 열 때 그 화면을 만들어서 처음 한 번은 오래 걸린다(화면 30개·창 200여 개에 몇 분). 처음 여는 화면이 많을 때(창이 백 개를 넘는 규모)는 아래 「실서비스 빌드로 빠르게 보기」로 띄운 서버에 대고 찍는 쪽이 빠르다. 창이 수십 개면 개발 서버로도 충분하다.
- 그림에는 개발 도구 표시(Next.js 개발 표시·요소 복사 도구)가 들어가지 않게 숨기고 찍는다. 로딩 상태(`?state=loading`)는 뼈대가 보이는 동안 찍는다.
- 화면에 `data-map-ready` 표시가 달린 요소(견본 지도 틀 `.claude/templates/sample-map/`의 지도 영역)가 있으면, 그 값이 `"1"`(지도가 다 그려짐)이 될 때까지 최대 15초 기다렸다 찍는다. 지도 영역이 없는 화면은 지금과 같다. 15초 안에 안 그려지면 경고를 내고 그대로 찍는다 — 빈 지도가 찍힐 수 있다.
- 늦게 그려지는 화면(3D 장면·게임판 등)은 첫 그림을 그리면 `data-view-ready="1"`을 낸다(지도의 `data-map-ready`와 같은 방식). 스크립트는 이 표시가 있는 화면에서 `"1"`이 될 때까지 최대 30초 기다렸다 찍고, 안 그려지면 경고를 내고 그대로 찍는다. `data-map-ready`도 그대로 된다.
- **3D 화면이 있으면** 스크립트가 크로미움을 `--use-angle=swiftshader`(그래픽 카드 없이 소프트웨어로 WebGL을 그리는 방식)로 띄운다. 이게 없으면 헤드리스 브라우저에서 3D가 빈 화면으로 찍힌다. 3D 화면이 없는 프로젝트는 `CANVAS_GL=0 npm run canvas:shots`로 끄거나 스크립트의 `BROWSER_ARGS`를 비운다.
- **캔버스의 그림 귀퉁이에 「찍은 때: 10-21 14:32」가 작게 붙는다.** 그림은 찍은 순간의 화면이라, 그 뒤에 화면을 고쳤다면 낡았을 수 있다 — 사람이 알아보라는 표시다. 낡았다 싶으면 그 화면만 다시 찍는다.
- **이 그림은 사람이 캔버스를 훑을 때 쓰는 미리보기다.** AI가 화면이 맞는지 판정하는 수단이 아니다 — AI는 이 그림을 보고 「화면 확인 완료」라고 결론 내지 않는다. 화면 판정은 사람 몫이다.
- 그림은 개발용 라우트(`/dev/canvas/shots`)로만 내보낸다. 실서비스 빌드에서는 404다.
- 화면을 고친 뒤에는 고친 화면만 다시 찍는다(`-- S-02`). 그림이 낡아도 확대하면 실제 화면이 뜨니, 매번 찍지 않아도 된다.

## 요소 복사 (React Grab)

[React Grab](https://github.com/aidenybai/react-grab)(MIT 라이선스)이 한다. 요소에 마우스를 올리고 ⌘+C(맥)·Ctrl+C(윈도우)를 누르면 이런 글이 복사된다:

```
[<a class="…" href="/posts/1">첫 글</a> in PostRow (at src/components/post-row.tsx:48:11) in PostListScreen (at src/app/posts/post-list-screen.tsx:71:26)]
```

- **어디서 되나** — 개발 서버의 모든 화면, 캔버스 위 실제 창, 크게 보기 창. 그림(멀리서 보이는 미리보기)은 사진이라 안 된다 — 확대해 실제 창이 뜬 뒤에 쓴다. 실제 창에 마우스를 올리면 캔버스가 그 창에 키보드 초점을 넘겨 ⌘+C·Ctrl+C가 창 안으로 간다.
- **캔버스 페이지 자신에서는 끈다** — 캔버스가 열릴 때 캔버스 쪽 도구를 내린다. 캔버스 쪽 도구가 떠 있으면 창 안의 도구가 제 것을 띄우지 않고 캔버스 쪽 것을 빌려 쓰는데, 그러면 창 안 요소의 파일:줄을 엉뚱한 곳(프레임워크 내부 파일)으로 짚는다. 창마다 제 도구가 떠야 맞게 짚는다.
- **파일:줄이 나오지 않는 요소** — 서버 컴포넌트(서버에서만 그리는 부품)가 직접 그린 요소는 부품 이름만 나오거나 가장 가까운 브라우저 쪽 부품의 자리가 나온다. 리액트가 서버 컴포넌트의 코드 자리를 브라우저에 넘기지 않아서다. 이때는 복사된 HTML과 부품 이름으로 찾는다.
- **실서비스 빌드에서는 안 된다** — `MOCKUP_CANVAS=1`로 띄운 실서비스 빌드 캔버스에도 싣지 않는다. 파일:줄은 리액트 개발 빌드에만 있는 정보라, 실서비스 빌드에서는 실어도 파일:줄을 못 준다. 요소 복사가 필요하면 개발 서버(`npm run dev`)로 본다.
- 도구는 처음 켜질 때 화면 구석에 자기 도구 막대를 띄우고, 그 막대의 글꼴을 바깥 글꼴 서비스에서 받는다. 개발 서버에서만 생기는 요청이다.

## 코멘트 핀

- **남기기** — 오른쪽 위 「코멘트 달기」 단추(단축키 C)로 코멘트 모드를 켜고 화면(캔버스 위 실제 창, 크게 보기 창)을 클릭한다. 작은 그림을 클릭하면 그 화면이 크게 보기로 열리니 거기서 찍을 자리를 클릭한다. 코멘트 모드에서는 화면의 원래 동작(링크 이동·메뉴 열기)보다 먼저 가로채서 그 자리에 메모 칸이 뜬다. 지름길로 코멘트 모드 없이 Option(⌥)+클릭(맥)·Alt+클릭(윈도우)도 된다. 적고 「핀 꽂기」를 누르면 개발용 라우트 `/dev/canvas/comments`가 `mvp/canvas-comments.json`에 한 건을 더한다.
- **다시 보기** — 같은 주소·같은 폭의 창을 다시 띄우면 핀이 다시 꽂힌다. 핀은 요소를 다시 찾아(선택자와 글자 앞부분) 그 요소 위에 놓고, 못 찾으면 남길 때의 화면 안 위치에 놓는다. 창 안에서 링크를 눌러 다른 화면으로 옮겨 가면 그 화면의 핀만 보인다.
- **목록** — 오른쪽 위 「코멘트 보기」를 누르면 목록이 열린다(옆 숫자가 열린 코멘트 수). 핀을 누르면 그 코멘트가 목록에서 짚인다. 「캔버스에서 찾기」·「크게」로 그 화면에 가고, 「완료 표시」로 닫는다. 그림 위 창 이름 옆에는 그 창의 열린 코멘트 수가 붙는다.
- **한 건의 모양** (`model.ts`의 `CanvasComment`):

  ```json
  {
    "id": "c-mvemp9tp-2ju8",
    "screenId": "S-02",
    "screenName": "글 목록",
    "draft": null,
    "url": "/posts?state=empty",
    "viewport": "desktop",
    "state": "empty",
    "target": {
      "selector": "main > h1",
      "text": "글 목록",
      "source": "src/app/posts/post-list-screen.tsx:41",
      "component": "PostListScreen"
    },
    "position": { "x": 800, "y": 106, "rx": 0.5, "ry": 0.48 },
    "comment": "제목이 너무 커요",
    "status": "open",
    "resolution": "",
    "createdAt": "2026-01-01T00:00:00.000Z",
    "resolvedAt": null
  }
  ```

  - `target`은 요소를 다시 찾을 단서다. `source`·`component`는 개발 서버에서 요소 복사 도구가 알려 줄 때만 채워진다(실서비스 빌드 캔버스에서는 `null`).
  - `position`의 `x`·`y`는 화면 문서 왼쪽 위에서 잰 거리, `rx`·`ry`는 요소 상자 안의 비율(0~1)이다.
  - `status`는 `open`·`done`. 고친 쪽이 `done`으로 바꾸고 `resolution`에 무엇을 고쳤는지 적는다.
- **라우트** — `GET /dev/canvas/comments`(전부), `POST`(한 건 더하기 — `id`·`status`·`createdAt`은 라우트가 붙인다), `PATCH { id, status?, resolution? }`(상태·처리 메모 고치기). Claude는 파일을 직접 고쳐도 된다 — 개발 서버가 요청마다 파일을 새로 읽는다.
- 「코멘트 반영해줘」를 들었을 때 Claude가 하는 차례는 idea-to-mvp `2-1-mockup.md` §2.7 「코멘트 반영」이 정한다.

## 실서비스 빌드로 빠르게 보기

개발 서버(`npm run dev`)는 주소를 처음 열 때마다 그 화면을 새로 만들어서, 처음 확대해 실제 창이 뜰 때 느리다. 내 컴퓨터에서 빠르게 훑어보고 싶으면 실서비스 빌드를 띄우되, 빌드 명령 앞에 `MOCKUP_CANVAS=1`을 붙인다.

```bash
MOCKUP_CANVAS=1 npm run build && npm run start
```

- 열림과 `?state=` 흉내는 둘 다 **빌드 때** 정해진다 — 빌드 명령에 꼭 붙인다. 실행 명령에는 붙이지 않아도 되고, 붙여도 바뀌는 것이 없다.
- **`?state=` 흉내가 브라우저 쪽에서도 켜지려면 `next.config.ts`의 `env` 줄이 있어야 한다** (「프로젝트에 넣는 차례」 8번). 데이터를 브라우저에서 읽는 화면은 `readDevState`도 브라우저에서 도는데, 브라우저 코드는 서버 환경변수를 못 읽는다. `env` 줄이 빌드 때 값을 코드에 글자 그대로 넣어 두어 서버와 브라우저가 같은 조건으로 켜진다. Next.js 문서 `next.config.js` 옵션 `env`가 이 동작을 정한다 — 빌드 때 `process.env.MOCKUP_CANVAS`를 값으로 바꿔 넣는다(그래서 `process.env`를 구조 분해하면 안 바뀐다).
- 이렇게 띄운 캔버스에서도 그림·코멘트 핀은 그대로 쓴다. **요소 복사만 안 된다** (「요소 복사」).
- 다 본 뒤 평소처럼 `npm run build`를 다시 하면 막힌 빌드로 돌아간다.
- **이 서버가 떠 있는 동안은 다른 빌드를 돌리지 않는다** — 빌드가 이 서버가 읽고 있는 빌드 결과물(`.next`)을 덮어써, 사람이 보던 캔버스가 깨지거나 404로 바뀐다. AI는 떠 있는 서버가 `next start`면 그 서버를 개발 서버로 쓰지 않고, 빌드도 사람에게 그 서버를 꺼도 되는지 물은 뒤에 돌린다(`AGENTS.md` 검증 절 「공용 dev 서버를 죽이지 마라」).
- **이 변수는 Vercel 환경변수에 절대 넣지 않는다** — 넣으면 공개 주소에서 목업 캔버스와 코멘트 라우트가 열린다. `.env`·`.env.local` 같은 파일에도 적지 않는다(빌드가 그 파일을 읽어 모르는 사이에 열린다). 명령 앞에 붙여 그 한 번만 쓴다.

## 동작 메모

- 실서비스 막기는 두 겹이다. 페이지는 `(dev)/layout.tsx`가 `process.env.NODE_ENV === "production"`이고 `MOCKUP_CANVAS`가 `1`이 아닐 때 `notFound()`를 부른다. **라우트 핸들러(`route.ts`)에는 레이아웃이 듣지 않으므로** 핸들러마다 맨 앞에서 `dev-only.ts`의 `devOnly()`를 불러 같은 조건에서 404를 돌려준다. 새 개발용 라우트 핸들러를 더하면 이 줄을 꼭 넣는다. `next.config.ts`의 `env`가 값을 빌드 때 코드에 넣어 두므로, 열릴지 막힐지는 **빌드 때** 정해진다 — 실행(`next start`) 때만 변수를 붙이면 그대로 404고, 붙여 빌드했으면 실행 때 변수가 없어도 열린다.
- `(dev)`는 라우트 그룹(주소에는 안 나타나고 폴더만 묶는 이름)이다. 비교안 폴더(`src/app/(dev)/dev/drafts/`)도 같은 그룹 아래라 같이 막힌다.
- 루트 레이아웃(헤더·푸터)이 이 페이지들도 감싼다. 창(iframe) 안의 화면도 같은 레이아웃을 쓰니 실제 화면과 똑같이 보인다. 목업 캔버스는 그 위를 창 전체 크기 층으로 덮는다.
- 창은 실제 크기(데스크톱 1440×900, 폰 390×844)로 놓고 판 전체를 줄이고 늘린다. 그래서 창 안의 컨테이너 쿼리가 실제 폭 기준으로 돈다. 크기는 `model.ts`의 `VIEWPORTS`, 실제 창 상한·실제 창으로 바뀌는 배율은 `canvas-board.tsx` 맨 위 상수(`MAX_LIVE` 4, `LIVE_MIN_SCALE` 0.3)다.
- 캔버스는 같은 주소(같은 출처)의 창 문서에 이벤트를 걸고 핀을 꽂는다(`frame-bridge.ts`). 화면 코드는 고치지 않는다. 핀은 창 문서 맨 끝에 따로 붙인 상자 안에 그리고, 색은 앱의 2층 이름(`var(--foreground)` 등)으로 칠한다.
- 그림 폴더(`.canvas-shots/`)와 코멘트 파일(`mvp/canvas-comments.json`)의 자리는 `server-paths.ts`가 정한다 — 둘 다 개발 서버를 띄운 폴더(프로젝트 맨 위) 기준이다.
- `?state=`는 주소로만 정한다(브라우저 저장소에 쓰지 않는다). 한 창이 다른 창의 상태를 바꾸지 않게 하려는 것이다.
- 창(iframe)들은 같은 주소라 브라우저 저장소를 같이 쓴다 — 한 창에서 가짜 로그인·데이터를 바꾸면 다른 창에도 바로 보인다. 그래서 로그인 전 모습은 저장소를 바꾸지 않고 `?as=guest`로 띄운다.
- 루트 `tsconfig.json`의 `include`가 `**/*.tsx`라도 이 틀의 끝 이름은 `.tsx.template`이라 `.claude/templates/` 안에서는 검사에 걸리지 않는다.

## 지켜야 할 것

- **이 틀의 코드도 디자인 규칙 검사를 통과한다** — 캔버스 껍데기는 프로젝트 디자인과 상관없는 개발 도구지만 `src/app` 안에 있어 3단계 배포 전 검사의 디자인 규칙 검사(`3-frontend-build.md` §2.5 검사 ①)가 훑는다. 예외 줄을 따로 두지 않고 규칙을 지켜 통과시킨다:
  - 색은 shadcn 기본 이름(`bg-background`·`bg-muted`·`text-muted-foreground`·`border-border`·`bg-foreground` 등)만 쓴다 — 어느 프로젝트의 2층에도 있는 이름이라 프로젝트 디자인과 섞이지 않는다. 강조색(`primary`)은 쓰지 않는다.
  - 글자·둥글기·움직임은 하네스 기본 이름(`text-h3`·`text-b2`·`rounded-card`·`rounded-control`·`duration-base`·`ease-standard`)만 쓴다. 간격은 `1`·`2`·`3`·`4`·`6`·`8`·`12` 단계만 쓴다.
  - hex(`#…`)·`rgb(`·`oklch(`·`px` 글자·대괄호 임의 값(`w-[…]`)·숫자 길이(`duration-300`)·뷰포트 접두어(`md:` 등)를 쓰지 않는다.
  - 창 크기·판 위치처럼 계산으로 나오는 크기는 숫자 속성(`width={1440}`)과 숫자 스타일(`style={{ left: x }}`)로, 판 확대는 `matrix(…)` 변환으로 적는다 — 단위 글자가 코드에 나오지 않는다. 창 문서에 꽂는 핀은 `rem` 단위와 `var(--…)` 2층 이름으로 칠한다.
  - 프로젝트가 위 이름 중 하나를 없앴으면 그 줄만 프로젝트 2층의 가까운 이름으로 바꾼다.
- 색·크기 값은 코드에 적지 않는다. 디자인 시스템 페이지는 브라우저가 계산한 값을 읽어 보여 준다.
- 디자인 시스템 페이지는 거울이다. 값을 고치려면 1·2층 CSS를 고친다.
- 강조색(`primary`)은 디자인 시스템 페이지 견본에서도 쓰는 자리 규칙을 지킨다 — 주 버튼 견본과 색 역할 견본에만 쓰고, 간격 막대·격자 칸 같은 견본은 무채색으로 그린다(design-system `SKILL.md` 「강조색은 어디에 쓰나」).
- 개발용 묶음을 본 코드(`src/app`의 본 화면·`src/components`)에서 불러오지 않는다. 루트 레이아웃의 요소 복사 스크립트 줄은 주소를 적을 뿐 불러오지 않는다.
- `MOCKUP_CANVAS`는 내 컴퓨터의 명령 앞에만 붙인다 — Vercel 환경변수·`.env` 파일에 넣지 않는다.
- AI는 브라우저 자동화로 이 페이지를 열어 보거나 찍어 둔 그림을 보고 「확인 완료」라고 판정하지 않는다. 화면을 보고 판정하는 것은 사람 몫이다.
