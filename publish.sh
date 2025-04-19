#!/bin/bash

# 설정
ROOT_DIR=$(pwd)
CORE_PACKAGE_DIR="$ROOT_DIR"
ADAPTERS_DIR="$ROOT_DIR/packages"
LOG_FILE="$ROOT_DIR/publish_log.txt"

# 로그 파일 초기화
echo "배포 시작: $(date)" > "$LOG_FILE"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 함수: 로그 출력 및 저장
log() {
  local message="$1"
  local color="$2"

  # 콘솔 출력
  echo -e "${color}${message}${NC}"

  # 로그 파일에 저장 (색상 코드 제외)
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

# 함수: 패키지 검증
validate_package() {
  local package_dir="$1"
  local package_name="$2"

  cd "$package_dir" || {
    log "디렉토리 이동 실패: $package_dir" "$RED"
    return 1
  }

  log "[$package_name] 패키지 검증 시작..." "$YELLOW"

  # Pub 캐시 정리 (선택 사항)
  flutter pub cache repair

  # 의존성 가져오기
  flutter pub get || {
    log "[$package_name] 의존성 가져오기 실패" "$RED"
    return 1
  }

  # 코드 분석
  flutter analyze || {
    log "[$package_name] 코드 분석 실패" "$RED"
    return 1
  }

  # 테스트 실행
  flutter test || {
    log "[$package_name] 테스트 실패" "$RED"
    return 1
  }

  log "[$package_name] 패키지 검증 완료" "$GREEN"
  return 0
}

# 함수: 패키지 배포
publish_package() {
  local package_dir="$1"
  local package_name="$2"

  cd "$package_dir" || {
    log "디렉토리 이동 실패: $package_dir" "$RED"
    return 1
  }

  log "[$package_name] 배포 시작..." "$YELLOW"

  # Dry run으로 먼저 체크
  flutter pub publish --dry-run || {
    log "[$package_name] Dry run 실패" "$RED"
    return 1
  }

  # 실제 배포
  flutter pub publish -f || {
    log "[$package_name] 배포 실패" "$RED"
    return 1
  }

  log "[$package_name] 배포 완료" "$GREEN"
  return 0
}

# 메인 실행 흐름
main() {
  log "===== one_time_executor 패키지 배포 자동화 시작 =====" "$GREEN"

  # 1. 코어 패키지 배포
  log "1. 코어 패키지 배포 시작" "$YELLOW"

  validate_package "$CORE_PACKAGE_DIR" "one_time_executor" || {
    log "코어 패키지 검증 실패. 배포 중단." "$RED"
    exit 1
  }

  publish_package "$CORE_PACKAGE_DIR" "one_time_executor" || {
    log "코어 패키지 배포 실패. 배포 중단." "$RED"
    exit 1
  }

  log "코어 패키지 배포 완료. 60초 대기..." "$GREEN"
  sleep 60  # pub.dev에 패키지가 등록되는 시간 기다림

  # 2. 어댑터 패키지 배포
  log "2. 어댑터 패키지 배포 시작" "$YELLOW"

  # SharedPreferences 어댑터
  ADAPTER_DIR="$ADAPTERS_DIR/one_time_executor_shared_preferences"
  validate_package "$ADAPTER_DIR" "one_time_executor_shared_preferences" || {
    log "SharedPreferences 어댑터 검증 실패." "$RED"
    exit 1
  }

  publish_package "$ADAPTER_DIR" "one_time_executor_shared_preferences" || {
    log "SharedPreferences 어댑터 배포 실패." "$RED"
    exit 1
  }

  # Hive 어댑터
  ADAPTER_DIR="$ADAPTERS_DIR/one_time_executor_hive"
  validate_package "$ADAPTER_DIR" "one_time_executor_hive" || {
    log "Hive 어댑터 검증 실패." "$RED"
    exit 1
  }

  publish_package "$ADAPTER_DIR" "one_time_executor_hive" || {
    log "Hive 어댑터 배포 실패." "$RED"
    exit 1
  }

  # SecureStorage 어댑터
  ADAPTER_DIR="$ADAPTERS_DIR/one_time_executor_secure_storage"
  validate_package "$ADAPTER_DIR" "one_time_executor_secure_storage" || {
    log "SecureStorage 어댑터 검증 실패." "$RED"
    exit 1
  }

  publish_package "$ADAPTER_DIR" "one_time_executor_secure_storage" || {
    log "SecureStorage 어댑터 배포 실패." "$RED"
    exit 1
  }

  log "===== 모든 패키지 배포 완료 =====" "$GREEN"
  log "로그 파일 위치: $LOG_FILE" "$YELLOW"
}

# 스크립트 실행
main
