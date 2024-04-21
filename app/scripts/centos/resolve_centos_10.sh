#!/bin/bash

#<<10>>------------------------------------------------------------------------------------------------
echo
echo "-------------------------------------------------------------------------"
echo "10. /etc/(x)inetd.conf 파일 소유자 및 권한 설정"
echo "-------------------------------------------------------------------------"


# /etc/xinetd.conf 파일 소유자 및 권한 설정
if [ -f /etc/xinetd.conf ]; then
    echo "xinetd.conf 파일이 존재합니다."
    chown root:root /etc/xinetd.conf
    chmod 600 /etc/xinetd.conf
    echo "xinetd.conf 파일 소유자 및 권한이 설정되었습니다."
else
    echo "xinetd.conf 파일이 존재하지 않습니다."
fi

# /etc/xinetd.d/ 디렉터리 내 파일 소유자 및 권한 설정
if [ -d /etc/xinetd.d ]; then
    echo "/etc/xinetd.d/ 폴더가 존재합니다."
    chown root:root /etc/xinetd.d/*
    chmod 600 /etc/xinetd.d/*
    echo "/etc/xinetd.d/ 폴더 내 파일 소유자 및 권한이 설정되었습니다."
else
    echo "/etc/xinetd.d 폴더가 존재하지 않습니다."
fi

# 소유자나 그룹이 없는 파일 및 디렉터리 찾기 및 삭제
echo "소유자나 그룹이 없는 파일 및 디렉터리를 검색 후 삭제합니다..."
sudo find / -nouser -exec echo "소유자가 없는 파일/디렉터리: {}" \; -exec rm -rf {} \;
sudo find / -nogroup -exec echo "그룹이 없는 파일/디렉터리: {}" \; -exec rm -rf {} \;
echo "처리가 완료되었습니다."

echo 
