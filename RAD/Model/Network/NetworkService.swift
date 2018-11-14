//
//  NetworkService.swift
//  RAD
//
//  Copyright 2018 NPR
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use
//  this file except in compliance with the License. You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

import Foundation

class NetworkService: NSObject, URLSessionTaskDelegate {
    typealias Completion = (
        _ response: HTTPURLResponse?, _ error: Error?
    ) -> Void

    static let shared = NetworkService()

    private var session: URLSession!
    private var tasksMap: [URLSessionTask: Completion] = [:]

    private override init() {
        super.init()
        session = URLSession(
            configuration: URLSessionConfiguration.framework,
            delegate: self,
            delegateQueue: OperationQueue.background)
    }

    func executeRequest(_ request: URLRequest, completion: Completion? = nil) {
        let task = session.dataTask(with: request)
        if let completion = completion {
            tasksMap[task] = completion
        }
        task.resume()
    }

    // MARK: URLSessionDelegate

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        guard let completion = tasksMap[task] else { return }

        let response = task.response as? HTTPURLResponse
        tasksMap[task] = nil
        completion(response, error)
    }
}
