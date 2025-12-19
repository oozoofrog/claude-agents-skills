# Repository Guidelines

## Project Structure & Module Organization
이 저장소는 Claude Code에서 사용할 에이전트와 스킬 문서를 모아둔 문서형 리포지토리다. 루트의 `README.md`는 전체 목록과 설치 방법을 제공한다. `agents/`에는 개별 에이전트 정의가 있으며 파일명은 `agents/<agent-name>.md` 형식을 따른다. `skills/`에는 스킬별 디렉터리가 있고 기본 설명은 `skills/<skill-name>/SKILL.md`에 둔다. 필요하면 `CHECKLIST.md`, `PRINCIPLES.md`, `SMELLS.md` 같은 보조 문서를 같은 폴더에 추가한다.

## Build, Test, and Development Commands
이 프로젝트는 문서만 다루므로 빌드나 실행 명령이 없다. 변경 전후를 빠르게 탐색하려면 다음 명령을 사용한다.
```
rg --files
rg "키워드" skills/
ls agents skills
```
의존성 설치 과정도 없다.

## Coding Style & Naming Conventions
모든 문서는 Markdown으로 작성하고, 제목은 명확한 H1/H2 구조를 유지한다. 문장은 한국어로 간결하게 쓰고, 예시는 코드 블록이나 인라인 코드로 제시한다. 스킬 폴더는 케밥 케이스를 사용한다(예: `skills/weekly-report/`). 핵심 문서는 대문자 파일명(`SKILL.md`)을 유지하고, 에이전트 파일은 소문자 케밥 케이스(`agents/tech-doc-writer.md`)로 통일한다.

## Testing Guidelines
자동 테스트는 없다. 변경 후에는 문서 렌더링이 자연스러운지와 링크/경로가 유효한지 수동으로 확인한다. 새로운 스킬이나 에이전트를 추가했다면 `README.md`의 목록도 함께 갱신한다.

## Commit & Pull Request Guidelines
기존 히스토리는 `Adds ...` 같은 영어 요약 형태가 많다. 앞으로는 커밋 메시지를 항상 한국어로 작성하며, 한 줄 요약으로 간단히 남긴다. 예: `스위프트 컨벤션 문서 보강`, `주간 보고 템플릿 정리`. PR은 요구 사항이 없으므로, 변경 요약과 영향 범위(예: `skills/weekly-report/`)만 간단히 적으면 된다. 새 문서 추가 시에는 포함된 파일 목록과 사용 목적을 덧붙인다.
