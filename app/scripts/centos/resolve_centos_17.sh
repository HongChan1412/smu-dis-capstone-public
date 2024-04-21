#!/bin/bash

#<<17>>------------------------------------------------------------------------------------------------
echo
echo "-------------------------------------------------------------------------"
echo "17. /root/.rhosts, hosts.equiv 사용 금지 "
echo "-------------------------------------------------------------------------"

# 시스템 전체에서 .rhosts 파일 검색 및 제거
echo "시스템 전체에서 .rhosts 파일 검색 중..."
find / -type f -name .rhosts 2>/dev/null | while read file; do
    echo "${file} 파일을 제거합니다."
    rm -f "${file}"
done

# 시스템 전체에서 hosts.equiv 파일/디렉터리 검색
echo "시스템 전체에서 hosts.equiv 검색 중..."
find / -name hosts.equiv 2>/dev/null | while read item; do
    if [ -d "${item}" ]; then
        echo "${item} 디렉터리를 제거합니다."
        rm -rf "${item}"
    elif [ -f "${item}" ]; then
        echo "${item} 파일을 제거합니다."
        rm -f "${item}"
    fi
done

echo "모든 .rhosts 및 hosts.equiv 관련 항목이 제거되었습니다."

echo 
