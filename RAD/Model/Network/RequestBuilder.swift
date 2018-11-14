//
//  RequestBuilder.swift
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

class RequestBuilder {
    private let batch: Batch

    init(batch: Batch) {
        self.batch = batch
    }

    func buildRequest(with configuration: Configuration) -> URLRequest? {
        guard let url = batch.server.trackingURI else { return nil }
        guard let body = buildBody() else { return nil }
        var request = URLRequest(url: url)
        request.method = .post
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        for (key, value) in configuration.requestHeaderFields {
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }

    // MARK: Private functionality

    private func buildBody() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: batch.json, options: [])
        } catch {
            print("Unable to convert events batch into raw data.")
            return nil
        }
    }
}
