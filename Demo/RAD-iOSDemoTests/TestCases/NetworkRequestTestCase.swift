//
//  NetworkRequestTestCase.swift
//  RAD-iOSDemoTests
//
//  Created by David Livadaru on 23/11/2018.
//  Copyright © 2018 NPR. All rights reserved.
//

import XCTest
import RAD

class NetworkRequestTestCase: AnalyticsTestCase {
    override var configuration: Configuration? {
        return _configuration
    }

    private let _configuration = Configuration(
        submissionTimeInterval: .seconds(15),
        batchSize: 5,
        expirationTimeInterval: DateComponents(day: 10),
        sessionExpirationTimeInterval: .hours(24),
        requestHeaderFields: [:])

    private var networkRequestExpectation: XCTestExpectation!

    override func setUp() {
        super.setUp()

        networkRequestExpectation = self.expectation(
            description: "Network request did begin.")
    }

    func testExample() {
        analytics.debugger.addNetworkObserver(self)
        configureTestCase()
        executePlayback()
        wait(for: [networkRequestExpectation], timeout: .seconds(30))
    }
}

extension NetworkRequestTestCase: NetworkObserver {
    func didBeginExecutionOfUrlRequest(_ request: URLRequest) {
        networkRequestExpectation.fulfill()
    }
}
