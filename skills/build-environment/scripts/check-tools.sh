#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REQUIRED_TOOLS=("xcode-build-server" "xcbeautify")
OPTIONAL_TOOLS=("tuist")
MISSING_REQUIRED=()
MISSING_OPTIONAL=()

echo "iOS/macOS Build Environment - 도구 확인"
echo "========================================"
echo ""

for tool in "${REQUIRED_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $tool"
    else
        echo -e "${RED}✗${NC} $tool (필수)"
        MISSING_REQUIRED+=("$tool")
    fi
done

for tool in "${OPTIONAL_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $tool"
    else
        echo -e "${YELLOW}○${NC} $tool (선택)"
        MISSING_OPTIONAL+=("$tool")
    fi
done

echo ""

if [[ ${#MISSING_REQUIRED[@]} -gt 0 ]]; then
    echo -e "${RED}누락된 필수 도구:${NC} ${MISSING_REQUIRED[*]}"
    echo ""
    echo "설치 명령:"
    echo "  brew install ${MISSING_REQUIRED[*]}"
    echo ""
    
    if [[ "${1:-}" == "--install" ]]; then
        echo "설치 중..."
        brew install "${MISSING_REQUIRED[@]}"
        echo -e "${GREEN}설치 완료${NC}"
    else
        echo "자동 설치: $0 --install"
    fi
    exit 1
else
    echo -e "${GREEN}모든 필수 도구가 설치되어 있습니다.${NC}"
fi

if [[ ${#MISSING_OPTIONAL[@]} -gt 0 ]]; then
    echo ""
    echo -e "${YELLOW}선택 도구 설치:${NC} brew install ${MISSING_OPTIONAL[*]}"
fi
