#!/bin/bash
#5번 조치
change_root_permission() {
    # 기대되는 권한
    local expected_permission="550"
    # 현재 root 디렉터리의 권한
    local root_permission=$(ls -ld /root | awk '{print $1}')

    # 현재 권한이 기대되는 권한과 다른 경우에만 변경
    if [ "$root_permission" != "$expected_permission" ]; then
        sudo chmod $expected_permission /root
        echo "root 디렉터리 권한이 변경되었습니다."
    else
        echo "root 디렉터리 권한이 이미 안전한 상태입니다."
    fi
}

change_root_permission
