# 오픈 마켓 프로젝트

#### 프로젝트 기간: 2021.08.09 - 2021.08.27(예정)
#### 프로젝트 팀원: [Joey](https://github.com/joey-ful), [Soll](https://github.com/soll4u)

## step1 브랜치 - 모델/네트워킹 타입 구현

### Mock 객체
#### Mock 객체의 필요성
- 네트워크 통신을 하기 위해 URLSession의 `dataTask(with:completionHandler:)` 메서드를 사용했다. 하지만 서버가 아직 만들어지지 않았거나 당장 인터넷 통신이 불가한 경우 등을 대비해 실제 메서드 대신 mock 객체의 메서드를 활용해 데이터를 받아오는 방법을 구현했다.
  - URLSession을 mocking한 MockURLSesssion 타입을 구현했다.
  - 두 타입을 추상화한 URLSessionProtocol을 구현하고 requirement로 URLSession의 메서드인 `dataTask(with:completionHandler:)` 선언했다.
 
#### 의존성 주입
 - 네트워크 통신을 하는 타입은 URLSession과 MockURLSession을 추상화한 타입을 가지고 있어야 하며 이는 둘 중 어느 것이든 될 수 있기 때문에 인스턴스를 외부에서 주입하는 방식으로 구현했다.
  ```swift
  struct NetworkManager {
      let session: URLSessionProtocol
    
      init(session: URLSessionProtocol) {
          self.session = session
      }
  }
  ```
#### Mock 객체는 실제와 흡사하게 구현
- 그리고 실사용은 주입받은 객체가 무엇인지 관계없이 그대로 `dataTask(with:completionHandler:)` 메서드를 사용한다
```swift
let task: URLSessionDataTaskProtocol = session
    .dataTask(with: request) { data, urlResponse, error in
        //...
    }
task.resume()
```
- 이를 위해 Mock 객체는 실제 객체와 유사하게 작동해야 하며 실제 데이터와 흡사한 가짜 데이터를 전달해줘야 했다. 로컬에 Items와 Item, 두 가지 데이터가 있었고 파일 이름을 각 데이터의 url로 지정했다. 그리고 각 데이터의 url을 넘겨주면 해당하는 데이터를 반환, 다른 url을 넘겨주면 통신에 실패하도록 구현했다.

#### URLSessionDataTask
- 해당 메서드는 URLSessionDataTask 를 반환하는데 Mock 객체에서는 URLSessionDataTask를 상속받는 MockURLSessionDataTask를 반환하도록 했다. 
  - URLSessionDataTask 의 `resume()`를 override하기 위함이다.
  - 하지만 URLSessionDataTask를 초기화하는 init()은 deprecated되었다는 경고 메시지가 떠서 그대로 상속을 받기에 부적절하게 생각되었다.
  - 따라서 이 둘을 추상화하는 URLSessionDataTaskProtocol을 구현했다.
  - 다만 이 경우 `dataTask(with:completionHandler:)` 메서드는 더이상 URLSessionDataTask가 아닌 이를 추상화한 URLSessionDataTaskProtocol 타입을 반환해야 한다.
  - 다음 로직을 추가해 리턴 타입을 수정했다.
  ```swift
  protocol URLSessionProtocol {
      func dataTaskWithRequest(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> URLSessionDataTaskProtocol
      }

  extension URLSession: URLSessionProtocol {
      func dataTaskWithRequest(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> URLSessionDataTaskProtocol {
          dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTaskProtocol
          }
      }
  ```

### Result 타입
- Unit Test를 할 함수는 리턴타입을 Result타입으로 구현했다.
- 리턴할 때는 switch문을 사용해 성공과 실패 시 값을 따로 반환했다.
  ```swift
  case .success(let decodedData):
      completion(.success(decodedData))
  case .failure(let error):
      completion(.failure(error))
  }
  ```
- 대신 리턴값을 사용하거나 테스트할 때에도 성공과 실패를 구분해서 값을 벗겨야 했다.
  ```swift
  case .success(let data):
      outcome = data.title
  case .failture(let error):
      print(error)
  case .none:
      print("none")
  }
  ```

### 비동기 Unit Test
- XCTTestExpection을 생성한다.
- 비동기 작업이 완료된 시점에 해당 expectation의 `fulfill()` 메서드로 비동기 작업이 완료됨을 알린다.
- 비동기 작업을 호출한 함수에서는 `wait(for: [expectation], timeout: 5.0)` 로 expectation이 충족되기를 기다린다.
  - expectation이 fulfill되거나 5초가 지날 때까지 기다린다.
  - 혹시 비동기 작업이 너무 오래 걸리면 기다리지 않는다. 시간을 정해두면 비동기 작업에 실패하는 경우 5초를 초과하여 기다리지 않아도 되는 이점이 있다.
  ```swift
  // given
  let urlString = MockURL.mockItem.description
  let url = try XCTUnwrap(URL(string: urlString))
  var outcome: String?
  let expectation = XCTestExpectation(description: expectationDescription)
  let expectedValue = "MacBook Pro"

  // when
  sutNetworkManager?.fetchData(url: url) { (result: Result<Item, Error>) in
      switch result {
      case .success(let data):
          outcome = data.title
      default:
          XCTFail()
      }
      expectation.fulfill()
  }
  wait(for: [expectation], timeout: 5.0)

  // then
  XCTAssertEqual(outcome, expectedValue)
  ```


## main 브랜치 - 개인적으로 진행(미완)

### POST
<img src="https://user-images.githubusercontent.com/52592748/129999732-19455643-cb5e-4daf-a5f1-6c813b3efede.gif" width="400"/>

- POST와 PATCH 메서드로 상품을 등록/수정하기 위해서 multipart/form-data 를 활용했다.
- 사용자가 실제로 사용할 수 있는 메서드는 POST만 구현했다.
  - `+` 버튼으로 상품 등록 페이지로 이동을 한다
  - `취소` 버튼을 누르면 돌아간다
  - 필수 항목을 기입하지 않은 채로 `등록` 버튼을 누르면 경고 알럿이 뜬다.
  - 필수 항목을 모두 기입하고 `등록` 버튼을 누르면 콘솔에 response가 출력된다
  - response가 반환하는 id 번호를 다음과 같이 url뒤에 붙인 주소로 이동을 한다
  - `https://camp-open-market-2.herokuapp.com/item/538`
  
  ![image](https://user-images.githubusercontent.com/52592748/129998980-dbb96f48-b858-47fc-b8ea-984e1588fc01.png)
  - 웹에서 등록된 상품을 확인할 수 있다
 
  ![image](https://user-images.githubusercontent.com/52592748/129999103-bac84548-7eb2-4a5d-86b5-7c7556f9b77f.png)


### multipart/form-data
예를 들어 title=choco, price=9000 이라는 정보를 보낼 때 여러 방식을 통해 정보를 보낼 수 있다

[참고 stackoverflow](https://stackoverflow.com/questions/3508338/what-is-the-boundary-in-multipart-form-data)

- `aplication/x-www-form-urlencoded` 방식

    ```json
    title=choco&price=9000
    ```

- `multipart/form-data` 방식

    [multipart/form-data](https://developer.mozilla.org/en-US/docs/Web/API/FormData) 방식은 key/value 쌍을 쉽게 표현하는 형식

    ```json
    --XXX
    Content-Disposition: form-data; name="title"

    choco
    --XXX
    Content-Disposition: form-data; name="price"

    9000
    --XXX--
    ```

- 좀 더 구체적으로는 이렇게 생겼다
    - 여기서 boundary로 감싸진 내용들은 모두 **같은 요청에 관한 내용**임을 알리기 위한 것이다
        - `"Boundary-\(NSUUID().uuidString)"` 이렇게 랜덤으로 생성하면 되며
        - **같은 요청**에서는 **같은 boundary**를 위,아래,사이사이에 넣어주면 된다

        ```json
        --Boundary-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
        Content-Disposition: form-data; name=\"title\"

        choco
        --Boundary-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
        Content-Disposition: form-data; name=\"price\"

        9000
        --Boundary-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX--
        ```
- 실제로 httpBody를 만들고 출력해보면 다음과 같다
  - 디코딩을 먼저 해준다

    ```swift
    String(decoding: request.httpBody!, as: UTF8.self)
    ```

  - 실제 출력한 결과물 (title: choco, price: 9000, image: jpeg 파일)

    ```json
    --Boundary-265B324D-9628-4D91-AC7A-31C6E93020B7
    Content-Disposition: form-data; name="title"

    choco
    --Boundary-265B324D-9628-4D91-AC7A-31C6E93020B7
    Content-Disposition: form-data; name="price"

    9000
    --Boundary-265B324D-9628-4D91-AC7A-31C6E93020B7
    Content-Disposition: form-data; name="images[]"; filename="photo1602058207.jpeg"
    Content-Type: image/jpeg

    // 이미지 데이터 내용인데 알아볼 수 없는 형식
    // ���J�;ى�	;�Ȧ8@#?N��.w?\����Q�Lcp��������� 막 이런거 잔뜩 엄청 길게 나옴
    --Boundary-265B324D-9628-4D91-AC7A-31C6E93020B7--
    ```


### DELETE
DELETE 메서드는 multipart/form-data 방식이 작동하지 않아 application/json content-type으로 구현했다.
- parameters를 바로 Data형식으로 변환해서 httpBody에 담았다
  - [참고 StackOverflow](https://stackoverflow.com/questions/49683960/http-request-delete-and-put)

```swift
func deleteData(url: URL, parameters: [String:String]) {
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let dataBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
    request.httpBody = dataBody!
    
    sessionDataTaskAndPrintResults(with: request)
}
```

### CollectionView

<img src="https://user-images.githubusercontent.com/52592748/129997884-a8cc30eb-da31-4762-8e58-6164f6340865.gif" width="300"/>

- 토글 버튼을 만들어 UICollectionViewFlowLayout 의 스크롤 방향이 세로/가로로 변경되도록 구현했다.
  - 그리고 `performBatchUpdates()`로 애니메이션 효과를 추가했다.
  ```swift
  guard let layout = listCollectoinView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

  listCollectoinView.performBatchUpdates({
      layout.scrollDirection = (layout.scrollDirection == .vertical) ? .horizontal : .vertical
  }, completion: nil)
  ```

- 스크롤방향이 변경될 때마다 셀 크기도 새로 계산해줬다.

  ```swift
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero }

      let verticalNumberOfItems: CGFloat = 12
      let horizontalNumberOfItems: CGFloat = 2
      let bounds = collectionView.bounds
      let contentWidth = bounds.width - (layout.sectionInset.left + layout.sectionInset.right)
      let contentHeight = bounds.height - (layout.sectionInset.top + layout.sectionInset.bottom)
      var width: CGFloat
      var height: CGFloat

      switch layout .scrollDirection {
      case .vertical:
          width = contentWidth
          height = (contentHeight - (layout.minimumLineSpacing * (verticalNumberOfItems - 1))) / verticalNumberOfItems
      case .horizontal:
          width = (contentWidth - (layout.minimumLineSpacing * (horizontalNumberOfItems - 1))) / horizontalNumberOfItems
          height = width * 2 / 3
      @unknown default:
          fatalError()
      }

      return CGSize(width: width, height: height)
  }
  ```       
