//
//  JSONObject.swift
//  RAD
//
//  Created by David Livadaru on 07/06/2018.
//  Copyright © 2018 National Public Radio. All rights reserved.
//

import Foundation

public class JSONObject<JSONType: JSON> {
    public let json: JSONType

    init?(json: JSONType) {
        self.json = json
    }
}
