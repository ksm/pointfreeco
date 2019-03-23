import Either
import HttpPipeline
import Models
import ModelsTestSupport
import Optics
@testable import PointFree
import PointFreePrelude
import PointFreeTestSupport
import Prelude
import SnapshotTesting
#if !os(Linux)
import WebKit
#endif
import XCTest

class EnterpriseTests: TestCase {
  override func setUp() {
    super.setUp()
//    record = true
  }

  func testLanding() {
    Current.database = .mock

    let account = EnterpriseAccount.mock

    Current.database.fetchEnterpriseAccountForDomain = const(pure(.some(account)))

    let req = request(to: .enterprise(.landing(account.domain)))
    let conn = connection(from: req)
    assertSnapshot(matching: conn |> siteMiddleware, as: .ioConn)

    #if !os(Linux)
    if #available(OSX 10.13, *), ProcessInfo.processInfo.environment["CIRCLECI"] == nil {
      assertSnapshots(
        matching: conn |> siteMiddleware,
        as: [
          "desktop": .ioConnWebView(size: .init(width: 1100, height: 2100)),
          "mobile": .ioConnWebView(size: .init(width: 500, height: 2100))
        ]
      )
    }
    #endif
  }
}
