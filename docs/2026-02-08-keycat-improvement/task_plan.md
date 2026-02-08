# Task Plan: KeyCat 대규모 개선 프로젝트

## Goal
프로토타입 수준의 KeyCat macOS 메뉴바 단축키 뷰어를 실제 활용 가능한 완성도 높은 앱으로 개선한다. YAML 기반 단축키 관리 강화, 와이드 뷰 완성, UX 개선, 실용 기능 추가를 통해 개발자가 매일 사용하는 도구로 만든다.

## Current Phase
All phases complete

## Phases

### Phase 1: 핵심 구조 안정화 & YAML 관리 강화
> YAML 파일만 넣으면 완벽하게 동작하는 기반 만들기

- [x] YAML 유효성 검증 서비스 (`YAMLValidator`) 구현
- [x] YAML 로드 에러를 UI에 표시하는 시스템 구축
- [x] FileWatcher 개선: 디바운싱 추가 (0.5초)
- [x] config.yaml 자동 생성 로직 추가
- [x] 번들 YAML 파일 초기 복사 기능 (InitialSetup)
- [x] YAMLValidatorTests 9개 작성 및 통과
- **Status:** complete

### Phase 2: 와이드 뷰 완성 & 뷰 전환 개선
> 화면 80%를 채우는 넓은 보기로 모든 단축키를 한눈에

- [x] WideContentView: 앱 필터 칩 탭바, Escape 닫기, Cmd+F 검색
- [x] WideGridView: 빈 결과 ContentUnavailableView, 패딩 개선
- [x] AppColumnView: 아이콘 박스, prefix 뱃지, hover 효과
- [x] 뷰 전환 UX: 앱 필터, Escape 닫기, xmark 닫기 버튼
- [x] WindowManager: 다중 모니터(마우스 커서 기준), 프레임 유효성, toggle()
- **Status:** complete

### Phase 3: 프로그램 순서 & config.yaml 관리
> 사용자가 원하는 순서로 앱을 정렬하고 쉽게 관리

- [x] tab_order 기능 안정화 (이미 정상 동작 확인)
- [x] config.yaml 관리 UX: "설정 편집" 버튼 추가, config.yaml 자동 생성
- [x] YAML 폴더 접근성: 한국어 레이블, 파일 목록 팝오버, 툴팁
- **Status:** complete

### Phase 4: UX 개선 & 실용 기능
> 매일 사용할 때 필요한 편의 기능들

- [x] 단축키 클릭 시 클립보드 복사 (체크마크 애니메이션 피드백)
- [x] Cmd+1~9 탭 전환, Cmd+F 검색 포커스
- [x] 카테고리 접기/펼치기 상태 UserDefaults 저장/복원
- [x] 토스트 알림 시스템 (ToastView + AppState.showToast)
- **Status:** complete

### Phase 5: 외형 & 마무리
> 완성도 높은 외형과 안정성

- [x] KeyFormatter Backspace 버그 수정 (symbolMap 순서 재정렬)
- [x] Launch at Login 기능 (SMAppService + SettingsFooterView 토글)
- [x] 치트시트 내보내기 (Markdown + NSSavePanel)
- [x] 전체 테스트 보강 (44 → 64개, MarkdownExporter/ToastMessage/KeyFormatter 추가)
- [x] 빌드 & 배포 준비 (Info.plist 확인, README 업데이트, Release 빌드 성공)
- **Status:** complete

## Key Questions
1. Launch at Login은 SMAppService vs LaunchAgent 어떤 방식? → macOS 14+ 타겟이므로 SMAppService 권장
2. YAML 에러 표시는 모달 vs 인라인? → 인라인 배지 + 클릭 시 상세 (비방해적)
3. 번들 YAML을 사용자 디렉토리에 복사할 타이밍? → 첫 실행 시 자동 + 메뉴에서 수동
4. 와이드 뷰에서 앱 필터링은 탭 방식 vs 체크박스? → 검색 기반 필터 (탭은 compact에서만)

## Decisions Made
| Decision | Rationale |
|----------|-----------|
| 5개 Phase로 나눔 | 핵심 기반 → 뷰 → 설정 → UX → 마무리 순서로 의존성 최소화 |
| 즐겨찾기 기능은 제외 | 현 스코프에서 오버엔지니어링. 단축키 뷰어의 핵심 가치에 집중 |
| 충돌 감지 기능 제외 | 앱 간 단축키 충돌은 의미 없음 (각 앱 독립적). 복잡도 대비 가치 낮음 |
| 메뉴바 뱃지 제외 | macOS 메뉴바 아이콘에 뱃지는 가독성 저하. 불필요한 시각적 노이즈 |
| 인라인 에러 표시 | 모달은 방해적. Footer에 에러 뱃지 → 클릭 시 상세 내용이 가장 자연스러움 |
| SMAppService 사용 | macOS 14+ 타겟이므로 최신 API 사용. LaunchAgent 대비 코드 간결 |
| Markdown 내보내기 우선 | PDF는 렌더링 복잡. Markdown은 단순하고 개발자 친화적 |

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| (아직 없음) | - | - |

## Notes
- 각 Phase는 독립적으로 빌드 & 테스트 가능하도록 설계
- Phase 1 완료 후 반드시 기존 테스트 통과 확인
- 한국어 UI 유지, 코드 주석/변수명은 영어
- 사용자 피드백에 따라 Phase 4~5 우선순위 조정 가능
