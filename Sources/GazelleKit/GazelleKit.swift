//
//  RedactedAPI.swift
//  REDSwift
//
//  Created by Tarball on 12/3/22.
//

import Foundation
import Combine

public class GazelleAPI: ObservableObject {
    public var apiKey: String
    public init(_ apiKey: String) {
        self.apiKey = apiKey
    }
}

public enum GazelleAPIError: Error {
    case urlParseError
    case requestError
    case networkError
}
