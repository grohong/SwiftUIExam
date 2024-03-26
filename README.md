# 홍성호 SKT 과제

## 개발환경

### 개발 스펙
* [x] Open Source 사용 하지 않았습니다
* [x] Combine 사용
* [x] SwiftUI 기반으로 구현 (iOS14 버전에서 collectionView기반으로 photoListView 구현)
* [x] MVVM 기반으로 구현

### OS 최소 버전
* [x] iOS14

## 기능

### Image List
* [x] Portrait : Image List (1열 이미지 리스트)
* [x] Landscape : Grid Image List (2열 이미지 리스트)
* [x] Image paging, infinite scroll (무한 스크롤 구현)
* [x] pull to refresh

### 검색 기능
* [x] Author 기반 검색 (이미 받아온 List내에서 검색)
* [x] 자동완성 기능 (검색시에 List내에 Author List 보이도록 설정)

### Image cache
* [x] Memory Cache
* [x] Disk Cache

### Detail View
* [x] 이미지와 Author 정보 노출
* [x] Detail View에선 원본 사진을 보도록 설정

## 테스트 요소

### Network
* [x] API 설정 테스트
* [x] Model 파싱 테스트

### Cache
* [x] 캐쉬 된 이미지 불러오는지 테스트

### ViewModel
* [x] 네트워크 처리 테스트
* [x] pullToRefresh 기능 테스트
* [x] 검색 관련 기능 테스트
