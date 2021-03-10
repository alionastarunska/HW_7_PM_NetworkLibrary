import XCTest
@testable import MyLibrary

final class MyLibraryTests: XCTestCase {
    func testExample() {
        let networkService = DefaultNetworkService()
        
        let requestExpectation = expectation(description: "request")
        
        networkService.execute(request: TestRequest()) { (response: TestResponse) in
            requestExpectation.fulfill()
            XCTAssertEqual(response.id, 1)
        } failure: { (error) in
            XCTFail()
        }

        wait(for: [requestExpectation], timeout: 10)
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

private struct TestRequest: Resource {
    
    typealias Response = TestResponse
    
    var url: String = "https://jsonplaceholder.typicode.com/todos/1"
    var requestBody: [String: Any] = [:]
    var method: MyLibrary.Method = .get
    var headers: [String: String] = [:]
}

private struct TestResponse: Codable {
    var userId: Int?
    var id: Int?
    var title: String?
    var completed: Bool?
}
