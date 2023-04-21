//
//  ArtistSearchRequest.swift
//  GazelleKit
//
//  Created by Tarball on 12/6/22.
//

import Foundation

public extension GazelleAPI {
    func requestArtistSearchResults(term: String, page: Int) async throws -> TorrentSearchResults {
        guard let encodedTerm = term.urlEncoded else { throw GazelleAPIError.urlParseError }
        guard let url = URL(string: "\(tracker.rawValue)/ajax.php?action=browse&artistname=\(encodedTerm)&page=\(page)") else { throw GazelleAPIError.urlParseError }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #if DEBUG
        print(json as Any)
        #endif
        let decoder = JSONDecoder()
        return try TorrentSearchResults(results: decoder.decode(RedactedTorrentSearchResults.self, from: data), requestJson: json, requestSize: data.count)
    }
}
