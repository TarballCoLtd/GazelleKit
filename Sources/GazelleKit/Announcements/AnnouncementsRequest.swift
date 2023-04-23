//
//  AnnouncementsRequest.swift
//  GazelleKit
//
//  Created by Tarball on 12/2/22.
//

import Foundation

public extension GazelleAPI {
    func requestAnnouncements(perPage: Int) async throws -> Announcements {
        if tracker == .redacted {
            return try await requestAnnouncementsRedacted(perPage)
        } else if tracker == .orpheus {
            return try await requestAnnouncementsOrpheus(perPage)
        }
        throw GazelleAPIError.unknownTrackerSelectedError
    }
    
    internal func requestAnnouncementsRedacted(_ perPage: Int) async throws -> Announcements {
        guard let url = URL(string: "\(tracker.rawValue)/ajax.php?action=announcements&perpage=\(perPage)&order_by=title") else { throw GazelleAPIError.urlParseError }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #if DEBUG
        print(json as Any)
        #endif
        let decoder = JSONDecoder()
        return try Announcements(announcements: decoder.decode(RedactedAnnouncements.self, from: data), requestJson: json)
    }
    
    internal func requestAnnouncementsOrpheus(_ perPage: Int) async throws -> Announcements {
        guard let url = URL(string: "\(tracker.rawValue)/ajax.php?action=announcements&perpage=\(perPage)&order_by=title") else { throw GazelleAPIError.urlParseError }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #if DEBUG
        print(json as Any)
        #endif
        let decoder = JSONDecoder()
        return try Announcements(announcements: decoder.decode(OrpheusAnnouncements.self, from: data), requestJson: json)
    }

    internal struct RedactedAnnouncements: Codable {
        var status: String
        var response: RedactedAnnouncementsResponse
    }

    internal struct RedactedAnnouncementsResponse: Codable {
        var announcements: [RedactedAnnouncement]
    }

    internal struct RedactedAnnouncement: Codable {
        var newsId: Int
        var title: String
        var bbBody: String?
        var body: String
        var newsTime: String
    }
    
    internal struct OrpheusAnnouncements: Codable {
        var status: String
        var response: OrpheusAnnouncementsResponse
    }
    
    internal struct OrpheusAnnouncementsResponse: Codable {
        var announcements: [OrpheusAnnouncement]
    }
    
    internal struct OrpheusAnnouncement: Codable {
        var newsId: String
        var title: String
        var bbBody: String?
        var body: String
        var newsTime: String
    }
}

public class Announcement: Identifiable {
    public let id = UUID()
    public let announcementId: Int?
    public let title: String
    public let bbBody: String?
    public let body: String
    public let time: Date?
    
    internal init(_ announcement: GazelleAPI.RedactedAnnouncement) {
        announcementId = announcement.newsId
        title = announcement.title
        bbBody = announcement.bbBody
        body = announcement.body
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        time = formatter.date(from: announcement.newsTime)
    }
    
    internal init(_ announcement: GazelleAPI.OrpheusAnnouncement) {
        announcementId = Int(announcement.newsId)
        title = announcement.title
        bbBody = announcement.bbBody
        body = announcement.body
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        time = formatter.date(from: announcement.newsTime)
    }
}

public class Announcements: Identifiable {
    public let id = UUID()
    public var announcements: [Announcement]
    public let successful: Bool
    public let requestJson: [String: Any]?
    
    internal init(announcements: GazelleAPI.RedactedAnnouncements, requestJson: [String: Any]?) {
        var temp: [Announcement] = []
        for announcement in announcements.response.announcements {
            temp.append(Announcement(announcement))
        }
        self.announcements = temp
        successful = announcements.status == "success"
        self.requestJson = requestJson
    }
    
    internal init(announcements: GazelleAPI.OrpheusAnnouncements, requestJson: [String: Any]?) {
        var temp: [Announcement] = []
        for announcement in announcements.response.announcements {
            temp.append(Announcement(announcement))
        }
        self.announcements = temp
        successful = announcements.status == "success"
        self.requestJson = requestJson
    }
}
