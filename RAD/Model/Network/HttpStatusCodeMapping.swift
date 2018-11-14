//
//  HttpStatusCodeMapping.swift
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

extension HttpStatusCode {
    static func with(_ rawCode: Int) -> HttpStatusCode {
        return HttpStatusCode.map[rawCode] ?? HttpStatusCode.unknown
    }

    private static let map: [Int: HttpStatusCode] = {
        var map: [Int: HttpStatusCode] = [:]

        // MARK: Informational
        map[100] = HttpStatusCode.continue
        map[101] = HttpStatusCode.switchingProtocols
        map[102] = HttpStatusCode.processing
        map[103] = HttpStatusCode.earlyHints

        // MARK: Success
        map[200] = HttpStatusCode.ok
        map[201] = HttpStatusCode.created
        map[202] = HttpStatusCode.accepted
        map[203] = HttpStatusCode.nonAuthoritativeInformation
        map[204] = HttpStatusCode.noContent
        map[205] = HttpStatusCode.resetContent
        map[206] = HttpStatusCode.partialContent
        map[207] = HttpStatusCode.multiStatus
        map[208] = HttpStatusCode.alreadyReported
        map[226] = HttpStatusCode.imUsed

        // MARK: Redirection
        map[300] = HttpStatusCode.multipleChoices
        map[301] = HttpStatusCode.movedPermanently
        map[302] = HttpStatusCode.found
        map[303] = HttpStatusCode.seeOther
        map[304] = HttpStatusCode.notModified
        map[305] = HttpStatusCode.useProxy
        map[306] = HttpStatusCode.switchProxy
        map[307] = HttpStatusCode.temporaryRedirect
        map[308] = HttpStatusCode.permanentRedirect

        // MARK: Client
        map[400] = HttpStatusCode.badRequest
        map[401] = HttpStatusCode.unauthorized
        map[402] = HttpStatusCode.paymentRequired
        map[403] = HttpStatusCode.forbidden
        map[404] = HttpStatusCode.notFound
        map[405] = HttpStatusCode.methodNotAllowed
        map[406] = HttpStatusCode.notAcceptable
        map[407] = HttpStatusCode.proxyAuthenticationRequired
        map[408] = HttpStatusCode.requestTimeout
        map[409] = HttpStatusCode.conflict
        map[410] = HttpStatusCode.gone
        map[411] = HttpStatusCode.lengthRequired
        map[412] = HttpStatusCode.preconditionFailed
        map[413] = HttpStatusCode.payloadTooLarge
        map[414] = HttpStatusCode.uriTooLong
        map[415] = HttpStatusCode.unsupportedMediaType
        map[416] = HttpStatusCode.rangeNotSatifiable
        map[417] = HttpStatusCode.expectationFailed
        map[418] = HttpStatusCode.imATeapot
        map[421] = HttpStatusCode.misdirectedRequest
        map[422] = HttpStatusCode.unprocessableEntity
        map[423] = HttpStatusCode.locked
        map[424] = HttpStatusCode.failedDependency
        map[426] = HttpStatusCode.upgradeRequired
        map[428] = HttpStatusCode.preconditionRequired
        map[429] = HttpStatusCode.tooManyRequests
        map[431] = HttpStatusCode.requestHeaderFieldsTooLarge
        map[451] = HttpStatusCode.unavailableForLegalReasons

        // MARK: Server
        map[500] = HttpStatusCode.internalServerError
        map[501] = HttpStatusCode.notImplemented
        map[502] = HttpStatusCode.badGateway
        map[503] = HttpStatusCode.serviceUnavailable
        map[504] = HttpStatusCode.gatewayTimeout
        map[505] = HttpStatusCode.httpVersionNotSupported
        map[506] = HttpStatusCode.variantAlsoNegociates
        map[507] = HttpStatusCode.insufficientStorage
        map[508] = HttpStatusCode.loopDetected
        map[510] = HttpStatusCode.notExtended
        map[511] = HttpStatusCode.networkAuthenticationRequired

        return map
    }()
}
