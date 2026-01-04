#!/bin/bash

# =============================================================================
# LLM Settings 동기화 스크립트 v2.0
# Claude Code, Codex CLI, OpenCode 간 agents/skills 동기화
# =============================================================================

set -euo pipefail

# 스크립트 디렉토리
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 기본 설정 경로
CLAUDE_HOME="${HOME}/.claude"
CODEX_HOME="${HOME}/.codex"
OPENCODE_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"

# 색상 설정
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' NC=''
fi

# =============================================================================
# 헬퍼 함수
# =============================================================================

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1" >&2; }
log_header() { echo -e "\n${BOLD}${CYAN}═══ $1 ═══${NC}\n"; }

print_usage() {
    cat << EOF
${BOLD}LLM Settings 동기화 스크립트${NC}

${BOLD}사용법:${NC}
  $0 <command> [options]

${BOLD}명령어:${NC}
  push        프로젝트 → 도구로 동기화
  pull        도구 → 프로젝트로 동기화
  status      현재 동기화 상태 확인

${BOLD}옵션:${NC}
  --tools <list>    동기화할 도구 (기본: claude,codex,opencode)
                    예: --tools claude,codex
  --agents-only     에이전트만 동기화
  --skills-only     스킬만 동기화
  --dry-run         실제 복사 없이 미리보기
  -h, --help        도움말 표시

${BOLD}예시:${NC}
  $0 push                           # 모든 도구로 push
  $0 push --tools claude            # Claude만 push
  $0 push --dry-run                 # push 미리보기
  $0 pull --tools codex             # Codex에서 pull
  $0 status                         # 상태 확인

${BOLD}지원 도구:${NC}
  claude     ~/.claude/agents, ~/.claude/skills
  codex      ~/.codex/agents, ~/.codex/skills
  opencode   ~/.config/opencode/skill

${BOLD}포맷 변환:${NC}
  • Claude/OpenCode 에이전트: agents/<name>.md
  • Codex 에이전트: agents/<name>/rules.md
  • 모든 스킬: skills/<name>/SKILL.md (공통 포맷)
EOF
}

# =============================================================================
# 도구별 경로 함수
# =============================================================================

get_tool_agents_path() {
    local tool="$1"
    case "$tool" in
        claude)   echo "$CLAUDE_HOME/agents" ;;
        codex)    echo "$CODEX_HOME/agents" ;;
        opencode) echo "" ;;

        *)        echo "" ;;
    esac
}

get_tool_skills_path() {
    local tool="$1"
    case "$tool" in
        claude)   echo "$CLAUDE_HOME/skills" ;;
        codex)    echo "$CODEX_HOME/skills" ;;
        opencode) echo "$OPENCODE_HOME/skill" ;;
        *)        echo "" ;;
    esac
}

# =============================================================================
# 포맷 변환 함수
# =============================================================================

convert_claude_agent_to_codex() {
    local src="$1"
    local dest="$2"
    if grep -q '^---$' "$src"; then
        awk '/^---$/{p++} p==2{p=3} p==3{print}' "$src" | tail -n +2 > "$dest"
    else
        cp "$src" "$dest"
    fi
}

convert_codex_agent_to_claude() {
    local src="$1"
    local dest="$2"
    local name="$3"
    {
        echo "---"
        echo "name: $name"
        echo "description: Imported from Codex"
        echo "---"
        echo ""
        cat "$src"
    } > "$dest"
}

# =============================================================================
# 에이전트 동기화 함수
# =============================================================================

sync_agents_to_claude() {
    local dry_run="$1"
    local src="$SCRIPT_DIR/agents"
    local dest="$CLAUDE_HOME/agents"

    if [[ ! -d "$src" ]]; then
        log_warn "소스 디렉토리 없음: $src"
        return 0
    fi

    log_info "Claude agents: $src → $dest"

    if [[ "$dry_run" == "true" ]]; then
        shopt -s nullglob
        local files=("$src"/*.md)
        shopt -u nullglob
        if [[ ${#files[@]} -eq 0 ]]; then
            echo "    (복사할 파일 없음)"
        else
            for f in "${files[@]}"; do
                echo "    ${YELLOW}→${NC} $(basename "$f")"
            done
        fi
    else
        mkdir -p "$dest"
        shopt -s nullglob
        local files=("$src"/*.md)
        shopt -u nullglob
        for f in "${files[@]}"; do
            cp "$f" "$dest/"
            log_success "$(basename "$f")"
        done
    fi
}

sync_agents_to_codex() {
    local dry_run="$1"
    local src="$SCRIPT_DIR/agents"
    local dest="$CODEX_HOME/agents"

    if [[ ! -d "$src" ]]; then
        log_warn "소스 디렉토리 없음: $src"
        return 0
    fi

    log_info "Codex agents: $src → $dest"

    shopt -s nullglob
    local files=("$src"/*.md)
    shopt -u nullglob

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "    (복사할 파일 없음)"
        return 0
    fi

    for f in "${files[@]}"; do
        local name
        name=$(basename "$f" .md)
        local agent_dir="$dest/$name"

        if [[ "$dry_run" == "true" ]]; then
            echo "    ${YELLOW}→${NC} $name/ (rules.md 변환)"
        else
            mkdir -p "$agent_dir"
            convert_claude_agent_to_codex "$f" "$agent_dir/rules.md"
            [[ ! -f "$agent_dir/state.json" ]] && echo '{"enabled": true}' > "$agent_dir/state.json"
            log_success "$name/ (변환됨)"
        fi
    done
}

sync_agents_from_claude() {
    local dry_run="$1"
    local src="$CLAUDE_HOME/agents"
    local dest="$SCRIPT_DIR/agents"

    if [[ ! -d "$src" ]]; then
        log_warn "소스 디렉토리 없음: $src"
        return 0
    fi

    log_info "Claude agents: $src → $dest"

    if [[ "$dry_run" == "true" ]]; then
        shopt -s nullglob
        local files=("$src"/*.md)
        shopt -u nullglob
        if [[ ${#files[@]} -eq 0 ]]; then
            echo "    (복사할 파일 없음)"
        else
            for f in "${files[@]}"; do
                echo "    ${YELLOW}←${NC} $(basename "$f")"
            done
        fi
    else
        mkdir -p "$dest"
        shopt -s nullglob
        local files=("$src"/*.md)
        shopt -u nullglob
        for f in "${files[@]}"; do
            cp "$f" "$dest/"
            log_success "$(basename "$f")"
        done
    fi
}

sync_agents_from_codex() {
    local dry_run="$1"
    local src="$CODEX_HOME/agents"
    local dest="$SCRIPT_DIR/agents"

    if [[ ! -d "$src" ]]; then
        log_warn "소스 디렉토리 없음: $src"
        return 0
    fi

    log_info "Codex agents: $src → $dest"

    shopt -s nullglob
    local dirs=("$src"/*/)
    shopt -u nullglob

    if [[ ${#dirs[@]} -eq 0 ]]; then
        echo "    (복사할 에이전트 없음)"
        return 0
    fi

    for d in "${dirs[@]}"; do
        local name
        name=$(basename "$d")
        [[ "$name" == ".system" ]] && continue

        local rules_file="$d/rules.md"
        if [[ -f "$rules_file" ]]; then
            if [[ "$dry_run" == "true" ]]; then
                echo "    ${YELLOW}←${NC} $name.md (rules.md에서 변환)"
            else
                mkdir -p "$dest"
                convert_codex_agent_to_claude "$rules_file" "$dest/$name.md" "$name"
                log_success "$name.md (변환됨)"
            fi
        fi
    done
}

# =============================================================================
# 스킬 동기화 함수
# =============================================================================

sync_skills_to_tool() {
    local tool="$1"
    local dry_run="$2"
    local src="$SCRIPT_DIR/skills"
    local dest
    dest=$(get_tool_skills_path "$tool")

    if [[ -z "$dest" ]]; then
        log_warn "$tool: 스킬 경로 없음"
        return 0
    fi

    if [[ ! -d "$src" ]]; then
        log_warn "소스 디렉토리 없음: $src"
        return 0
    fi

    log_info "$tool skills: $src → $dest"

    shopt -s nullglob
    local dirs=("$src"/*/)
    shopt -u nullglob

    if [[ ${#dirs[@]} -eq 0 ]]; then
        echo "    (복사할 스킬 없음)"
        return 0
    fi

    for d in "${dirs[@]}"; do
        local name
        name=$(basename "$d")

        if [[ "$dry_run" == "true" ]]; then
            echo "    ${YELLOW}→${NC} $name/"
        else
            mkdir -p "$dest"
            cp -R "${d%/}" "$dest/"
            log_success "$name/"
        fi
    done
}

sync_skills_from_tool() {
    local tool="$1"
    local dry_run="$2"
    local src
    src=$(get_tool_skills_path "$tool")
    local dest="$SCRIPT_DIR/skills"

    if [[ -z "$src" || ! -d "$src" ]]; then
        log_warn "$tool: 소스 스킬 경로 없음"
        return 0
    fi

    log_info "$tool skills: $src → $dest"

    shopt -s nullglob
    local dirs=("$src"/*/)
    shopt -u nullglob

    if [[ ${#dirs[@]} -eq 0 ]]; then
        echo "    (복사할 스킬 없음)"
        return 0
    fi

    for d in "${dirs[@]}"; do
        local name
        name=$(basename "$d")
        [[ "$name" == ".system" ]] && continue

        if [[ "$dry_run" == "true" ]]; then
            echo "    ${YELLOW}←${NC} $name/"
        else
            mkdir -p "$dest"
            cp -R "${d%/}" "$dest/"
            log_success "$name/"
        fi
    done
}

# =============================================================================
# 상태 확인 함수
# =============================================================================

show_status() {
    local tools=("$@")

    log_header "동기화 상태"

    echo -e "${BOLD}프로젝트 소스:${NC} $SCRIPT_DIR"
    echo ""

    # 프로젝트 상태
    echo -e "${BOLD}[프로젝트]${NC}"
    shopt -s nullglob
    local agent_files=("$SCRIPT_DIR/agents"/*.md)
    local skill_dirs=("$SCRIPT_DIR/skills"/*/)
    shopt -u nullglob
    echo "  에이전트: ${#agent_files[@]}개"
    echo "  스킬: ${#skill_dirs[@]}개"
    echo ""

    # 각 도구 상태
    for tool in "${tools[@]}"; do
        echo -e "${BOLD}[$tool]${NC}"

        case "$tool" in
            claude)
                local path="$CLAUDE_HOME"
                if [[ -d "$path" ]]; then
                    shopt -s nullglob
                    local agents=("$path/agents"/*.md)
                    local skills=("$path/skills"/*/)
                    shopt -u nullglob
                    echo "  경로: $path"
                    echo "  에이전트: ${#agents[@]}개"
                    echo "  스킬: ${#skills[@]}개"
                else
                    echo "  ${YELLOW}미설치${NC}"
                fi
                ;;
            codex)
                local path="$CODEX_HOME"
                if [[ -d "$path" ]]; then
                    shopt -s nullglob
                    local agents=("$path/agents"/*/)
                    local skills=("$path/skills"/*/)
                    shopt -u nullglob
                    local agent_count=0
                    for a in "${agents[@]}"; do
                        [[ "$(basename "$a")" != ".system" ]] && ((agent_count++)) || true
                    done
                    local skill_count=0
                    for s in "${skills[@]}"; do
                        [[ "$(basename "$s")" != ".system" ]] && ((skill_count++)) || true
                    done
                    echo "  경로: $path"
                    echo "  에이전트: ${agent_count}개"
                    echo "  스킬: ${skill_count}개"
                else
                    echo "  ${YELLOW}미설치${NC}"
                fi
                ;;
            opencode)
                local path="$OPENCODE_HOME"
                if [[ -d "$path" ]]; then
                    shopt -s nullglob
                    local skills=("$path/skill"/*/)
                    shopt -u nullglob
                    echo "  경로: $path"
                    echo "  스킬: ${#skills[@]}개"
                    echo "  ${CYAN}(Claude 경로도 인식됨)${NC}"
                else
                    echo "  ${YELLOW}미설치${NC}"
                fi
                ;;
        esac
        echo ""
    done
}

# =============================================================================
# Push/Pull 명령 함수
# =============================================================================

do_push() {
    local tools=("$1")
    local sync_agents="$2"
    local sync_skills="$3"
    local dry_run="$4"

    IFS=',' read -ra tool_array <<< "$tools"

    log_header "Push: 프로젝트 → 도구"

    if [[ "$dry_run" == "true" ]]; then
        log_warn "DRY-RUN 모드: 실제 파일은 복사되지 않습니다"
        echo ""
    fi

    for tool in "${tool_array[@]}"; do
        echo -e "${BOLD}[$tool]${NC}"

        if [[ "$sync_agents" == "true" ]]; then
            case "$tool" in
                claude)   sync_agents_to_claude "$dry_run" ;;
                codex)    sync_agents_to_codex "$dry_run" ;;
                opencode) log_info "OpenCode: 에이전트는 스킬로 관리됨 (건너뜀)" ;;
            esac
        fi

        if [[ "$sync_skills" == "true" ]]; then
            sync_skills_to_tool "$tool" "$dry_run"
        fi

        echo ""
    done

    if [[ "$dry_run" != "true" ]]; then
        log_success "Push 완료!"
    fi
}

do_pull() {
    local tools=("$1")
    local sync_agents="$2"
    local sync_skills="$3"
    local dry_run="$4"

    IFS=',' read -ra tool_array <<< "$tools"

    log_header "Pull: 도구 → 프로젝트"

    if [[ "$dry_run" == "true" ]]; then
        log_warn "DRY-RUN 모드: 실제 파일은 복사되지 않습니다"
        echo ""
    fi

    for tool in "${tool_array[@]}"; do
        echo -e "${BOLD}[$tool]${NC}"

        if [[ "$sync_agents" == "true" ]]; then
            case "$tool" in
                claude)   sync_agents_from_claude "$dry_run" ;;
                codex)    sync_agents_from_codex "$dry_run" ;;
                opencode) log_info "OpenCode: 에이전트 없음 (건너뜀)" ;;
            esac
        fi

        if [[ "$sync_skills" == "true" ]]; then
            sync_skills_from_tool "$tool" "$dry_run"
        fi

        echo ""
    done

    if [[ "$dry_run" != "true" ]]; then
        log_success "Pull 완료!"
    fi
}

# =============================================================================
# 메인 로직
# =============================================================================

main() {
    local command=""
    local tools="claude,codex,opencode"
    local sync_agents="true"
    local sync_skills="true"
    local dry_run="false"

    # 인자 파싱
    while [[ $# -gt 0 ]]; do
        case "$1" in
            push|pull|status)
                command="$1"
                shift
                ;;
            --tools)
                tools="$2"
                shift 2
                ;;
            --agents-only)
                sync_skills="false"
                shift
                ;;
            --skills-only)
                sync_agents="false"
                shift
                ;;
            --dry-run)
                dry_run="true"
                shift
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            *)
                log_error "알 수 없는 인자: $1"
                print_usage
                exit 1
                ;;
        esac
    done

    # 명령 검증
    if [[ -z "$command" ]]; then
        print_usage
        exit 1
    fi

    # 도구 검증
    IFS=',' read -ra tool_array <<< "$tools"
    for tool in "${tool_array[@]}"; do
        case "$tool" in
            claude|codex|opencode) ;;
            *)
                log_error "지원하지 않는 도구: $tool"
                exit 1
                ;;
        esac
    done

    # 명령 실행
    case "$command" in
        push)
            do_push "$tools" "$sync_agents" "$sync_skills" "$dry_run"
            ;;
        pull)
            do_pull "$tools" "$sync_agents" "$sync_skills" "$dry_run"
            ;;
        status)
            show_status "${tool_array[@]}"
            ;;
    esac
}

main "$@"
