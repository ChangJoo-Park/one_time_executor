#!/bin/bash

# 버전 업데이트 스크립트
# 사용법: ./version_bump.sh [새 버전]
# 예: ./version_bump.sh 0.0.2

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# 함수: 메시지 출력
print_message() {
  local message="$1"
  local color="$2"
  echo -e "${color}${message}${NC}"
}

# 인자 검사
if [ $# -ne 1 ]; then
  print_message "오류: 새 버전을 입력해주세요." "$RED"
  print_message "사용법: ./version_bump.sh [새 버전]" "$YELLOW"
  print_message "예: ./version_bump.sh 0.0.2" "$YELLOW"
  exit 1
fi

NEW_VERSION="$1"

# 함수: pubspec.yaml 파일의 버전 업데이트
update_pubspec_version() {
  local pubspec_file="$1"
  local package_name="$2"

  # pubspec.yaml 파일이 있는지 확인
  if [ ! -f "$pubspec_file" ]; then
    print_message "오류: $pubspec_file 파일을 찾을 수 없습니다." "$RED"
    return 1
  fi

  # 버전 라인 업데이트
  sed -i '' "s/^version: .*/version: $NEW_VERSION/" "$pubspec_file"

  print_message "[$package_name] 버전 업데이트: $NEW_VERSION" "$GREEN"
  return 0
}

# 함수: CHANGELOG.md 파일에 새 버전 항목 추가
update_changelog() {
  local changelog_file="$1"
  local package_name="$2"

  # CHANGELOG.md 파일이 있는지 확인
  if [ ! -f "$changelog_file" ]; then
    print_message "오류: $changelog_file 파일을 찾을 수 없습니다." "$RED"
    return 1
  }

  # 현재 날짜
  local today=$(date +"%Y-%m-%d")

  # 새 버전 항목을 CHANGELOG.md 파일 상단에 추가
  local temp_file=$(mktemp)
  echo -e "## $NEW_VERSION - $today\n\n* TODO: 변경 사항을 입력하세요.\n" > "$temp_file"
  cat "$changelog_file" >> "$temp_file"
  mv "$temp_file" "$changelog_file"

  print_message "[$package_name] CHANGELOG 업데이트: $NEW_VERSION" "$GREEN"
  return 0
}

# 함수: 패키지 버전 업데이트
update_package_version() {
  local package_dir="$1"
  local package_name="$2"

  # pubspec.yaml 업데이트
  update_pubspec_version "$package_dir/pubspec.yaml" "$package_name" || return 1

  # CHANGELOG.md 업데이트
  update_changelog "$package_dir/CHANGELOG.md" "$package_name" || return 1

  return 0
}

# 설정
ROOT_DIR=$(pwd)

# 1. 코어 패키지 버전 업데이트
print_message "1. 코어 패키지 버전 업데이트 중..." "$YELLOW"
update_package_version "$ROOT_DIR" "one_time_executor" || {
  print_message "코어 패키지 버전 업데이트 실패." "$RED"
  exit 1
}

# 어댑터 패키지 디렉토리 목록
ADAPTER_PACKAGES=(
  "one_time_executor_shared_preferences"
  "one_time_executor_hive"
  "one_time_executor_secure_storage"
)

# 2. 어댑터 패키지 버전 업데이트
print_message "2. 어댑터 패키지 버전 업데이트 중..." "$YELLOW"

for adapter in "${ADAPTER_PACKAGES[@]}"; do
  adapter_dir="$ROOT_DIR/packages/$adapter"

  update_package_version "$adapter_dir" "$adapter" || {
    print_message "$adapter 패키지 버전 업데이트 실패." "$RED"
    exit 1
  }

  # 어댑터 패키지의 core 의존성도 업데이트
  sed -i '' "s/one_time_executor: .*/one_time_executor: ^$NEW_VERSION/" "$adapter_dir/pubspec.yaml"
  print_message "[$adapter] core 의존성 업데이트: ^$NEW_VERSION" "$GREEN"
done

# 3. 예제 앱 업데이트
print_message "3. 예제 앱 의존성 업데이트 중..." "$YELLOW"
example_pubspec="$ROOT_DIR/example/pubspec.yaml"

if [ -f "$example_pubspec" ]; then
  # 코어 패키지 의존성 업데이트
  sed -i '' "s/one_time_executor: .*/one_time_executor: ^$NEW_VERSION/" "$example_pubspec"

  # 어댑터 패키지 의존성 업데이트
  for adapter in "${ADAPTER_PACKAGES[@]}"; do
    sed -i '' "s/$adapter: .*/$adapter: ^$NEW_VERSION/" "$example_pubspec"
  done

  print_message "예제 앱 의존성 업데이트 완료" "$GREEN"
else
  print_message "경고: 예제 앱 pubspec.yaml 파일을 찾을 수 없습니다." "$YELLOW"
fi

print_message "\n===== 모든 패키지 버전이 $NEW_VERSION으로 업데이트되었습니다 =====" "$GREEN"
print_message "각 패키지의 CHANGELOG.md 파일에 변경 사항을 입력하세요." "$YELLOW"
