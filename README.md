<img width="937" alt="스크린샷 2024-08-04 오후 9 47 36" src="https://github.com/user-attachments/assets/2ac30939-53b5-49cf-9961-b271edc034bf">

[42CM 개발 및 학습일지(Click.ᐟ)](https://velog.io/@hwyjj/series/%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-42CM)

<br/>

## 목차
- [프로젝트 소개](#프로젝트-소개)
- [팀 구성 및 역할](#팀-구성-및-역할)
- [기술 스택](#기술-스택)
- [주요 기능 실행 화면](#주요-기능-실행-화면)
- [주요 기술](#주요-기술)
- [학습](#학습)
- [트러블슈팅](#트러블슈팅)
- [일정 관리](#일정-관리)
- [회고](#회고)
- [유지보수 계획](#유지보수-계획)

<br/><br/>

## 프로젝트 소개

### **42CM**

사용자의 위치를 기반으로 소통하고, 주변 상점의 제품을 결제할 수 있는 소셜 네트워크 서비스입니다. 

### **기능**

- 📝 게시글 업로드
- 📸 인스타그램 스토리 형식 게시글 조회
- 🗺 지도 기반으로 게시글 조회
- 🗑 게시글 삭제
- ❤️ 게시글 좋아요
- 🔍 댓글 조회
- 💬 댓글 작성
- 💳 PG사를 통한 실제 결제
- 💬 채팅 조회
- 💬 채팅 발송
- 💬 채팅 실시간 수신
- 🔍 채팅방 조회
- 👤 내 정보 조회
- 🗂 내가 작성한 게시글 조회
- 🗂 내가 좋아요한 게시글 조회
- 🔍 유저 팔로우
- 👋🏻 유저 언팔로우

<br/><br/>

## 팀 구성 및 역할

**구성원:** iOS Developer(1), Server Developer(1)

**담당 역할(휘진):** 기획, 디자인, iOS 개발

<br/><br/>

## 기술 스택

- **언어:** `Swift`
- **프레임워크:** `UIKit`
- 아키텍쳐: `MVVM`
- 반응형 프로그래밍: `RxSwift`
- **결제 시스템:** `PayGate`
- **사용한 라이브러리:**
    - `Alamofire`
    - `KingFisher`
    - `SocketIO`
    - `Realm`
    - `SnapKit`
    - `Then`
    - `Toast`
    

[아키텍쳐 및 기술 스택 선택과정 보러가기(Click.ᐟ)](https://velog.io/@hwyjj/42CM-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%EC%95%84%ED%82%A4%ED%85%8D%EC%B2%98-%EB%B0%8F-%EA%B8%B0%EC%88%A0%EC%8A%A4%ED%83%9D-%EC%84%A0%ED%83%9D-%EA%B3%BC%EC%A0%95)

<br/><br/>

## 주요 기능 실행 화면

| 로그인          | 회원가입         | 게시글 조회      |
|----------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/94e1ab64-1ef6-406a-a021-ac613be1cb94" width="360"/> | <img src="https://github.com/user-attachments/assets/739a0356-79d8-477b-9d58-24306ffd0b04" width="360"/> | <img src="https://github.com/user-attachments/assets/9c48140d-46ac-41ee-bd34-01009385bbba" width="360"/> |

| 지도 기반 게시글 조회          | 상품 결제         | 채팅      |
|----------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/0123bbc3-2ef0-40ca-b6d1-8cd25d0da304" width="360"/> | <img src="https://github.com/user-attachments/assets/49a7037a-1ba5-40aa-b5c0-efcb961a3ed4" width="360"/> | <img src="https://github.com/user-attachments/assets/8650c67c-addf-4488-8d4a-28328ceea9b6" width="360"/> |

| 게시글 업로드          | 게시글 삭제         | 댓글 조회 및 작성      |
|----------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/f8fcde28-2553-4024-96ea-d4bee155bf50" width="360"/> | <img src="https://github.com/user-attachments/assets/6a84c038-5fdf-4641-a879-6baa52e3ed1c" width="360"/> | <img src="https://github.com/user-attachments/assets/53f60fcc-a948-4edf-8b50-04812f955364" width="360"/> |

| 팔로우 / 언팔로우          | 게시글 좋아요         | 마이페이지      |
|----------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/8c1d9f48-dc24-4b20-bf70-44f64c1d534a" width="360"/> | <img src="https://github.com/user-attachments/assets/bacaaee0-986d-429a-a9a1-bbac7b2b50bf" width="360"/> | <img src="https://github.com/user-attachments/assets/d14c221f-ff10-49b9-956d-692b589df7b8" width="360"/> |

<br/><br/>

## 주요 기술

**디자인 패턴**

- ViewModel에 **Input-Output 패턴**을 적용하여 데이터의 흐름을 단방향으로 관리하였습니다.
- Router Pattern을 사용하여 네트워크 요청을 구조화하고 관리했습니다. 각 API 엔드포인트를 열거형으로 정의하고, URL, HTTP method, Parameter 및 Query String 등을 일관되고 체계적으로 설정하였습니다.
- Repository Pattern을 이용하여 Realm method를 관리해 코드 구조를 명확하게 유지하고 재사용성을 높였습니다.<br/>

**비동기 프로그래밍 및 네트워크 처리**

- 네트워크 요청의 단일 응답을 비동기적으로 처리하기 위해 RxSwift의 Single Trait를 사용하였습니다.
- 토큰 만료 시 **APIInterceptor**를 사용해 자동으로 새 토큰을 발급받아 저장하고 요청을 재시도하도록 하였습니다.
- API 통신에서 발생할 수 있는 다양한 에러를 관리하기 위해 **APIError 열거형**을 정의하고, 이를 토스트 메시지로 제공하여 UX를 개선했습니다.<br/>

**데이터 관리**

- 데이터 중복을 최소화하고 일관성을 유지하기 위해 정규화를 고려하여 Realm 모델링을 수행하였습니다.
- Realm의 List를 사용하여 1:N 관계를 구현하여 객체 간의 연관성을 효과적으로 관리했습니다.<br/>

**보안**

- 토큰과 같이 민감한 유저 정보를 안전하게 저장하기 위해 KeyChain을 사용하였습니다.<br/>

**코드 최적화 및 안정성**

- final 키워드와 접근 제어자를 사용하여 컴파일 최적화를 이루고, 코드의 안전성과 성능을 향상 시켰습니다.
- Instrument를 활용하여 메모리 누수 여부를 검토하고 최적화 작업을 수행했습니다.
- 디버깅과 실행 중 상태 분석을 위해 LLDB를 활용하여 런타임에 변수 값을 확인하고 코드 실행을 제어했습니다.

<br/><br/>

## 학습

- [민감한 유저 정보를 **KeyChain**에 담아보자](https://velog.io/@hwyjj/42CM-%EB%AF%BC%EA%B0%90%ED%95%9C-%EC%9C%A0%EC%A0%80%EC%A0%95%EB%B3%B4%EB%8A%94-KeyChain%EC%97%90-%EB%8B%B4%EC%95%84%EB%B3%B4%EC%9E%90)
- [Observable 대신 Single 사용해보기](https://velog.io/@hwyjj/42CM-Observable-%EB%8C%80%EC%8B%A0-Single-%EC%82%AC%EC%9A%A9%ED%95%B4%EB%B3%B4%EA%B8%B0)
- [오프셋 기반 페이지네이션 vs 커서 기반 페이지네이션](https://velog.io/@hwyjj/42CM-%EC%98%A4%ED%94%84%EC%85%8B-%EA%B8%B0%EB%B0%98-%ED%8E%98%EC%9D%B4%EC%A7%80%EB%84%A4%EC%9D%B4%EC%85%98-vs-%EC%BB%A4%EC%84%9C-%EA%B8%B0%EB%B0%98-%ED%8E%98%EC%9D%B4%EC%A7%80%EB%84%A4%EC%9D%B4%EC%85%98)
- [싱글톤 패턴의 장단점](https://velog.io/@hwyjj/42CM-%EC%8B%B1%EA%B8%80%ED%86%A4-%ED%8C%A8%ED%84%B4%EC%9D%98-%EC%9E%A5%EB%8B%A8%EC%A0%90)
- [로컬 DB에 채팅을 저장하는 이유(feat. Realm, Core Data)](https://velog.io/@hwyjj/%EB%A1%9C%EC%BB%AC-DB%EC%97%90-%EC%B1%84%ED%8C%85%EC%9D%84-%EC%A0%80%EC%9E%A5%ED%95%98%EB%8A%94-%EC%9D%B4%EC%9C%A0feat.RealmCoreData)
- [Network Protocol과 소켓 통신](https://velog.io/@hwyjj/Network-Protocol%EA%B3%BC-%EC%86%8C%EC%BC%93-%ED%86%B5%EC%8B%A0)
- [소켓은 언제 연결하고 끊어야 할까? 1편 (feat. App의 생명주기)](https://velog.io/@hwyjj/42CM-%EC%86%8C%EC%BC%93%EC%9D%80-%EC%96%B8%EC%A0%9C-%EC%97%B0%EA%B2%B0%ED%95%98%EA%B3%A0-%EB%81%8A%EC%96%B4%EC%95%BC-%ED%95%A0%EA%B9%8C-1%ED%8E%B8)
- [소켓은 언제 연결하고 끊어야 할까? 2편 (feat. ViewController의 생명주기)](https://velog.io/@hwyjj/%EC%86%8C%EC%BC%93%EC%9D%80-%EC%96%B8%EC%A0%9C-%EC%97%B0%EA%B2%B0%ED%95%98%EA%B3%A0-%EB%81%8A%EC%96%B4%EC%95%BC-%ED%95%A0%EA%B9%8C-2%ED%8E%B8)

<br/><br/>


## 트러블슈팅

### 의도적으로 PageViewController를 빠르게 넘길시, UI 렌더링 지연 및 Memory Leak 발생

**문제 상황**

UIPageViewController를 사용하여 게시글 조회 기능을 구현하였습니다. 이 기능은 5개씩 커서 기반 페이지네이션 방식으로 동작합니다. 그러나 사용자가 페이지를 의도적으로 빠르게 넘길 경우 UI가 제대로 렌더링되지 않는 문제가 있었습니다. 또한, Instrument를 통해 확인한 결과, 해당 기능에서 메모리 누수가 발생하고 있어 앱의 성능 저하와 비정상 종료 가능성이 있었습니다.

<img width="1161" alt="스크린샷 2024-08-04 오후 10 21 27" src="https://github.com/user-attachments/assets/df23e338-3fe6-4ccc-8a6b-78837ced2ff4">


**문제 원인**

기존 로직에서는 현재 페이지의 마지막(5번째) 게시글에 도달했을 때만 다음 페이지 데이터를 요청하도록 구현하였습니다. 이로 인해 사용자가 빠르게 PageViewController를 넘길 경우, 데이터 로딩 지연이 발생했습니다. 이는 다음 페이지 데이터를 요청하고 받아오는 동안, 사용자가 이미 다음 페이지를 넘어가고 있어 로딩이 완료되기 전에 UI가 준비되지 않았기 때문에 발생했습니다.



**해결 방법**

현재 페이지의 마지막 게시글에 도달했을 때가 아니라, 3개의 단위로 데이터를 사전 로드하는 로직을 추가하였습니다. PageViewController의 인덱스가 3의 배수일 때마다 다음 페이지 데이터를 미리 로드하도록 처리하여, UI가 제대로 렌더링되지 않는 문제와 메모리 누수 문제를 해결할 수 있었습니다.


<img width="1161" alt="스크린샷 2024-08-04 오후 10 22 05" src="https://github.com/user-attachments/assets/6b55306e-b869-454b-8218-564da7516268">

<img width="1161" alt="스크린샷 2024-08-04 오후 10 24 11" src="https://github.com/user-attachments/assets/f1af4fa2-ceae-423e-a2f6-1cbe8e97a354">



<br/><br/>

### 채팅방 전환 시 소켓 이벤트 중복 호출 문제

**문제 상황**

채팅 앱에서 채팅방을 전환할 때마다 소켓 연결 이벤트인 connect에 대한 로그가 여러 번 출력되었고, 같은 이벤트가 중복으로 처리되는 문제가 발생했습니다. 이는 중복 데이터 처리, 성능 저하, 메모리 누수 등을 초래할 수 있었습니다.<br/>

**문제 원인**

소켓을 통한 연결을 설정할 때, 이전 채팅방에서 등록된 이벤트 핸들러들이 제거되지 않은 상태로 남아 있었습니다. 이에 따라, 새로운 채팅방으로 이동하거나 새로운 소켓을 설정할 때 기존의 이벤트 핸들러가 중복으로 호출되어 동일한 이벤트에 대해 여러 번 로그가 출력되고 이벤트가 처리되었습니다.<br/>

**해결 방법**

채팅방을 나갈 때 소켓 연결을 끊는 함수에 기존 핸들러를 제거하는 코드(socket.removeAllHandlers())를 추가했습니다. 이 코드는 채팅방이 사라질 때 호출되며, 이를 통해 이전 채팅방에서 등록된 이벤트 핸들러들이 새 채팅방에서 중복 호출되지 않도록 했습니다.

<img width="333" alt="스크린샷 2024-08-04 오후 10 22 53" src="https://github.com/user-attachments/assets/e6c9d989-3ede-4366-86b4-747e14b639e6">


<br/><br/>

## 일정 관리

Jira를 활용하여 프로젝트 일정 및 작업 관리를 효율적으로 수행했습니다. 특히, 개인 프로젝트에서 스케줄 관리와 작업 추적을 위해 Jira의 이슈 트래킹 기능을 적극적으로 활용했습니다. 이를 통해 개발 과정에서 발생할 수 있는 혼란을 최소화하고, 일정을 효율적으로 조율할 수 있었습니다.

<img width="1161" alt="스크린샷 2024-08-05 오전 12 47 57" src="https://github.com/user-attachments/assets/7b976120-9a5b-4e28-ab6b-1e649d94017b">



<br/><br/>

## 회고

이번 프로젝트에서는 기존의 커스텀 Observable 구현에서 RxSwift로 전환하여 비동기 작업의 가독성과 유지보수성을 크게 향상시켰습니다. 또한, `Router` 패턴을 도입하여 네트워크 요청 관련 코드를 모듈화하고, 반복되는 코드를 줄이는 데 성공했습니다. 이러한 시도들은 코드의 일관성을 높이고, 개발 속도를 향상시켰다는 점에서 굉장히 뿌듯했습니다. 하지만 프로젝트를 진행하면서 몇 가지 아쉬운 점들도 있었습니다.<br/>

**1. 비즈니스 로직과 데이터 처리 로직의 혼재**

`ViewModel`에서 비즈니스 로직과 데이터 처리를 처리하게 했더니, ViewModel 코드가 지나치게 복잡해지는 문제가 생겼습니다. 예를 들어 로그인 파트같은 경우, 사용자가 로그인 버튼을 누르면 네트워크 요청을 보내고, 응답을 받아 처리하는 모든 과정이 ViewModel에 포함되었습니다. 이로 인해 ViewModel이 너무 많은 책임을 지게 되었고, 코드가 복잡해졌습니다. 이것 때문에 기능 수정 시 많은 부분을 수정해야 하는 상황이 자주 일어났습니다.

**2. 네트워크 요청 테스트가 어려움**

저는 `ViewController`가 `ViewModel`을 직접 생성하여 사용했습니다. 이로 인해 네트워크 요청을 테스트할 때, 실제 네트워크 호출을 피하고 모의 객체를 사용하고자 할 때 문제가 발생했습니다.

<br/>

**생각해본 해결방안**

문제들을 해결하기 위해 여러 방안을 고민하던 중, 클린 아키텍처의 필요성을 깨달았습니다. 실제로 적용하지는 않았지만, 다음과 같은 방법들이 해결책이 될 수 있겠다고 생각했습니다.

**1. 유즈케이스와 비즈니스 로직의 분리**

`SignInViewModel`과 같은 ViewModel에서 비즈니스 로직을 분리하여 유즈케이스 클래스로 관리하면 좋겠다고 생각했습니다. 예를 들어, `SignInUseCase`라는 클래스를 만들어 사용자 인증과 관련된 로직을 처리하고, ViewModel은 오직 뷰 업데이트만 담당하게 하는 것입니다. 이렇게 하면 ViewModel의 책임이 줄어들고, 코드가 더 깔끔해질 것입니다.

**2. 의존성 주입의 도입**

의존성 주입을 통해 클래스들이 필요한 의존성을 외부에서 주입받도록 설계하면, 테스트 시 모의 객체를 쉽게 사용할 수 있습니다. `ViewController`가 `ViewModel`을 외부에서 주입받도록 하면, 유닛 테스트에서 다양한 시나리오를 테스트할 수 있게 됩니다.<br/>

이러한 개선 방안들을 다음 프로젝트에서 적용해보려 합니다. 이번 프로젝트에서 경험한 문제들을 바탕으로, 더 나은 아키텍처를 설계하고 유지보수하기 쉬운 코드를 작성할 수 있도록 노력해봐야겠다 생각했습니다.

<br/><br/>

## 유지보수 계획

- 클린 아키텍처 적용
- DI 적용
- 42CM만의 디자인 스타일을 프레임워크로 만들어보기
- Core Haptics 적용
- 클러스터링 적용
- SwiftUI+Combine으로 마이그레이션 해보기
