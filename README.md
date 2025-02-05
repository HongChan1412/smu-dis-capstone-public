# 보안가이드라인 기반의 중소기업 서버 취약점 점검 및 교체

## 개발 동기

### 중소기업을 대상으로 서버 취약점 점검을 진행하는 이유

| 1 | 2 |
|:-:|:-:|
| ![image](https://github.com/user-attachments/assets/c1bf385e-b7fe-41ef-b747-e682b514ac30) | ![image](https://github.com/user-attachments/assets/0520e1b8-5661-41e4-bbce-8c42ecd3e472) |

> 다음과 같은 이유들로 'IT 보안가이드라인'을 기반의 자동으로 서버 취약점을 점검하고 조치해주는 시스템을 제작하여 <br>
> 사이버 공격의 피해 비중이 높은 중소 기업의 서버를 대상으로 서버 취약점을 관리를 해주는 서비스를 제공 하고 <br>
> 사전에 서버 취약점을 줄이고 피해를 방지하고자 해당 프로젝트를 진행

## 개발 환경
### Tech
![Python](https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=flat-square&logo=fastapi&logoColor=white)
![Shell Script](https://img.shields.io/badge/Shell_Script-89E051?style=flat-square&logo=gnu-bash&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=flat-square&logo=javascript&logoColor=black)
![HTML](https://img.shields.io/badge/HTML-E34F26?style=flat-square&logo=html5&logoColor=white)
![Trivy](https://img.shields.io/badge/Trivy-5C6BC0?style=flat-square&logo=trivy&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat-square&logo=github&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat-square&logo=github-actions&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)
![DockerHub](https://img.shields.io/badge/DockerHub-0db7f2?style=flat-square&logo=dockerhub&logoColor=white)
![NCP](https://img.shields.io/badge/NCP-3DDC84?style=flat-square&logo=ncp&logoColor=white)

### CI/CD
![image](https://github.com/user-attachments/assets/4fc3ae3f-d0de-4723-90e5-c2ce5ffeb60c)

> 1. 프로젝트의 코드를 CI/CD 과정을 거쳐 DockerHub에 프로젝트 최신 이미지로 빌드하여 저장 <br>
> 2. 배포 대상 서버인 점검 서버에 자동으로 프로젝트의 최신 이미지를 다운로드 (PULL) <br>
> 3. 프로젝트의 최신 이미지로 컨테이너를 시작해 최신 상태의 코드를 실행 <br>

**이과정을 통해 개발에서 배포까지의 전 과정이 자동화되며, CI/CD 파이프라인의 도입으로 프로젝트 안정성과 배포 과정을 더 빠르고 효율적으로 수행**

## 흐름도
![image](https://github.com/user-attachments/assets/32571c2b-00c7-4d30-bf37-b0c308c0717a)

## 주요 기능

### 서버 보안 설정

#### 점검 사항
> 1. 계정관리 <br>
> 2. 파일 및 디렉터리 관리 <br>
> 3. 서비스 관리 및 디렉터리 관리 <br>
> 4. 패치 & 로그 관리 <br>

#### 점검 코드 
| 1 | 2 |
|:-:|:-:|
| ![image](https://github.com/user-attachments/assets/86a975c3-3984-4df1-b8f5-4a9512f93c1e) | ![image](https://github.com/user-attachments/assets/bc4337b9-f880-4103-97a5-476e2a72b652) |

> 정규식과 sed, shell을 조합해 서버내에서 점검 및 조치 진행

### Docker image 점검 및 조치

#### Docker image 점검 이유

| 1 | 2 |
|:-:|:-:|
| ![image](https://github.com/user-attachments/assets/da67ceda-62e7-4cae-8efd-536a56d57c6e) | ![image](https://github.com/user-attachments/assets/b1c5363a-66ab-4a8e-b277-c3c05930911f) |

> Docker를 사용하는 기업이 점점 늘어가는 추세에 비해 <br>
> 취약한 Docker image는 계속 증가하고 있으며 공식 이미지의 절반 이상이 이미지가 취약점을 가진 이미지임을 확인 <br>

**이러한 이미지의 사용으로 Docker 사용으로 인해 취약한 환경이 구성될 수 있음**

#### Docker image 점검 과정
> 1. 클라이언트 서버내에 존재하는 image 목록을 읽어 해당 목록을 개발서버로 반환 <br>
> 2. Trivy를 통해 이미지목록을 순서대로 점검 <br>

#### Docker image 점검 조치
> 1. 패키지 업데이트 진행 및 최소 권한 원칙 적용한 Dockerfile 작성 <br>
> 2. Dockerfile을 Build하여 image 생성 후 생성된 image를 Trivy로 점검하여 조치 정보 제공 <br>
> 3. 조치된 image를 압축한 tar 파일을 제공 <Br>

### 취약한 SW Package 점검

#### 취약한 SW Package 점검 이유

| 1 | 2 |
|:-:|:-:|
| ![image](https://github.com/user-attachments/assets/4e6a0803-f6b9-4299-9863-a2216ec722be) | ![image](https://github.com/user-attachments/assets/93c6f8a7-13bf-40cd-8a02-b3bae905904c) |

이런 취약점 발견은 소프트웨어 및 라이브러리의 지속적인 모니터링과 업데이트의 중요성을 보여줌
**취약점에 대한 정보를 신속하게 파악하고, 적절한 대응 조치를 취함으로써 시스템의 보안을 강화해야함**

#### 취약한 SW 패키지 점검 과정
![image](https://github.com/user-attachments/assets/531cc7ea-b8c3-46e0-88ba-15e518990b5f)

> 1. 서버에 설치된 패키지의 소프트웨어명과 버전의 목록을 추출 <br>
> 2. 소프트웨어의 버전에 맞는 CPE 알아내기 <br>
> 3. 알아낸 CPE로 CVE정보 알아내기 <br>

### 보고서 자동 생성
![image](https://github.com/user-attachments/assets/beba55b1-ad53-4983-adfe-9d0ae9d5797e)

> 서버 보안 설정, Docker image, SW Package 점검 후 동적으로 보고서를 생성 <br>
> pdf로 다운받을 수 있도록 기능 추가
