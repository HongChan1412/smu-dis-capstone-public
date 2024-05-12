#!/bin/bash

# sudoers 파일 백업
cp /etc/sudoers /etc/sudoers.bak

# sudoers 파일에 내용 추가
echo "{USERNAME} ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo "{USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
