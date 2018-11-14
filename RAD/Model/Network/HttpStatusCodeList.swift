//
//  HttpStatusCodeList.swift
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

// swiftlint:disable line_length identifier_name
extension HttpStatusCode {
    // MARK: Informational
    static let `continue` = HttpStatusCode(code: 100, class: .informational, description: "The server has received the request headers and the client should proceed to send the request body (in the case of a request for which a body needs to be sent; for example, a POST request). Sending a large request body to a server after a request has been rejected for inappropriate headers would be inefficient. To have a server check the request's headers, a client must send Expect: 100-continue as a header in its initial request and receive a 100 Continue status code in response before sending the body. If the client receives an error code such as 403 (Forbidden) or 405 (Method Not Allowed) then it shouldn't send the request's body. The response 417 Expectation Failed indicates that the request should be repeated without the Expect header as it indicates that the server doesn't support expectations (this is the case, for example, of HTTP/1.0 servers).")
    static let switchingProtocols = HttpStatusCode(code: 101, class: .informational, description: "The requester has asked the server to switch protocols and the server has agreed to do so.")
    static let processing = HttpStatusCode(code: 102, class: .informational, description: "A WebDAV request may contain many sub-requests involving file operations, requiring a long time to complete the request. This code indicates that the server has received and is processing the request, but no response is available yet. This prevents the client from timing out and assuming the request was lost.")
    static let earlyHints = HttpStatusCode(code: 103, class: .informational, description: "Used to return some response headers before final HTTP message.")

    // MARK: Success
    static let ok = HttpStatusCode(code: 200, class: .success, description: "Standard response for successful HTTP requests. The actual response will depend on the request method used. In a GET request, the response will contain an entity corresponding to the requested resource. In a POST request, the response will contain an entity describing or containing the result of the action.")
    static let created = HttpStatusCode(code: 201, class: .success, description: "The request has been fulfilled, resulting in the creation of a new resource.")
    static let accepted = HttpStatusCode(code: 202, class: .success, description: "The request has been accepted for processing, but the processing has not been completed. The request might or might not be eventually acted upon, and may be disallowed when processing occurs.")
    static let nonAuthoritativeInformation = HttpStatusCode(code: 203, class: .success, description: "The server is a transforming proxy (e.g. a Web accelerator) that received a 200 OK from its origin, but is returning a modified version of the origin's response.")
    static let noContent = HttpStatusCode(code: 204, class: .success, description: "The server successfully processed the request and is not returning any content.")
    static let resetContent = HttpStatusCode(code: 205, class: .success, description: "The server successfully processed the request, but is not returning any content. Unlike a 204 response, this response requires that the requester reset the document view.")
    static let partialContent = HttpStatusCode(code: 206, class: .success, description: "The server is delivering only part of the resource (byte serving) due to a range header sent by the client. The range header is used by HTTP clients to enable resuming of interrupted downloads, or split a download into multiple simultaneous streams.")
    static let multiStatus = HttpStatusCode(code: 207, class: .success, description: "The message body that follows is by default an XML message and can contain a number of separate response codes, depending on how many sub-requests were made.")
    static let alreadyReported = HttpStatusCode(code: 208, class: .success, description: "The members of a DAV binding have already been enumerated in a preceding part of the (multistatus) response, and are not being included again.")
    static let imUsed = HttpStatusCode(code: 226, class: .success, description: "The server has fulfilled a request for the resource, and the response is a representation of the result of one or more instance-manipulations applied to the current instance.")

    // MARK: Redirection
    static let multipleChoices = HttpStatusCode(code: 300, class: .redirection, description: "Indicates multiple options for the resource from which the client may choose (via agent-driven content negotiation). For example, this code could be used to present multiple video format options, to list files with different filename extensions, or to suggest word-sense disambiguation.")
    static let movedPermanently = HttpStatusCode(code: 301, class: .redirection, description: "This and all future requests should be directed to the given URI.")
    static let found = HttpStatusCode(code: 302, class: .redirection, description: "Tells the client to look at (browse to) another url. 302 has been superseded by 303 and 307. This is an example of industry practice contradicting the standard. The HTTP/1.0 specification (RFC 1945) required the client to perform a temporary redirect (the original describing phrase was 'Moved Temporarily'), but popular browsers implemented 302 with the functionality of a 303 See Other. Therefore, HTTP/1.1 added status codes 303 and 307 to distinguish between the two behaviours. However, some Web applications and frameworks use the 302 status code as if it were the 303.")
    static let seeOther = HttpStatusCode(code: 303, class: .redirection, description: "The response to the request can be found under another URI using the GET method. When received in response to a POST (or PUT/DELETE), the client should presume that the server has received the data and should issue a new GET request to the given URI.")
    static let notModified = HttpStatusCode(code: 304, class: .redirection, description: "Indicates that the resource has not been modified since the version specified by the request headers If-Modified-Since or If-None-Match. In such case, there is no need to retransmit the resource since the client still has a previously-downloaded copy.")
    static let useProxy = HttpStatusCode(code: 305, class: .redirection, description: "The requested resource is available only through a proxy, the address for which is provided in the response. Many HTTP clients (such as Mozilla and Internet Explorer) do not correctly handle responses with this status code, primarily for security reasons.")
    static let switchProxy = HttpStatusCode(code: 306, class: .redirection, description: "No longer used. Originally meant 'Subsequent requests should use the specified proxy'.")
    static let temporaryRedirect = HttpStatusCode(code: 307, class: .redirection, description: "In this case, the request should be repeated with another URI; however, future requests should still use the original URI. In contrast to how 302 was historically implemented, the request method is not allowed to be changed when reissuing the original request. For example, a POST request should be repeated using another POST request.")
    static let permanentRedirect = HttpStatusCode(code: 308, class: .redirection, description: "The request and all future requests should be repeated using another URI. 307 and 308 parallel the behaviors of 302 and 301, but do not allow the HTTP method to change. So, for example, submitting a form to a permanently redirected resource may continue smoothly.")

    // MARK: Client
    static let badRequest = HttpStatusCode(code: 400, class: .client, description: "The server cannot or will not process the request due to an apparent client error (e.g., malformed request syntax, size too large, invalid request message framing, or deceptive request routing).")
    static let unauthorized = HttpStatusCode(code: 401, class: .client, description: "Similar to 403 Forbidden, but specifically for use when authentication is required and has failed or has not yet been provided. The response must include a WWW-Authenticate header field containing a challenge applicable to the requested resource. See Basic access authentication and Digest access authentication. 401 semantically means 'unauthenticated', i.e. the user does not have the necessary credentials. Note: Some sites issue HTTP 401 when an IP address is banned from the website (usually the website domain) and that specific address is refused permission to access a website.")
    static let paymentRequired = HttpStatusCode(code: 402, class: .client, description: "Reserved for future use. The original intention was that this code might be used as part of some form of digital cash or micropayment scheme, as proposed for example by GNU Taler, but that has not yet happened, and this code is not usually used. Google Developers API uses this status if a particular developer has exceeded the daily limit on requests.")
    static let forbidden = HttpStatusCode(code: 403, class: .client, description: "The request was valid, but the server is refusing action. The user might not have the necessary permissions for a resource, or may need an account of some sort.")
    static let notFound = HttpStatusCode(code: 404, class: .client, description: "The requested resource could not be found but may be available in the future. Subsequent requests by the client are permissible.")
    static let methodNotAllowed = HttpStatusCode(code: 405, class: .client, description: "A request method is not supported for the requested resource; for example, a GET request on a form that requires data to be presented via POST, or a PUT request on a read-only resource.")
    static let notAcceptable = HttpStatusCode(code: 406, class: .client, description: "The requested resource is capable of generating only content not acceptable according to the Accept headers sent in the request.")
    static let proxyAuthenticationRequired = HttpStatusCode(code: 407, class: .client, description: "The client must first authenticate itself with the proxy.")
    static let requestTimeout = HttpStatusCode(code: 408, class: .client, description: "The server timed out waiting for the request. According to HTTP specifications: 'The client did not produce a request within the time that the server was prepared to wait. The client MAY repeat the request without modifications at any later time.'")
    static let conflict = HttpStatusCode(code: 409, class: .client, description: "Indicates that the request could not be processed because of conflict in the request, such as an edit conflict between multiple simultaneous updates.")
    static let gone = HttpStatusCode(code: 410, class: .client, description: "Indicates that the resource requested is no longer available and will not be available again. This should be used when a resource has been intentionally removed and the resource should be purged. Upon receiving a 410 status code, the client should not request the resource in the future. Clients such as search engines should remove the resource from their indices. Most use cases do not require clients and search engines to purge the resource, and a '404 Not Found' may be used instead.")
    static let lengthRequired = HttpStatusCode(code: 411, class: .client, description: "The request did not specify the length of its content, which is required by the requested resource.")
    static let preconditionFailed = HttpStatusCode(code: 412, class: .client, description: "The server does not meet one of the preconditions that the requester put on the request.")
    static let payloadTooLarge = HttpStatusCode(code: 413, class: .client, description: "The request is larger than the server is willing or able to process. Previously called 'Request Entity Too Large'.")
    static let uriTooLong = HttpStatusCode(code: 414, class: .client, description: "The URI provided was too long for the server to process. Often the result of too much data being encoded as a query-string of a GET request, in which case it should be converted to a POST request. Called 'Request-URI Too Long' previously.")
    static let unsupportedMediaType = HttpStatusCode(code: 415, class: .client, description: "The request entity has a media type which the server or resource does not support. For example, the client uploads an image as image/svg+xml, but the server requires that images use a different format.")
    static let rangeNotSatifiable = HttpStatusCode(code: 416, class: .client, description: "The client has asked for a portion of the file (byte serving), but the server cannot supply that portion. For example, if the client asked for a part of the file that lies beyond the end of the file. Called 'Requested Range Not Satisfiable' previously.")
    static let expectationFailed = HttpStatusCode(code: 417, class: .client, description: "The server cannot meet the requirements of the Expect request-header field.")
    static let imATeapot = HttpStatusCode(code: 418, class: .client, description: "This code was defined in 1998 as one of the traditional IETF April Fools' jokes, in RFC 2324, Hyper Text Coffee Pot Control Protocol, and is not expected to be implemented by actual HTTP servers. The RFC specifies this code should be returned by teapots requested to brew coffee. This HTTP status is used as an Easter egg in some websites, including Google.com.")
    static let misdirectedRequest = HttpStatusCode(code: 421, class: .client, description: "The request was directed at a server that is not able to produce a response (for example because of connection reuse).")
    static let unprocessableEntity = HttpStatusCode(code: 422, class: .client, description: "The request was well-formed but was unable to be followed due to semantic errors.")
    static let locked = HttpStatusCode(code: 423, class: .client, description: "The resource that is being accessed is locked.")
    static let failedDependency = HttpStatusCode(code: 424, class: .client, description: "The request failed because it depended on another request and that request failed (e.g., a PROPPATCH).")
    static let upgradeRequired = HttpStatusCode(code: 426, class: .client, description: "The client should switch to a different protocol such as TLS/1.0, given in the Upgrade header field.")
    static let preconditionRequired = HttpStatusCode(code: 428, class: .client, description: "The origin server requires the request to be conditional. Intended to prevent the 'lost update' problem, where a client GETs a resource's state, modifies it, and PUTs it back to the server, when meanwhile a third party has modified the state on the server, leading to a conflict.")
    static let tooManyRequests = HttpStatusCode(code: 429, class: .client, description: "The user has sent too many requests in a given amount of time. Intended for use with rate-limiting schemes.")
    static let requestHeaderFieldsTooLarge = HttpStatusCode(code: 431, class: .client, description: "The server is unwilling to process the request because either an individual header field, or all the header fields collectively, are too large.")
    static let unavailableForLegalReasons = HttpStatusCode(code: 451, class: .client, description: "A server operator has received a legal demand to deny access to a resource or to a set of resources that includes the requested resource.[57] The code 451 was chosen as a reference to the novel Fahrenheit 451 (see the Acknowledgements in the RFC).")

    // MARK: Server
    static let internalServerError = HttpStatusCode(code: 500, class: .server, description: "A generic error message, given when an unexpected condition was encountered and no more specific message is suitable.")
    static let notImplemented = HttpStatusCode(code: 501, class: .server, description: "The server either does not recognize the request method, or it lacks the ability to fulfil the request. Usually this implies future availability (e.g., a new feature of a web-service API).")
    static let badGateway = HttpStatusCode(code: 502, class: .server, description: "The server was acting as a gateway or proxy and received an invalid response from the upstream server.")
    static let serviceUnavailable = HttpStatusCode(code: 503, class: .server, description: "The server is currently unavailable (because it is overloaded or down for maintenance). Generally, this is a temporary state.")
    static let gatewayTimeout = HttpStatusCode(code: 504, class: .server, description: "The server was acting as a gateway or proxy and did not receive a timely response from the upstream server.")
    static let httpVersionNotSupported = HttpStatusCode(code: 505, class: .server, description: "The server does not support the HTTP protocol version used in the request.")
    static let variantAlsoNegociates = HttpStatusCode(code: 506, class: .server, description: "Transparent content negotiation for the request results in a circular reference.")
    static let insufficientStorage = HttpStatusCode(code: 507, class: .server, description: "The server is unable to store the representation needed to complete the request.")
    static let loopDetected = HttpStatusCode(code: 508, class: .server, description: "The server detected an infinite loop while processing the request (sent in lieu of 208 Already Reported).")
    static let notExtended = HttpStatusCode(code: 510, class: .server, description: "Further extensions to the request are required for the server to fulfil it.")
    static let networkAuthenticationRequired = HttpStatusCode(code: 511, class: .server, description: "The client needs to authenticate to gain network access. Intended for use by intercepting proxies used to control access to the network (e.g., 'captive portals' used to require agreement to Terms of Service before granting full Internet access via a Wi-Fi hotspot).")

    // MARK: Others
    static let unknown = HttpStatusCode(code: Int.min, class: .unknown, description: "This status code is not in the list of HTPP status code maintained by Internet Assigned Numbers Authority (IANA).")
}

// swiftlint:enable line_length identifier_name
