//
//  ParseRADObjectsOperation.swift
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
import CoreData

class ParseRADObjectsOperation: ChainOperation<JSONDictionary, RADPayload> {
    let context: NSManagedObjectContext
    private let sessionId: String
    private let md5: String

    private var md5Predicate: NSPredicate {
        return NSPredicate(format: "md5 LIKE %@", argumentArray: [md5])
    }

    init(context: NSManagedObjectContext, sessionId: String, md5: String) {
        self.context = context
        self.sessionId = sessionId
        self.md5 = md5
    }

    override func execute() {
        guard let json = input else {
            finish(with: InputError.requiredDataNotAvailable)
            return
        }

        guard let radJSon =
            json[RadMetadata.JSONProperty.remoteAudioData] as? JSONDictionary
            else {
                finish(with: InputError.requiredDataNotAvailable)
                return
        }

        context.perform {
            let servers = self.parseServers(with: radJSon)
            guard servers.count > 0 else {
                self.finish(with: ParseError.unableToParseJson)
                return
            }
            var radMetadataJson = radJSon
            radMetadataJson[Server.JSONProperty.trackingUrls] = nil

            guard let radMetadata = self.fetchRadMetadata(with: radMetadataJson)
                else {
                    self.finish(with: ParseError.unableToParseJson)
                    return
            }
            guard let metadataEvents =
                radJSon[RadMetadata.JSONProperty.events] as? JSONArray else {
                    self.finish(with: ParseError.unableToParseJson)
                    return
            }

            let events = metadataEvents.compactMap({
                self.fetchEvent(with: $0)
            })

            let payload = RADPayload(
                servers: servers,
                radMetadata: radMetadata,
                events: events,
                sessionId: self.sessionId)
            self.finish(with: payload)
        }
    }

    private func parseServers(
        with json: JSONDictionary
    ) -> [Server] {
        guard let urls =
            json[Server.JSONProperty.trackingUrls] as? [String] else {
                return []
        }
        let servers = urls.compactMap({
            self.fetchServer(with: $0, json: json)
        })
        return servers
    }

    private func fetchServer(
        with url: String, json: JSONDictionary
    ) -> Server? {
        do {
            let request: NSFetchRequest<Server> = Server.fetchRequest()
            request.predicate = NSPredicate(
                format: "trackingUrl LIKE %@", argumentArray: [url])
            request.fetchLimit = 1
            let result: NSAsynchronousFetchResult<Server>? =
                try context.execute(request)
            if let server = result?.finalResult?.first {
                return server
            } else {
                return Server(urlString: url, context: context)
            }
        } catch {
            var message: String = "Unable to fetch server with trackingUrl: "
            message += "\(url) due to error: \(error)."
            print(message)
            return nil
        }
    }

    private func fetchRadMetadata(with json: JSONDictionary) -> RadMetadata? {
        do {
            let request: NSFetchRequest<RadMetadata> =
                RadMetadata.fetchRequest()
            request.predicate = md5Predicate
            request.fetchLimit = 1
            let result: NSAsynchronousFetchResult<RadMetadata>? =
                try context.execute(request)
            if let radMetadata = result?.finalResult?.first {
                return radMetadata
            } else {
                let radMetadata = RadMetadata(json: json, context: context)
                radMetadata?.md5 = md5
                return radMetadata
            }
        } catch {
            let message: String = "Unable to fetch radMetadata with md5: \(md5)"
            print(message)
            return nil
        }
    }

    private func fetchEvent(with json: JSONDictionary) -> Event? {
        guard let eventTime = json[Event.JSONProperty.eventTime] as? String
            else { return nil }
        do {
            let request: NSFetchRequest<Event> = Event.fetchRequest()
            let eventTimePredicate = NSPredicate(
                format: "eventTime LIKE %@", argumentArray: [eventTime])
            request.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    md5Predicate, eventTimePredicate
                ])
            request.fetchLimit = 1
            let result: NSAsynchronousFetchResult<Event>? =
                try context.execute(request)
            if let event = result?.finalResult?.first {
                return event
            } else {
                let event = Event(json: json, context: context)
                event?.md5 = md5
                return event
            }
        } catch {
            var message: String = "Unable to fetch event with event time: "
            message += "\(eventTime), md5: \(md5)"
            print(message)
            return nil
        }
    }
}
