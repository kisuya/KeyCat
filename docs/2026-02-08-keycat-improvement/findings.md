# Findings & Decisions

## Requirements
### 사용자 명시 요구사항
- YAML 파일만 넣으면 단축키가 자동 추가되는 구조 강화
- 화면 80%를 채우는 와이드 뷰로 모든 단축키 한눈에 보기
- 프로그램 순서를 config.yaml에서 변경 가능
- YAML 폴더 쉽게 접근 (Finder 열기 + 경로 복사)
- Claude Code에서 경로 쉽게 확인할 수 있도록 경로 복사 버튼

### 추가 기획 기능 (우선순위 높음)
- 단축키 클릭 시 클립보드 복사
- 빠른 앱 전환 (Cmd+1~9)
- YAML 에러 시 친절한 UI 피드백
- 카테고리 접기 상태 저장
- Launch at Login
- 치트시트 마크다운 내보내기

### 제외된 기능 (이유 포함)
- 즐겨찾기/북마크: 단축키 뷰어의 핵심 가치와 거리. 복잡도 증가
- 단축키 충돌 감지: 앱 간 독립적 단축키이므로 의미 없음
- 메뉴바 뱃지: 가독성 저하. macOS 메뉴바 UX 관행에 맞지 않음
- PDF 내보내기: 렌더링 복잡도 대비 Markdown이 더 실용적

## Research Findings

### 현재 코드베이스 분석 결과

#### 모델 구조
- `Shortcut`: key + desc (Codable, Equatable)
- `ShortcutCategory`: name + shortcuts[]
- `ShortcutFile`: app + prefix? + icon? + categories[]
- `AppConfig`: tabOrder + hotkey + preferences (default_view)
- `ViewMode`: compact | wide

#### YAML 파일 형식
```yaml
app: tmux
prefix: "Ctrl+a"      # optional
icon: "terminal"       # optional SF Symbol
categories:
  - name: "세션"
    shortcuts:
      - key: "prefix + d"
        desc: "detach (세션 유지하고 나가기)"
```

#### 서비스 계층
- `YAMLLoader`: 번들 + 사용자 파일 로드, 사용자 파일이 번들 오버라이드
- `ConfigLoader`: config.yaml 로드, 번들 기본값 폴백
- `ShortcutStore`: @Observable, orderedFiles/filteredFile 등 computed 제공
- `FileWatcher`: DispatchSource, write/delete/rename 감지
- `HotkeyManager`: NSEvent 글로벌/로컬 모니터
- `SearchEngine`: key/desc/category name 필터링

#### 뷰 구조
- `PopoverContentView`: 420x560 팝오버 (Compact)
- `WideContentView`: NSPanel 기반 와이드 뷰
- `WideGridView`: LazyVGrid, min 300pt 컬럼
- `AppColumnView`: 앱별 카드
- `WindowManager`: NSPanel 생성/관리, 80% 화면, UserDefaults 위치 저장
- `SettingsFooterView`: 폴더 열기, 경로 복사, 새 템플릿, 뷰 전환, 종료

#### 상수 (Constants.swift)
- 팝오버: 420x560
- 와이드 뷰: 80% 화면, min 300pt 컬럼
- 설정 경로: ~/.config/keycat/
- 메뉴바 아이콘: keyboard.fill

#### 테스트 현황
- 6개 테스트 파일, Swift Testing 프레임워크
- ShortcutStore(11), ConfigLoader(4), YAMLLoader(6), TemplateGenerator(3), KeyFormatter(6), SearchEngine(7)

### 개선 필요 사항 분석

1. **YAML 유효성 검증 없음**: 잘못된 YAML → 조용한 실패. 사용자에게 피드백 없음
2. **FileWatcher 디바운싱 없음**: 에디터 저장 시 여러 번 트리거 가능
3. **와이드 뷰 기본 구현**: 레이아웃/디자인 개선 필요
4. **에러 처리 미흡**: YAML 파싱 에러가 사용자에게 전달되지 않음
5. **뷰 전환 UX**: 전환이 갑작스러움, Escape 닫기 등 미구현
6. **카테고리 접기 상태 휘발**: 앱 재시작 시 초기화

## Technical Decisions
| Decision | Rationale |
|----------|-----------|
| @Observable 유지 | iOS 17+/macOS 14+ 타겟에 적합. ObservableObject 대비 보일러플레이트 적음 |
| DispatchSource FileWatcher 유지 | FSEvents보다 단순하고 단일 디렉토리 감시에 충분 |
| SMAppService for Login Item | macOS 14+ 최신 API, 코드 간결 |
| 토스트는 커스텀 구현 | 외부 의존성 최소화 원칙. 간단한 overlay로 충분 |
| Markdown 내보내기 | String 조합으로 충분, 외부 라이브러리 불필요 |

## Issues Encountered
| Issue | Resolution |
|-------|------------|
| (아직 없음) | - |

## Resources
- 프로젝트 경로: /Users/kisuya/Dev/KeyCat
- 설정 경로: ~/.config/keycat/
- 번들 YAML: Sources/KeyCat/Resources/Defaults/
- 의존성: Yams 5.1.0+
- 타겟: Swift 5.9, macOS 14+
