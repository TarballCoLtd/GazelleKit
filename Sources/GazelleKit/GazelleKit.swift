//
//  GazelleKit.swift
//  GazelleKit
//
//  Created by Tarball on 12/3/22.
//

import Foundation

public class GazelleAPI: ObservableObject {
    public var apiKey: String
    public var tracker: GazelleTracker
    
    public init(_ apiKey: String, tracker: GazelleTracker) {
        self.apiKey = apiKey
        self.tracker = tracker
    }
    
    public static func getShortenedTrackerName(_ tracker: GazelleTracker) -> String {
        switch(tracker) {
        case .redacted:
            return "RED"
        case .orpheus:
            return "OPS"
        }
    }
    
    public static func getTrackerName(_ tracker: GazelleTracker) -> String {
        switch(tracker) {
        case .redacted:
            return "Redacted"
        case .orpheus:
            return "Orpheus"
        }
    }
}

public enum GazelleTracker: String { // do not include a forward slash at the end of a link, things will break
    case redacted = "https://redacted.ch"
    case orpheus = "https://orpheus.network"
}

public enum GazelleAPIError: Error {
    case urlParseError
    case requestError
    case networkError
    case unknownTrackerSelectedError
}

public extension String {
    var urlEncoded: String? {
        addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)?
            .replacingOccurrences(of: "&", with: "%26")
    }
}
