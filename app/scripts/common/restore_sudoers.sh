#!/bin/bash

# sudoers 파일 복구
cp /etc/sudoers.bak /etc/sudoers

# 백업 파일 삭제 (선택사항)
rm /etc/sudoers.bak
