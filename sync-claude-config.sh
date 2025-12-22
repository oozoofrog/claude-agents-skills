#!/bin/bash

# Claude agents/skills 동기화 스크립트
# 프로젝트 <-> ~/.claude 간 agents와 skills 동기화

set -euo pipefail

# 스크립트 디렉토리 확인
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || {
    echo "오류: 스크립트 디렉토리 확인 실패" >&2
    exit 1
}

# HOME 환경변수 검증
if [[ -z "${HOME:-}" ]]; then
    echo "오류: HOME 환경변수가 설정되지 않음" >&2
    exit 1
fi
HOME_CLAUDE="$HOME/.claude"

# 터미널 색상 지원 확인
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

print_usage() {
    echo -e "${BLUE}사용법:${NC} $0 [pull|push] [--dry-run]"
    echo ""
    echo -e "${GREEN}명령어:${NC}"
    echo "  pull      ~/.claude/agents, ~/.claude/skills → 현재 프로젝트로 복사"
    echo "  push      현재 프로젝트 agents/, skills/ → ~/.claude로 복사 (덮어쓰기)"
    echo ""
    echo -e "${YELLOW}옵션:${NC}"
    echo "  --dry-run   실제 복사 없이 변경될 내용만 표시"
    echo ""
    echo -e "${BLUE}예시:${NC}"
    echo "  $0 pull           # ~/.claude에서 가져오기"
    echo "  $0 push           # ~/.claude로 내보내기"
    echo "  $0 push --dry-run # 내보낼 내용 미리보기"
}

check_directories() {
    local source_agents="$1"
    local source_skills="$2"

    if [[ ! -d "$source_agents" ]]; then
        echo -e "${RED}오류:${NC} $source_agents 디렉토리가 없습니다." >&2
        exit 1
    fi

    if [[ ! -r "$source_agents" ]] || [[ ! -x "$source_agents" ]]; then
        echo -e "${RED}오류:${NC} $source_agents 디렉토리에 접근할 수 없습니다." >&2
        exit 1
    fi

    if [[ ! -d "$source_skills" ]]; then
        echo -e "${RED}오류:${NC} $source_skills 디렉토리가 없습니다." >&2
        exit 1
    fi

    if [[ ! -r "$source_skills" ]] || [[ ! -x "$source_skills" ]]; then
        echo -e "${RED}오류:${NC} $source_skills 디렉토리에 접근할 수 없습니다." >&2
        exit 1
    fi
}

sync_directories() {
    local source_agents="$1"
    local source_skills="$2"
    local dest_agents="$3"
    local dest_skills="$4"
    local dry_run="$5"
    local action_name="$6"

    echo -e "${BLUE}=== $action_name ===${NC}"
    echo ""

    # agents 동기화
    echo -e "${GREEN}[agents]${NC}"
    echo "  소스: $source_agents"
    echo "  대상: $dest_agents"

    if [[ "$dry_run" == "true" ]]; then
        echo -e "  ${YELLOW}(dry-run) 복사될 파일:${NC}"
        local find_output
        local find_status=0
        find_output=$(find "$source_agents" -type f -name "*.md" 2>&1) || find_status=$?

        if [[ $find_status -ne 0 ]]; then
            echo -e "    ${RED}오류: 파일 목록 조회 실패${NC}" >&2
            echo -e "    ${RED}상세: $find_output${NC}" >&2
            exit 1
        fi

        local found_agents=0
        while IFS= read -r file; do
            [[ -n "$file" ]] && echo "    - $(basename "$file")" && found_agents=1
        done <<< "$find_output"

        if [[ $found_agents -eq 0 ]]; then
            echo "    (복사할 .md 파일 없음)"
        fi
    else
        if ! mkdir -p "$dest_agents"; then
            echo -e "${RED}오류:${NC} 디렉토리 생성 실패: $dest_agents" >&2
            exit 1
        fi

        if [[ ! -w "$dest_agents" ]]; then
            echo -e "${RED}오류:${NC} 쓰기 권한 없음: $dest_agents" >&2
            exit 1
        fi

        # nullglob으로 빈 glob 처리
        shopt -s nullglob
        local md_files=("$source_agents"/*.md)
        shopt -u nullglob

        if [[ ${#md_files[@]} -eq 0 ]]; then
            echo "  (복사할 .md 파일 없음)"
        else
            for md_file in "${md_files[@]}"; do
                echo "  복사 중: $(basename "$md_file")"
                if ! cp -v "$md_file" "$dest_agents/"; then
                    echo -e "${RED}오류:${NC} 파일 복사 실패: $md_file" >&2
                    exit 1
                fi
            done
        fi
    fi

    echo ""

    # skills 동기화
    echo -e "${GREEN}[skills]${NC}"
    echo "  소스: $source_skills"
    echo "  대상: $dest_skills"

    if [[ "$dry_run" == "true" ]]; then
        echo -e "  ${YELLOW}(dry-run) 복사될 디렉토리:${NC}"
        local find_skills_output
        local find_skills_status=0
        find_skills_output=$(find "$source_skills" -mindepth 1 -maxdepth 1 -type d 2>&1) || find_skills_status=$?

        if [[ $find_skills_status -ne 0 ]]; then
            echo -e "    ${RED}오류: 디렉토리 목록 조회 실패${NC}" >&2
            echo -e "    ${RED}상세: $find_skills_output${NC}" >&2
            exit 1
        fi

        local found_skills=0
        while IFS= read -r dir; do
            [[ -n "$dir" ]] && echo "    - $(basename "$dir")/" && found_skills=1
        done <<< "$find_skills_output"

        if [[ $found_skills -eq 0 ]]; then
            echo "    (복사할 skill 디렉토리 없음)"
        fi
    else
        if ! mkdir -p "$dest_skills"; then
            echo -e "${RED}오류:${NC} 디렉토리 생성 실패: $dest_skills" >&2
            exit 1
        fi

        if [[ ! -w "$dest_skills" ]]; then
            echo -e "${RED}오류:${NC} 쓰기 권한 없음: $dest_skills" >&2
            exit 1
        fi

        # nullglob으로 빈 glob 처리
        shopt -s nullglob
        local skill_dirs=("$source_skills"/*/)
        shopt -u nullglob

        if [[ ${#skill_dirs[@]} -eq 0 ]]; then
            echo "  (복사할 skill 디렉토리 없음)"
        else
            for skill_dir in "${skill_dirs[@]}"; do
                skill_name=$(basename "$skill_dir")
                echo "  복사 중: $skill_name/"
                if ! cp -Rv "${skill_dir%/}" "$dest_skills/"; then
                    echo -e "${RED}오류:${NC} skill 복사 실패: $skill_name" >&2
                    exit 1
                fi
            done
        fi
    fi

    echo ""
    if [[ "$dry_run" == "true" ]]; then
        echo -e "${YELLOW}dry-run 모드: 실제 파일은 복사되지 않았습니다.${NC}"
    else
        echo -e "${GREEN}동기화 완료!${NC}"
    fi
}

# 메인 로직
DRY_RUN="false"
ACTION=""

for arg in "$@"; do
    case $arg in
        pull)
            ACTION="pull"
            ;;
        push)
            ACTION="push"
            ;;
        --dry-run)
            DRY_RUN="true"
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo -e "${RED}알 수 없는 인자:${NC} $arg" >&2
            print_usage
            exit 1
            ;;
    esac
done

if [[ -z "$ACTION" ]]; then
    print_usage
    exit 1
fi

case $ACTION in
    pull)
        check_directories "$HOME_CLAUDE/agents" "$HOME_CLAUDE/skills"
        sync_directories \
            "$HOME_CLAUDE/agents" \
            "$HOME_CLAUDE/skills" \
            "$SCRIPT_DIR/agents" \
            "$SCRIPT_DIR/skills" \
            "$DRY_RUN" \
            "Pull: ~/.claude → 프로젝트"
        ;;
    push)
        check_directories "$SCRIPT_DIR/agents" "$SCRIPT_DIR/skills"
        sync_directories \
            "$SCRIPT_DIR/agents" \
            "$SCRIPT_DIR/skills" \
            "$HOME_CLAUDE/agents" \
            "$HOME_CLAUDE/skills" \
            "$DRY_RUN" \
            "Push: 프로젝트 → ~/.claude"
        ;;
esac
