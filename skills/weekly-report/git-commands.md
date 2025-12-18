# Git Commands for Weekly Report

주간보고 생성에 필요한 Git 명령어 모음입니다.

## 사용자 감지

```bash
# Git config에서 사용자 이름 자동 감지
AUTHOR=$(git config user.name)

# 또는 사용자 지정
AUTHOR="사용자명"
```

## 날짜 계산

```bash
# 이번 주 월요일 계산
THIS_MONDAY=$(date -v-$(($(date +%u)-1))d +%Y-%m-%d)

# 지난 주 월요일/일요일 계산
LAST_MONDAY=$(date -v-$(($(date +%u)+6))d +%Y-%m-%d)
LAST_SUNDAY=$(date -v-$(($(date +%u)))d +%Y-%m-%d)

# 오늘 날짜
TODAY=$(date +%Y-%m-%d)
```

## 커밋 조회

### [한일] 커밋 조회 (지난 주 월요일 ~ 일요일)
```bash
git log --author="$AUTHOR" --since="$LAST_MONDAY" --until="$LAST_SUNDAY 23:59:59" --all --pretty=format:"%h|%s|%ad" --date=short
```

### [할일] 커밋 조회 (이번 주 월요일 ~ 오늘)
```bash
git log --author="$AUTHOR" --since="$THIS_MONDAY" --until="$TODAY 23:59:59" --all --pretty=format:"%h|%s|%ad" --date=short
```

### 브랜치 포함 상세 조회
```bash
git log --author="$AUTHOR" --since="$LAST_MONDAY" --all --pretty=format:"%h|%s|%ad|%D" --date=short
```

## 원격 저장소 최신화

```bash
git fetch --all
```

## 추가 분석

### 진행 중인 브랜치
```bash
# 아직 머지되지 않은 브랜치 확인
git branch -r --no-merged main | grep $AUTHOR
```

### 관련 이슈/PR
- GitHub/GitLab CLI가 있으면 열린 PR/이슈 조회
- 커밋에 언급된 티켓 번호 수집
