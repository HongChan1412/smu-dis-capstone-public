#!/bin/bash

#<<6>>------------------------------------------------------------------------------------------------
echo
echo "-------------------------------------------------------------------------"
echo "6. 파일 및 디렉터리 소유자 설정 "
echo "-------------------------------------------------------------------------"

echo "소유자나 그룹이 없는 파일 또는 디렉터리를 찾고 있습니다..."

# 시스템 전체에서 소유자나 그룹이 없는 파일 또는 디렉터리를 찾음
result=$(sudo find / -nouser -o -nogroup 2>/dev/null)

if [ -z "$result" ]; then
    echo "소유자나 그룹이 없는 파일 또는 디렉터리가 없습니다."
else
    echo "소유자나 그룹이 없는 파일 또는 디렉터리를 삭제합니다..."
    # 소유자나 그룹이 없는 파일 또는 디렉터리 삭제
    echo "$result" | xargs sudo rm -rf
    echo "삭제가 완료되었습니다."
fi

echo 
