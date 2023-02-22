//
//  UserSearchRequest.swift
//  GazelleKit
//
//  Created by Tarball on 12/6/22.
//

import Foundation

public extension GazelleAPI {
    func requestUserSearchResults(term: String, page: Int) async throws -> UserSearchResults {
        guard let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { throw GazelleAPIError.urlParseError }
        guard let url = URL(string: "https://redacted.ch/ajax.php?action=usersearch&search=\(encodedTerm)&page=\(page)") else { throw GazelleAPIError.urlParseError }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #if DEBUG
        print(json as Any)
        #endif
        let decoder = JSONDecoder()
        return try UserSearchResults(results: decoder.decode(RedactedUserSearch.self, from: data), requestJson: json, requestSize: data.count)
    }
    
    internal struct RedactedUserSearch: Codable {
        var status: String
        var response: RedactedUserSearchResponse
    }
    
    internal struct RedactedUserSearchResponse: Codable {
        var currentPage: Int?
        var pages: Int?
        var results: [RedactedUserSearchResult]
    }
    
    internal struct RedactedUserSearchResult: Codable {
        var userId: Int
        var username: String
        var donor: Bool
        var warned: Bool
        var enabled: Bool
        var `class`: String
    }
}

public class UserSearchResult: Identifiable {
    public let id = UUID()
    public let userId: Int
    public let username: String
    public let donor: Bool?
    public let warned: Bool?
    public let enabled: Bool
    public let `class`: String
    internal init(_ result: GazelleAPI.RedactedUserSearchResult) {
        userId = result.userId
        username = result.username
        donor = result.donor
        warned = result.warned
        enabled = result.enabled
        `class` = result.class
    }
}

public class UserSearchResults {
    public let currentPage: Int?
    public let pages: Int?
    public var results: [UserSearchResult]
    public let successful: Bool
    public let requestJson: [String: Any]?
    public let requestSize: Int
    internal init(results: GazelleAPI.RedactedUserSearch, requestJson: [String: Any]?, requestSize: Int) {
        currentPage = results.response.currentPage
        pages = results.response.pages
        var temp: [UserSearchResult] = []
        for result in results.response.results {
            temp.append(UserSearchResult(result))
        }
        self.results = temp
        successful = results.status == "success"
        self.requestJson = requestJson
        self.requestSize = requestSize
    }
}
