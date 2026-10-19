# 목업 캔버스 뼈대

화면을 한 페이지에서 훑어보는 **목업 캔버스**와, 토큰·부품을 실제 코드로 보여 주는 **디자인 시스템 페이지**의 코드 틀이다. 개발 서버에서만 열리고, 실서비스 빌드에서는 404다(내 컴퓨터에서만 켜는 예외는 아래 「실서비스 빌드로 빠르게 보기」).

## 파일

| 틀 파일 | 프로젝트에 넣는 자리 |
|---|---|
| `app/(dev)/layout.tsx.template` | `src/app/(dev)/layout.tsx` — 실서비스 빌드에서 `notFound()` |
| `app/(dev)/dev/canvas/page.tsx.template` | `src/app/(dev)/dev/canvas/page.tsx` — 목업 캔버스 (`/dev/canvas`) |
| `app/(dev)/dev/canvas/screens.ts.template` | `src/app/(dev)/dev/canvas/screens.ts` — 목록 파일 |
| `app/(dev)/dev/design-system/page.tsx.template` | `src/app/(dev)/dev/design-system/page.tsx` — 디자인 시스템 페이지 (`/dev/design-system`) |
| `lib/dev-state.ts.template` | `src/lib/dev-state.ts` — `?state=` 읽기 도우미 |

## 프로젝트에 넣는 차례

1. 위 표대로 파일을 `src/` 아래 같은 경로로 복사하면서 끝의 `.template`을 뗀다.
2. `{{…}}`를 채운다 — 디자인 시스템 페이지의 서비스 이름, 글자 단계·색 역할·간격·둥글기 목록(프로젝트의 2층 이름으로), 프로젝트에 없는 부품 import 지우기.
3. **`<main>`을 셸에 맞춘다** — 틀 페이지의 맨 바깥은 `<div>`다. 셸(루트 레이아웃)이 본문 영역에 `<main>`을 두는 구조가 기본이라서다. 프로젝트 셸이 `<main>`을 두지 않고 화면마다 두는 구조면 두 틀 페이지의 맨 바깥 `<div>`를 `<main>`으로 바꾼다 — 한 페이지에 `<main>`은 하나다(design-system `layout-frames.md` §2.2).
4. **`next.config.ts`에 `env` 한 줄을 더한다** — `MOCKUP_CANVAS` 값을 빌드 때 브라우저 코드에도 넣어 두는 줄이다(아래 「실서비스 빌드로 빠르게 보기」). 이미 `env`가 있으면 그 안에 항목만 더한다.

   ```ts
   const nextConfig: NextConfig = {
     // 목업 캔버스 흉내 스위치 — 빌드할 때의 MOCKUP_CANVAS 값을 서버·브라우저 코드에 글자 그대로 넣는다(없으면 빈 글자).
     // .env 파일·Vercel 환경변수에는 넣지 않는다 — 넣으면 공개 주소에서 목업 캔버스가 열린다.
     env: {
       MOCKUP_CANVAS: process.env.MOCKUP_CANVAS ?? "",
     },
   }
   ```

5. **2층 파일 맨 끝에 「비교안」 블록 자리를 만들어 둔다** — `src/styles/2-semantic.css` 맨 끝에 주석 한 줄만 두고 비워 둔다. 화면 개선 단계가 이 아래에 비교안 범위 클래스를 넣는다. 모양은 design-system `bootstrap-project.md` §1.1 6번.
6. 목록 파일(`screens.ts`)의 예시를 지우고 프로젝트 화면을 올린다. 화면을 새로 만들 때마다 한 줄씩 더한다. 적는 모양은 아래 「목록 파일에 적는 모양」.
7. 저장·조회 코드(서버 컴포넌트·서버 함수, 또는 브라우저에서 데이터를 읽는 코드)에서 `readDevState`를 불러 빈 결과·느린 응답·오류·권한없음을 흉내 낸다. 부르는 예는 `dev-state.ts` 맨 위 주석에 있다.
8. 빌드·린트·타입 검사를 돌린다 (`npm run build`, `npm run lint`, `npx tsc --noEmit`).
9. 실서비스 모드(`npm run build` 뒤 `npm run start`)에서 `/dev/canvas`와 `/dev/design-system`이 404인지 `curl -s -o /dev/null -w "%{http_code}" <주소>`로 확인한다. 배포한 뒤에는 공개 주소로도 같은 확인을 한다.

## 목록 파일에 적는 모양

`screens.ts`의 `SCREENS`에 화면마다 한 항목을 적는다. 배열 순서가 곧 캔버스에 뜨는 차례다.

```ts
{
  id: "S-02",                       // 화면 목록의 화면 ID와 같게
  name: "글 목록",                   // 사용자가 보는 화면 이름
  group: "처음 온 사람 — 둘러보기에서 가입까지",  // 같은 묶음끼리 한 제목 아래 모인다
  path: "/posts",                   // 화면 주소
  states: ["empty", "loading"],     // 같이 띄울 상태 창 — 주소 끝에 ?state=가 붙는다
  drafts: [                         // 비교안 — 화면 개선 단계에서만 붙인다
    { label: "A판", path: "/dev/drafts/posts-a" },
    { label: "B판", path: "/dev/drafts/posts-b", states: ["empty"] },
  ],
}
```

- **`states`** — `"empty"`·`"loading"`·`"error"`·`"forbidden"` 중 그 화면이 가진 상태만 적는다. 원래 화면 창 아래에 상태마다 창이 한 쌍(데스크톱·폰)씩 더 뜬다.
- **`drafts`** — 원래 화면 아래 「비교안」 제목 밑에 판마다 줄을 지어 뜬다. 판마다 원래 모양 한 쌍과 상태 창이 뜬다. 판의 `states`를 빼면 원래 화면의 `states`와 같은 상태 창을 띄운다 — 비교안도 본 화면과 같은 저장·조회 코드를 거치니 같은 `?state=`가 듣는다. 판마다 다르게 띄우려면 그 판에 `states`를 적는다(빈 배열 `[]`이면 상태 창 없음).
- **고른 뒤** — 고른 판이 본 화면 자리로 옮겨 가면 그 항목의 `drafts`에서 고른 판을 지운다. 고르지 않은 판은 비교안을 지울 때 같이 지운다.

## 실서비스 빌드로 빠르게 보기

개발 서버(`npm run dev`)는 주소를 처음 열 때마다 그 화면을 새로 만들어서, 목업 캔버스처럼 창을 여러 개 띄우면 처음 내려 볼 때 느리다. 내 컴퓨터에서 빠르게 훑어보고 싶으면 실서비스 빌드를 띄우되, 빌드 명령 앞에 `MOCKUP_CANVAS=1`을 붙인다.

```bash
MOCKUP_CANVAS=1 npm run build && npm run start
```

- 열림과 `?state=` 흉내는 둘 다 **빌드 때** 정해진다 — 빌드 명령에 꼭 붙인다. 실행 명령에는 붙이지 않아도 되고, 붙여도 바뀌는 것이 없다.
- **`?state=` 흉내가 브라우저 쪽에서도 켜지려면 `next.config.ts`의 `env` 줄이 있어야 한다** (「프로젝트에 넣는 차례」 4번). 데이터를 브라우저에서 읽는 화면은 `readDevState`도 브라우저에서 도는데, 브라우저 코드는 서버 환경변수를 못 읽는다. `env` 줄이 빌드 때 값을 코드에 글자 그대로 넣어 두어 서버와 브라우저가 같은 조건으로 켜진다. Next.js 문서 `next.config.js` 옵션 `env`가 이 동작을 정한다 — 빌드 때 `process.env.MOCKUP_CANVAS`를 값으로 바꿔 넣는다(그래서 `process.env`를 구조 분해하면 안 바뀐다).
- 다 본 뒤 평소처럼 `npm run build`를 다시 하면 막힌 빌드로 돌아간다.
- **이 변수는 Vercel 환경변수에 절대 넣지 않는다** — 넣으면 공개 주소에서 목업 캔버스가 열린다. `.env`·`.env.local` 같은 파일에도 적지 않는다(빌드가 그 파일을 읽어 모르는 사이에 열린다). 명령 앞에 붙여 그 한 번만 쓴다.

## 동작 메모

- 실서비스 막기는 `(dev)/layout.tsx`가 `process.env.NODE_ENV === "production"`이고 `MOCKUP_CANVAS`가 `1`이 아닐 때 `notFound()`를 부르는 방식이다. 이 페이지들은 `next build`가 미리 그려 두는 정적 페이지이고 `next.config.ts`의 `env`가 값을 빌드 때 코드에 넣어 두므로, 열릴지 막힐지는 **빌드 때** 정해진다 — 실행(`next start`) 때만 변수를 붙이면 그대로 404고, 붙여 빌드했으면 실행 때 변수가 없어도 열린다. 실제 Next.js 앱에서 `next start`로 두 경우를 시험해 확인했다.
- `(dev)`는 라우트 그룹(주소에는 안 나타나고 폴더만 묶는 이름)이다. 비교안 폴더(`src/app/(dev)/dev/drafts/`)도 같은 그룹 아래라 같이 막힌다.
- 루트 레이아웃(헤더·푸터)이 이 페이지들도 감싼다. 창(iframe) 안의 화면도 같은 레이아웃을 쓰니 실제 화면과 똑같이 보인다. 그래서 틀 페이지는 `<main>`을 스스로 두지 않는다(「프로젝트에 넣는 차례」 3번).
- 데스크톱 창은 실제 폭(1440)으로 띄우고 CSS로 줄여 보여 준다. 그래야 창 안의 컨테이너 쿼리가 실제 폭 기준으로 돈다. 창은 `loading="lazy"`라 화면에 들어온 것만 불러온다 — 개발 서버는 주소를 처음 열 때 컴파일하므로 처음 내려 볼 때는 느리다.
- `?state=`는 주소로만 정한다(브라우저 저장소에 쓰지 않는다). 한 창이 다른 창의 상태를 바꾸지 않게 하려는 것이다.
- 루트 `tsconfig.json`의 `include`가 `**/*.tsx`라도 이 틀의 끝 이름은 `.tsx.template`이라 `.claude/templates/` 안에서는 검사에 걸리지 않는다.

## 지켜야 할 것

- 이 틀의 코드도 디자인 규칙을 지킨다 — hex(`#…`)·`rgb(`·`oklch(`·`px` 글자·대괄호 임의 값(`w-[…]`)을 쓰지 않고, 2층 이름과 Tailwind 단계 클래스만 쓴다. 화면 크기에 따른 분기는 뷰포트 접두어(`md:` 등) 대신 컨테이너 쿼리를 쓴다.
- 창 크기는 숫자 속성(`width={1440}`)과 숫자 스타일로 적는다. `px` 글자를 쓰지 않는다.
- 색·크기 값은 코드에 적지 않는다. 디자인 시스템 페이지는 브라우저가 계산한 값을 읽어 보여 준다.
- 디자인 시스템 페이지는 거울이다. 값을 고치려면 1·2층 CSS를 고친다.
- 강조색(`primary`)은 견본에서도 쓰는 자리 규칙을 지킨다 — 주 버튼 견본과 색 역할 견본에만 쓰고, 간격 막대·격자 칸 같은 견본은 무채색으로 그린다(design-system `SKILL.md` 「강조색은 어디에 쓰나」).
- 개발용 묶음을 본 코드(`src/app`의 본 화면·`src/components`)에서 불러오지 않는다.
- `MOCKUP_CANVAS`는 내 컴퓨터의 명령 앞에만 붙인다 — Vercel 환경변수·`.env` 파일에 넣지 않는다.
- AI는 브라우저 자동화로 이 페이지를 열어 보고 「확인 완료」라고 판정하지 않는다. 화면을 보고 판정하는 것은 사람 몫이다.
