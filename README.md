<img width="1024" alt="FTCM" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/FTCM.png?raw=true">

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


### **개발 기간**

2024.04.13 ~ 2024.05.31(기능 개발)
<br/>
2024.07.01 ~ 2024.07.28(리팩토링, 버그 수정 및 채팅 기능)


### **iOS 최소 버전**

15.0

<br/>


### **기능**

<table>
  <tr>
    <td>📝 게시글 업로드</td>
    <td>📸 스토리 형식 게시글 조회</td>
  </tr>
  <tr>
    <td>🗺 지도 기반으로 게시글 조회</td>
    <td>🗑 게시글 삭제</td>
  </tr>
  <tr>
    <td>🤍 게시글 좋아요</td>
    <td>🔍 댓글 조회</td>
  </tr>
  <tr>
    <td>💬 댓글 작성</td>
    <td>💳 PG사를 통한 실제 결제</td>
  </tr>
  <tr>
    <td>💬 채팅 조회</td>
    <td>💬 채팅 발송</td>
  </tr>
  <tr>
    <td>💬 채팅 실시간 수신</td>
    <td>🔍 채팅방 조회</td>
  </tr>
  <tr>
    <td>👤 내 정보 조회</td>
    <td>🗂 내가 작성한 게시글 조회</td>
  </tr>
  <tr>
    <td>🗂 내가 좋아요한 게시글 조회</td>
    <td>👥 유저 팔로우 / 언팔로우</td>
  </tr>
</table>
      

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
    

[프레임워크, 아키텍쳐 및 기술 스택 선택과정 보러가기(Click.ᐟ)](https://velog.io/@hwyjj/frameworkarchitecture)

<br/><br/>

## 주요 기능 실행 화면


| 로그인          | 회원가입         | 게시글 조회      |
|----------------|----------------|----------------|
| <img width="252" alt="42cm_signin" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/1/42cm_signin.gif?raw=true"> | <img width="252" alt="42CM Sign Up" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/1/42cm_signup.gif?raw=true"> | <img width="252" alt="42CM View Post" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/1/42CM_view_post.gif?raw=true"> |

| 지도 기반 게시글 조회          | 상품 결제         | 채팅      |
|----------------|----------------|----------------|
| <img width="252" alt="42CM View Map" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/2/42CM_view_map.gif?raw=true"> | <img width="252" alt="42CM Payment" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/2/42cm_payment.gif?raw=true"> | <img width="252" alt="42CM Chat" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/2/42cm_chat.gif?raw=true"> |

| 게시글 업로드          | 게시글 삭제         | 댓글 조회 및 작성      |
|----------------|----------------|----------------|
| <img width="252" alt="42CM Upload Post" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/3/42CM_upload_post.gif?raw=true"> | <img width="252" alt="42CM Delete Post" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/3/42cm_delete_post%20(1).gif?raw=true"> | <img width="252" alt="42CM Comment" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/3/42CM_comment.gif?raw=true"> |

| 팔로우 / 언팔로우          | 게시글 좋아요         | 마이페이지      |
|----------------|----------------|----------------|
| <img width="252" alt="42CM Follow" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/4/42CM_follow.gif?raw=true"> | <img width="252" alt="42CM Like Post" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/4/42CM_like_post.gif?raw=true"> | <img width="252" alt="42CM My Page" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/4/42CM_mypage.gif?raw=true"> |

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
- [로컬 DB에 채팅을 저장하는 이유(feat. Realm, Core Data)](https://velog.io/@hwyjj/%EB%A1%9C%EC%BB%AC-DB%EC%97%90-%EC%B1%84%ED%8C%85%EC%9D%84-%EC%A0%80%EC%9E%A5%ED%95%98%EB%8A%94-%EC%9D%B4%EC%9C%A0feat.RealmCoreData)
- [Network Protocol과 소켓 통신](https://velog.io/@hwyjj/Network-Protocol%EA%B3%BC-%EC%86%8C%EC%BC%93-%ED%86%B5%EC%8B%A0)
- [소켓은 언제 연결하고 끊어야 할까? 1편 (feat. App의 생명주기)](https://velog.io/@hwyjj/42CM-%EC%86%8C%EC%BC%93%EC%9D%80-%EC%96%B8%EC%A0%9C-%EC%97%B0%EA%B2%B0%ED%95%98%EA%B3%A0-%EB%81%8A%EC%96%B4%EC%95%BC-%ED%95%A0%EA%B9%8C-1%ED%8E%B8)
- [소켓은 언제 연결하고 끊어야 할까? 2편 (feat. ViewController의 생명주기)](https://velog.io/@hwyjj/%EC%86%8C%EC%BC%93%EC%9D%80-%EC%96%B8%EC%A0%9C-%EC%97%B0%EA%B2%B0%ED%95%98%EA%B3%A0-%EB%81%8A%EC%96%B4%EC%95%BC-%ED%95%A0%EA%B9%8C-2%ED%8E%B8)
- [민감한 유저 정보를 **KeyChain**에 담아보자](https://velog.io/@hwyjj/42CM-%EB%AF%BC%EA%B0%90%ED%95%9C-%EC%9C%A0%EC%A0%80%EC%A0%95%EB%B3%B4%EB%8A%94-KeyChain%EC%97%90-%EB%8B%B4%EC%95%84%EB%B3%B4%EC%9E%90)
- [Observable 대신 Single 사용해보기](https://velog.io/@hwyjj/42CM-Observable-%EB%8C%80%EC%8B%A0-Single-%EC%82%AC%EC%9A%A9%ED%95%B4%EB%B3%B4%EA%B8%B0)
- [오프셋 기반 페이지네이션 vs 커서 기반 페이지네이션](https://velog.io/@hwyjj/42CM-%EC%98%A4%ED%94%84%EC%85%8B-%EA%B8%B0%EB%B0%98-%ED%8E%98%EC%9D%B4%EC%A7%80%EB%84%A4%EC%9D%B4%EC%85%98-vs-%EC%BB%A4%EC%84%9C-%EA%B8%B0%EB%B0%98-%ED%8E%98%EC%9D%B4%EC%A7%80%EB%84%A4%EC%9D%B4%EC%85%98)
- [싱글톤 패턴의 장단점](https://velog.io/@hwyjj/42CM-%EC%8B%B1%EA%B8%80%ED%86%A4-%ED%8C%A8%ED%84%B4%EC%9D%98-%EC%9E%A5%EB%8B%A8%EC%A0%90)

<br/><br/>


## 트러블슈팅

### 의도적으로 PageViewController를 빠르게 넘길시, UI 렌더링 지연 및 Memory Leak 발생

**문제 상황**

UIPageViewController를 사용하여 게시글 조회 기능을 구현하였습니다. 이 기능은 5개씩 커서 기반 페이지네이션 방식으로 동작합니다. 그러나 사용자가 페이지를 의도적으로 빠르게 넘길 경우 UI가 제대로 렌더링되지 않는 문제가 있었습니다. 또한, Instrument를 통해 확인한 결과, 해당 기능에서 메모리 누수가 발생하고 있어 앱의 성능 저하와 비정상 종료 가능성이 있었습니다.

<img width="937" alt="Memory Leak" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/memoryleak.png?raw=true">

<br/>

**문제 원인**

기존 로직에서는 현재 페이지의 마지막(5번째) 게시글에 도달했을 때만 다음 페이지 데이터를 요청하도록 구현하였습니다. 이로 인해 사용자가 빠르게 PageViewController를 넘길 경우, 데이터 로딩 지연이 발생했습니다. 이는 다음 페이지 데이터를 요청하고 받아오는 동안, 사용자가 이미 다음 페이지를 넘어가고 있어 로딩이 완료되기 전에 UI가 준비되지 않았기 때문에 발생했습니다.

<br/>

**해결 방법**

현재 페이지의 마지막 게시글에 도달했을 때가 아니라, 3개의 단위로 데이터를 사전 로드하는 로직을 추가하였습니다. PageViewController의 인덱스가 3의 배수일 때마다 다음 페이지 데이터를 미리 로드하도록 처리하여, UI가 제대로 렌더링되지 않는 문제와 메모리 누수 문제를 해결할 수 있었습니다.

<img width="937" alt="Preloading" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/preloading.png?raw=true">

<img width="937" alt="Goodbye Memory Leak" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/goodbyememoryleak.png?raw=true">




<br/><br/>

### 채팅방 전환 시 소켓 이벤트 중복 호출 문제

**문제 상황**

채팅 앱에서 채팅방을 전환할 때마다 소켓 연결 이벤트인 connect에 대한 로그가 여러 번 출력되었고, 같은 이벤트가 중복으로 처리되는 문제가 발생했습니다. 이는 중복 데이터 처리, 성능 저하, 메모리 누수 등을 초래할 수 있었습니다.<br/>

<br/>

**문제 원인**

소켓을 통한 연결을 설정할 때, 이전 채팅방에서 등록된 이벤트 핸들러들이 제거되지 않은 상태로 남아 있었습니다. 이에 따라, 새로운 채팅방으로 이동하거나 새로운 소켓을 설정할 때 기존의 이벤트 핸들러가 중복으로 호출되어 동일한 이벤트에 대해 여러 번 로그가 출력되고 이벤트가 처리되었습니다.<br/>

<br/>

**해결 방법**

채팅방을 나갈 때 소켓 연결을 끊는 함수에 기존 핸들러를 제거하는 코드(socket.removeAllHandlers())를 추가했습니다. 이 코드는 채팅방이 사라질 때 호출되며, 이를 통해 이전 채팅방에서 등록된 이벤트 핸들러들이 새 채팅방에서 중복 호출되지 않도록 했습니다.


<img width="332" alt="Leave Connection" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/leaveconnection.png?raw=true">




<br/><br/>

## 일정 관리

Jira를 활용하여 프로젝트 일정 및 작업 관리를 효율적으로 수행했습니다. 특히, 개인 프로젝트에서 스케줄 관리와 작업 추적을 위해 Jira의 이슈 트래킹 기능을 적극적으로 활용했습니다. 이를 통해 개발 과정에서 발생할 수 있는 혼란을 최소화하고, 일정을 효율적으로 조율할 수 있었습니다.

<img width="1024" alt="42CM Jira" src="https://github.com/hwiwls/FourtyTwoCM/blob/main/ReadmeAssets/42CM_jira.png?raw=true">




<br/><br/>

## 회고

항상 그렇듯 뿌듯함과 아쉬움이 공존하는 프로젝트였습니다. 이전에는 커스텀 Observable을 사용했었는데, 이번 프로젝트에선 RxSwift로 전환하여 비동기 작업의 가독성과 유지보수성을 향상시킬 수 있었습니다. 이외에도 `Router` 패턴 등을 도입하여 관련 코드를 모듈화하고, 반복되는 코드를 줄이는 데 성공해서 굉장히 뿌듯했습니다. UI적으로도 난이도가 높은 화면들이 있었는데, 결국엔 그런 부분들을 해결해나가면서 굉장히 뿌듯했습니다. 하지만 프로젝트를 진행하면서 역시 몇 가지 아쉬운 점들도 있었습니다.<br/>

**아쉬운 점 1) 비즈니스 로직과 데이터 처리 로직의 혼재**

`ViewModel`에서 비즈니스 로직과 데이터 처리를 처리하게 했더니, ViewModel 코드가 지나치게 복잡해지는 문제가 생겼습니다. 네트워크 요청을 보내고, 응답을 받아 처리하는 모든 과정이 ViewModel에 포함되어 코드가 복잡해지는 문제가 생겼습니다. 뿐만 아니라, 기능 수정 시 많은 부분을 수정해야 하는 상황이 자주 일어났습니다.

**아쉬운 점 2) 네트워크 요청 테스트가 어려움**
ViewModel이 직접 NetworkManager를 호출하는 방식으로 구현되어 있었고, 의존성 주입이 적용되지 않아 테스트 시 실제 네트워크 호출을 피하기 어려웠습니다. 모의 객체를 사용한 테스트를 시도했지만, 네트워크 요청과 관련된 로직을 모의 객체로 대체할 수 없어서 어려움을 겪었습니다.

<br/>

**생각해본 해결방안**

문제들을 해결하기 위해 여러 방안을 고민하던 중, 클린 아키텍처의 필요성을 깨달았습니다. 실제로 적용하지는 않았지만, 다음과 같은 방법들이 해결책이 될 수 있겠다고 생각했습니다.

**1)유즈케이스를 이용해 비즈니스 로직의 분리**

ViewModel에서 비즈니스 로직을 분리하여 유즈케이스 클래스로 관리하면 좋겠다고 생각했습니다. 예를 들어, `SignInUseCase`라는 클래스를 만들어 사용자 인증과 관련된 로직을 처리하고, ViewModel은 오직 뷰 업데이트만 담당하게 하는 것입니다. 이렇게 하면 ViewModel의 책임이 줄어들고, 코드가 더 깔끔해질 것 같다고 생각했습니다.

**2) 의존성 주입의 도입**

의존성 주입을 도입해 ViewModel이 필요한 의존성을 외부에서 주입받도록 설계하면, 테스트 시 모의 객체를 쉽게 사용할 수 있습니다. 이를 통해 ViewModel이 특정 네트워크 구현에 강하게 결합되지 않도록 하여, 유닛 테스트에서 다양한 시나리오를 손쉽게 검증할 수 있게 됩니다.

이러한 개선 방안들을 차차 적용해보려 합니다. 이번 프로젝트에서 경험한 문제들을 바탕으로, 더 나은 아키텍처를 설계하고 유지보수하기 쉬운 코드를 작성할 수 있도록 노력해봐야겠다 생각했습니다.

<br/><br/>

## 유지보수 계획

- 클린 아키텍처 적용
- DI 적용
- 42CM만의 디자인 스타일을 프레임워크로 만들어보기
- Core Haptics 적용
- 클러스터링 적용
- SwiftUI+Combine으로 마이그레이션 해보기
