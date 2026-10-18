# 목업 캔버스 뼈대

화면을 한 페이지에서 훑어보는 **목업 캔버스**와, 토큰·부품을 실제 코드로 보여 주는 **디자인 시스템 페이지**의 코드 틀이다. 개발 서버에서만 열리고, 실서비스 빌드에서는 404다.

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
3. 목록 파일(`screens.ts`)의 예시를 지우고 프로젝트 화면을 올린다. 화면을 새로 만들 때마다 한 줄씩 더한다.
4. 저장·조회 코드(서버 컴포넌트·서버 함수)에서 `readDevState`를 불러 빈 결과·느린 응답·오류·권한없음을 흉내 낸다. 부르는 예는 `dev-state.ts` 맨 위 주석에 있다.
5. 빌드·린트·타입 검사를 돌린다 (`npm run build`, `npm run lint`, `npx tsc --noEmit`).
6. 실서비스 모드(`npm run build` 뒤 `npm run start`)에서 `/dev/canvas`와 `/dev/design-system`이 404인지 `curl -s -o /dev/null -w "%{http_code}" <주소>`로 확인한다. 배포한 뒤에는 공개 주소로도 같은 확인을 한다.

## 동작 메모

- 실서비스 막기는 `(dev)/layout.tsx`가 `process.env.NODE_ENV === "production"`일 때 `notFound()`를 부르는 방식이다. 실제 Next.js 앱에서 `next start`로 404가 나오는 것을 시험으로 확인했다. 레이아웃은 빌드 시점이 아니라 요청 때 돌기 때문에 환경 변수 검사가 맞게 걸린다.
- `(dev)`는 라우트 그룹(주소에는 안 나타나고 폴더만 묶는 이름)이다. 비교안 폴더(`src/app/(dev)/dev/drafts/`)도 같은 그룹 아래라 같이 막힌다.
- 루트 레이아웃(헤더·푸터)이 이 페이지들도 감싼다. 창(iframe) 안의 화면도 같은 레이아웃을 쓰니 실제 화면과 똑같이 보인다.
- 데스크톱 창은 실제 폭(1440)으로 띄우고 CSS로 줄여 보여 준다. 그래야 창 안의 컨테이너 쿼리가 실제 폭 기준으로 돈다. 창은 `loading="lazy"`라 화면에 들어온 것만 불러온다 — 개발 서버는 주소를 처음 열 때 컴파일하므로 처음 내려 볼 때는 느리다.
- `?state=`는 주소로만 정한다(브라우저 저장소에 쓰지 않는다). 한 창이 다른 창의 상태를 바꾸지 않게 하려는 것이다.
- 루트 `tsconfig.json`의 `include`가 `**/*.tsx`라도 이 틀의 끝 이름은 `.tsx.template`이라 `.claude/templates/` 안에서는 검사에 걸리지 않는다.

## 지켜야 할 것

- 이 틀의 코드도 디자인 규칙을 지킨다 — hex(`#…`)·`rgb(`·`oklch(`·`px` 글자·대괄호 임의 값(`w-[…]`)을 쓰지 않고, 2층 이름과 Tailwind 단계 클래스만 쓴다. 화면 크기에 따른 분기는 뷰포트 접두어(`md:` 등) 대신 컨테이너 쿼리를 쓴다.
- 창 크기는 숫자 속성(`width={1440}`)과 숫자 스타일로 적는다. `px` 글자를 쓰지 않는다.
- 색·크기 값은 코드에 적지 않는다. 디자인 시스템 페이지는 브라우저가 계산한 값을 읽어 보여 준다.
- 디자인 시스템 페이지는 거울이다. 값을 고치려면 1·2층 CSS를 고친다.
- 개발용 묶음을 본 코드(`src/app`의 본 화면·`src/components`)에서 불러오지 않는다.
- AI는 브라우저 자동화로 이 페이지를 열어 보고 「확인 완료」라고 판정하지 않는다. 화면을 보고 판정하는 것은 사람 몫이다.
