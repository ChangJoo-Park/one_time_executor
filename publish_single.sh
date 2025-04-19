#!/bin/bash

# 단일 패키지 배포 스크립트
# 사용법: ./publish_single.sh [패키지명]
# 예: ./publish_single.sh one_time_executor_shared_preferences

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 설정
ROOT_DIR=$(pwd)
LOG_DIR="$ROOT_DIR/logs"
mkdir -p "$LOG_DIR"

# 함수: 메시지 출력
print_message() {
  local message="$1"
  local color="$2"
  echo -e "${color}${message}${NC}"
}

# 인자 검사
if [ $# -ne 1 ]; then
  print_message "오류: 패키지명을 입력해주세요." "$RED"
  print_message "사용법: ./publish_single.sh [패키지명]" "$YELLOW"
  print_message "사용 가능한 패키지:" "$YELLOW"
  print_message "  - one_time_executor (코어)" "$YELLOW"
  print_message "  - one_time_executor_shared_preferences" "$YELLOW"
  print_message "  - one_time_executor_hive" "$YELLOW"
  print_message "  - one_time_executor_secure_storage" "$YELLOW"
  exit 1
fi

PACKAGE_NAME="$1"
LOG_FILE="$LOG_DIR/${PACKAGE_NAME}_publish.log"

# 패키지 디렉토리 설정
case "$PACKAGE_NAME" in
  "one_time_executor")
    PACKAGE_DIR="$ROOT_DIR"
    ;;
  "one_time_executor_shared_preferences")
    PACKAGE_DIR="$ROOT_DIR/packages/one_time_executor_shared_preferences"
    ;;
  "one_time_executor_hive")
    PACKAGE_DIR="$ROOT_DIR/packages/one_time_executor_hive"
    ;;
  "one_time_executor_secure_storage")
    PACKAGE_DIR="$ROOT_DIR/packages/one_time_executor_secure_storage"
    ;;
  *)
    print_message "오류: 잘못된 패키지명입니다: $PACKAGE_NAME" "$RED"
    exit 1
    ;;
esac

# 로그 시작
echo "[$PACKAGE_NAME] 배포 시작: $(date)" > "$LOG_FILE"

# 패키지 디렉토리로 이동
cd "$PACKAGE_DIR" || {
  print_message "오류: 디렉토리 이동 실패: $PACKAGE_DIR" "$RED"
  echo "오류: 디렉토리 이동 실패: $PACKAGE_DIR" >> "$LOG_FILE"
  exit 1
}

# 함수: 로그에 기록
log() {
  local message="$1"
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
  print_message "$message" "$YELLOW"
}

# 검증 및 배포 과정
log "[$PACKAGE_NAME] 패키지 준비 중..."

# Pub 캐시 수리 (선택적)
log "Pub 캐시 수리 중..."
flutter pub cache repair >> "$LOG_FILE" 2>&1 || {
  print_message "경고: Pub 캐시 수리 실패 (계속 진행)" "$YELLOW"
}

# 의존성 가져오기
log "의존성 가져오는 중..."
flutter pub get >> "$LOG_FILE" 2>&1 || {
  print_message "오류: 의존성 가져오기 실패" "$RED"
  exit 1
}

# 코드 분석
log "코드 분석 중..."
flutter analyze >> "$LOG_FILE" 2>&1 || {
  print_message "오류: 코드 분석 실패" "$RED"
  exit 1
}

# 테스트 실행
log "테스트 실행 중..."
flutter test >> "$LOG_FILE" 2>&1 || {
  print_message "오류: 테스트 실패" "$RED"
  exit 1
}

# Dry run
log "Dry run 실행 중..."
flutter pub publish --dry-run >> "$LOG_FILE" 2>&1 || {
  print_message "오류: Dry run 실패" "$RED"
  exit 1
}

# 배포 확인
print_message "[$PACKAGE_NAME] 패키지를 배포하시겠습니까? (y/n)" "$GREEN"
read -r answer
if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
  print_message "배포가 취소되었습니다." "$YELLOW"
  exit 0
fi

# 실제 배포
log "배포 중..."
flutter pub publish -f >> "$LOG_FILE" 2>&1 || {
  print_message "오류: 배포 실패" "$RED"
  exit 1
}

print_message "[$PACKAGE_NAME] 배포 완료!" "$GREEN"
log "배포 완료"
print_message "로그 파일: $LOG_FILE" "$YELLOW"
