//
//  TorrentSearchRequest.swift
//  GazelleKit
//
//  Created by Tarball on 12/5/22.
//

import Foundation

public extension GazelleAPI {
    func requestTorrentSearchResults(term: String, page: Int) async throws -> TorrentSearchResults {
        guard let encodedTerm = term.urlEncoded else { throw GazelleAPIError.urlParseError }
        guard let url = URL(string: "\(tracker.rawValue)/ajax.php?action=browse&searchstr=\(encodedTerm)&page=\(page)") else { throw GazelleAPIError.urlParseError }
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
    
    internal struct RedactedTorrentSearchResults: Codable {
        var status: String
        var response: RedactedTorrentSearchResultsResponse
    }
    
    internal struct RedactedTorrentSearchResultsResponse: Codable {
        var currentPage: Int?
        var pages: Int?
        var results: [RedactedTorrentSearchResultsResponseResults]
    }
    
    internal struct RedactedTorrentSearchResultsResponseResults: Codable {
        var cover: String?
        var groupId: String
        var groupName: String
        var artist: String?
        var tags: [String]
        var bookmarked: Bool?
        var vanityHouse: Bool?
        var groupYear: Int?
        var releaseType: String?
        var groupTime: String?
        var maxSize: Int?
        var totalSnatched: Int?
        var totalSeeders: Int?
        var totalLeechers: Int?
        var torrents: [RedactedTorrentSearchTorrent]?
    }
    
    internal struct RedactedTorrentSearchTorrent: Codable {
        var torrentId: Int
        var editionId: Int
        var artists: [RedactedTorrentSearchArtist]
        var remastered: Bool
        var remasterYear: Int
        var remasterCatalogueNumber: String
        var remasterTitle: String
        var media: String
        var encoding: String
        var format: String
        var hasLog: Bool
        var logScore: Int
        var hasCue: Bool
        var scene: Bool
        var vanityHouse: Bool
        var fileCount: Int
        var time: String
        var size: Int
        var snatches: Int
        var seeders: Int
        var leechers: Int
        var isFreeleech: Bool
        var isNeutralLeech: Bool
        var isFreeload: Bool?
        var isPersonalFreeleech: Bool
        var canUseToken: Bool
    }
    
    internal struct RedactedTorrentSearchArtist: Codable {
        var id: Int
        var name: String
        var aliasid: Int
    }
}

public class TorrentGroup: Identifiable {
    public let id = UUID()
    public let cover: String?
    public let groupId: String
    public let groupName: String
    public let artist: String?
    public let tags: [String]
    public let bookmarked: Bool?
    public let vanityHouse: Bool?
    public let groupYear: Int?
    public let releaseType: String?
    public let groupTime: Date?
    public let maxSize: Int?
    public let totalSnatched: Int?
    public let totalSeeders: Int?
    public let totalLeechers: Int?
    public let torrents: [Torrent]
    internal init(_ group: GazelleAPI.RedactedTorrentSearchResultsResponseResults) {
        cover = group.cover
        groupId = group.groupId
        groupName = group.groupName
        artist = group.artist
        tags = group.tags
        bookmarked = group.bookmarked
        vanityHouse = group.vanityHouse
        groupYear = group.groupYear
        releaseType = group.releaseType
        groupTime = Date(timeIntervalSince1970: Double(group.groupTime ?? "0")!)
        maxSize = group.maxSize
        totalSnatched = group.totalSnatched
        totalSeeders = group.totalSeeders
        totalLeechers = group.totalLeechers
        var temp: [Torrent] = []
        if let torrents = group.torrents {
            for torrent in torrents {
                temp.append(Torrent(torrent))
            }
        }
        torrents = temp
    }
}

public class Artist: Identifiable {
    public let id = UUID()
    public let artistId: Int
    public let name: String
    internal init(_ artist: GazelleAPI.RedactedTorrentSearchArtist) {
        artistId = artist.id
        name = artist.name
    }
    internal init(_ artist: GazelleAPI.RedactedRequestSearchArtist) {
        artistId = 0
        name = artist.name
    }
}

public class Torrent: Identifiable {
    public let id = UUID()
    public let torrentId: Int
    public let editionId: Int
    public let artists: [Artist]
    public let remastered: Bool
    public let remasteredYear: Int
    public let remasterCatalogueNumber: String
    public let remasterTitle: String
    public let media: String
    public let encoding: String
    public let format: String
    public let hasLog: Bool
    public let logScore: Int
    public let hasCue: Bool
    public let scene: Bool
    public let vanityHouse: Bool
    public let fileCount: Int
    public let time: Date
    public let size: Int
    public let snatches: Int
    public let seeders: Int
    public let leechers: Int
    public let isFreeleech: Bool
    public let isNeutralLeech: Bool
    public let isFreeload: Bool
    public let isPersonalFreeleech: Bool
    public let canUseToken: Bool
    internal init(_ torrent: GazelleAPI.RedactedTorrentSearchTorrent) {
        torrentId = torrent.torrentId
        editionId = torrent.editionId
        var temp: [Artist] = []
        for artist in torrent.artists {
            temp.append(Artist(artist))
        }
        artists = temp
        remastered = torrent.remastered
        remasteredYear = torrent.remasterYear
        remasterCatalogueNumber = torrent.remasterCatalogueNumber
        remasterTitle = torrent.remasterTitle
        media = torrent.media
        encoding = torrent.encoding == "24bit Lossless" ? "24-bit Lossless" : torrent.encoding
        format = torrent.format
        hasLog = torrent.hasLog
        logScore = torrent.logScore
        hasCue = torrent.hasCue
        scene = torrent.scene
        vanityHouse = torrent.vanityHouse
        fileCount = torrent.fileCount
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        time = formatter.date(from: torrent.time) ?? .distantPast
        size = torrent.size
        snatches = torrent.snatches
        seeders = torrent.seeders
        leechers = torrent.leechers
        isFreeleech = torrent.isFreeleech
        isNeutralLeech = torrent.isNeutralLeech
        if let freeload = torrent.isFreeload {
            isFreeload = freeload
        } else {
            isFreeload = false
        }
        isPersonalFreeleech = torrent.isPersonalFreeleech
        canUseToken = torrent.canUseToken
    }
}

public class TorrentSearchResults {
    public let currentPage: Int?
    public let pages: Int?
    public var groups: [TorrentGroup]
    public let requestJson: [String: Any]?
    public let requestSize: Int
    public let successful: Bool
    internal init(results: GazelleAPI.RedactedTorrentSearchResults, requestJson: [String: Any]?, requestSize: Int) {
        currentPage = results.response.currentPage
        pages = results.response.pages
        var temp: [TorrentGroup] = []
        for group in results.response.results {
            temp.append(TorrentGroup(group))
        }
        groups = temp
        successful = results.status == "success"
        self.requestJson = requestJson
        self.requestSize = requestSize
    }
}
