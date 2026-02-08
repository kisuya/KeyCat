# KeyCat

macOS 메뉴바에 상주하면서 터미널 도구의 단축키를 빠르게 검색/조회할 수 있는 네이티브 앱.

tmux, Neovim, yazi, lazygit 등의 단축키를 외울 필요 없이, 메뉴바 아이콘 클릭 한 번으로 확인할 수 있다.

```
┌──────────────────────────────────┐
│ 🔍 Search shortcuts...          │
├──────────────────────────────────┤
│ [tmux] [neovim] [yazi] [lazygit]│
├──────────────────────────────────┤
│ prefix = ⌃a                     │
├──────────────────────────────────┤
│ 세션                            │
│  ⌃a d    detach (세션 유지)      │
│  ⌃a s    세션 목록/전환          │
│                                 │
│ 윈도우                           │
│  ⌃a c    새 윈도우              │
│  ⌃a n    다음 윈도우             │
├──────────────────────────────────┤
│ 📁 Config Folder     ⏻ Quit    │
└──────────────────────────────────┘
```

## 주요 기능

- **메뉴바 상주** — Dock 아이콘 없이 상태바에서만 동작
- **탭 전환** — tmux, neovim, yazi, lazygit 간 빠른 전환
- **실시간 검색** — 키, 설명, 카테고리 이름으로 대소문자 무관 필터링
- **키 기호 변환** — `Ctrl+` → `⌃`, `Shift+` → `⇧`, `Cmd+` → `⌘` 자동 변환
- **YAML 기반 관리** — 사용자가 직접 단축키 추가/수정 가능
- **자동 리로드** — `~/.config/keycat/` 변경 시 앱 재시작 없이 반영
- **와이드 뷰** — 화면 80%를 채우는 넓은 보기 (모든 앱 단축키를 한눈에)
- **클릭 복사** — 단축키를 클릭하면 클립보드에 복사
- **글로벌 단축키** — `Ctrl+Shift+K` (기본값, config.yaml에서 변경 가능)
- **YAML 유효성 검증** — 오류 시 인라인 배지 + 상세 팝오버
- **카테고리 접기/펼치기** — 접힌 상태 자동 저장/복원
- **Markdown 내보내기** — 단축키 치트시트를 Markdown 파일로 내보내기
- **Launch at Login** — 로그인 시 자동 실행 설정
- **다중 모니터 지원** — 마우스 커서 기준 화면에 와이드 뷰 표시

## 요구사항

- macOS 14 (Sonoma) 이상
- Swift 5.9+

## 설치

### 소스에서 빌드

```bash
git clone https://github.com/kisuya/KeyCat.git
cd KeyCat

# .app 번들 생성
./Scripts/package-app.sh

# /Applications에 설치
./Scripts/install.sh
```

설치 후 `Cmd+Space` → "KeyCat"으로 실행.

### 개발 모드

```bash
swift run KeyCat
```

## 키보드 단축키

| 단축키 | 동작 |
|--------|------|
| `Ctrl+Shift+K` | 글로벌 토글 (config.yaml에서 변경 가능) |
| `Cmd+1~9` | 탭 전환 |
| `Cmd+F` | 검색 포커스 |
| `Cmd+E` | 넓은 보기 전환 |
| `←` `→` | 이전/다음 탭 |
| `↑` `↓` | 단축키 선택 |
| `Enter` | 선택한 단축키 복사 |
| `Esc` | 와이드 뷰 닫기 |

## config.yaml

`~/.config/keycat/config.yaml`에서 앱 정렬 순서, 글로벌 단축키, 기본 뷰를 설정할 수 있다.

```yaml
tab_order:
  - tmux
  - neovim
  - yazi
  - lazygit

hotkey:
  key: k
  modifiers:
    - control
    - shift

preferences:
  default_view: compact   # compact 또는 wide
```

## 사용자 단축키 추가

`~/.config/keycat/` 디렉토리에 YAML 파일을 추가하면 자동으로 반영된다.

같은 `app` 이름의 파일이 있으면 번들 기본값을 덮어쓴다.

```yaml
app: my-tool
prefix: "Ctrl+b"
icon: "terminal"        # SF Symbol 이름
categories:
  - name: "기본"
    shortcuts:
      - key: "prefix + d"
        desc: "detach"
      - key: "prefix + c"
        desc: "새로 만들기"
```

### YAML 필드

| 필드 | 필수 | 설명 |
|------|------|------|
| `app` | O | 탭에 표시될 프로그램 이름 |
| `prefix` | X | 공통 접두키 (예: `Ctrl+a`) |
| `icon` | X | SF Symbol 이름 (기본: `app.dashed`) |
| `categories[].name` | O | 카테고리 이름 |
| `categories[].shortcuts[].key` | O | 단축키 (`prefix + x` 형태 가능) |
| `categories[].shortcuts[].desc` | O | 단축키 설명 |

## 프로젝트 구조

```
Sources/KeyCat/
├── App/            # 진입점, AppDelegate, AppState
├── Models/         # Shortcut, ShortcutFile, AppConfig, ViewMode
├── Services/       # YAML 로더/검증, 검색 엔진, 파일 감시, 설정, 내보내기
├── Views/          # SwiftUI 뷰 (팝오버, 와이드, 검색바, 탭, 토스트)
├── Utilities/      # 상수, 키 포맷터
└── Resources/
    └── Defaults/   # 번들 YAML + config.yaml
```

## 기본 포함 단축키

| 프로그램 | 카테고리 |
|---------|---------|
| **tmux** | 세션, 윈도우, 패인, 복사 모드, 기타 |
| **neovim** | 모드 전환, 이동, 편집, 검색/치환, 파일/버퍼, 윈도우 분할 |
| **yazi** | 탐색, 파일 조작, 선택, 탭, 표시 |
| **lazygit** | 글로벌, 파일, 브랜치, 커밋, 스태시, 리모트 |

## 기술 스택

- **Swift + SwiftUI** (네이티브 macOS)
- **AppKit** (NSStatusItem + NSPopover)
- **Yams** (YAML 파싱)
- **SPM** (패키지 관리)

## 라이선스

MIT
