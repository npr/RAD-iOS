//
//  ParseRADPayloadOperation.swift
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

import AVFoundation

/// Extract RAD payload from an AVAsset.
/// If payload cannot be found, it will finish with an error.
class ParseRADPayloadOperation: OutputOperation<String> {
    private let asset: AVAsset

    init(asset: AVAsset) {
        self.asset = asset
    }

    override func execute() {
        let metadata: [String: String] =
            asset.availableMetadataFormats.reduce([:], { result, format in
                var new = result
                let formatMetadata = asset.metadata(forFormat: format)
                formatMetadata.enumerated().forEach({
                    new[String($0.offset)] = $0.element.stringValue
                })
                return new
            })

        guard let radPair = metadata.first(where: {
            $0.value.contains(RadMetadata.JSONProperty.remoteAudioData.rawValue)
        }) else {
            finish(with: ParseError.radPayloadNotFound)
            return
        }

        finish(with: radPair.value)
    }
}
