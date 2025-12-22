#!/bin/bash

# Claude agents/skills 동기화 스크립트
# 프로젝트 <-> ~/.claude 간 agents와 skills 동기화

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_CLAUDE="$HOME/.claude"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
        echo -e "${RED}오류:${NC} $source_agents 디렉토리가 없습니다."
        exit 1
    fi

    if [[ ! -d "$source_skills" ]]; then
        echo -e "${RED}오류:${NC} $source_skills 디렉토리가 없습니다."
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
        find "$source_agents" -type f -name "*.md" | while read -r file; do
            echo "    - $(basename "$file")"
        done
    else
        mkdir -p "$dest_agents"
        cp -Rv "$source_agents"/*.md "$dest_agents/" 2>/dev/null || echo "  (복사할 .md 파일 없음)"
    fi

    echo ""

    # skills 동기화
    echo -e "${GREEN}[skills]${NC}"
    echo "  소스: $source_skills"
    echo "  대상: $dest_skills"

    if [[ "$dry_run" == "true" ]]; then
        echo -e "  ${YELLOW}(dry-run) 복사될 디렉토리:${NC}"
        find "$source_skills" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
            echo "    - $(basename "$dir")/"
        done
    else
        mkdir -p "$dest_skills"
        # 각 skill 디렉토리를 재귀적으로 복사
        for skill_dir in "$source_skills"/*/; do
            if [[ -d "$skill_dir" ]]; then
                skill_name=$(basename "$skill_dir")
                echo "  복사 중: $skill_name/"
                cp -Rv "$skill_dir" "$dest_skills/" 2>/dev/null || true
            fi
        done
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
            echo -e "${RED}알 수 없는 인자:${NC} $arg"
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
