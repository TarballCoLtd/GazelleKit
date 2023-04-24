//
//  AnnouncementsRequest.swift
//  GazelleKit
//
//  Created by Tarball on 12/2/22.
//

import Foundation

public extension GazelleAPI {
    
    func requestAnnouncements(perPage: Int) async throws -> Announcements {
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
        return try Announcements(announcements: decoder.decode(RedactedAnnouncements.self, from: data), requestJson: json, tracker: tracker)
    }

    internal struct RedactedAnnouncements: Codable {
        var status: String
        var response: RedactedAnnouncementsResponse
    }

    internal struct RedactedAnnouncementsResponse: Codable {
        var announcements: [RedactedAnnouncement]
        var blogPosts: [OrpheusBlogPost]
    }
    
    internal struct OrpheusBlogPost: Codable {
        var bbBody: String
        var blogId: Int
        var blogTime: String
        var body: String
        var threadId: Int
        var title: String
    }

    internal struct RedactedAnnouncement: Codable {
        var newsId: Int?
        var title: String?
        var bbBody: String?
        var body: String?
        var newsTime: String?
    }
}

public class Announcement: Identifiable {
    public let id = UUID()
    public let announcementId: Int?
    public let title: String?
    public let bbBody: String?
    public let body: String?
    public let time: Date?
    
    internal init(_ announcement: GazelleAPI.RedactedAnnouncement) {
        announcementId = announcement.newsId
        title = announcement.title
        bbBody = announcement.bbBody
        body = announcement.body
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        time = formatter.date(from: announcement.newsTime ?? "")
    }
}

public class BlogPost: Identifiable {
    public let id = UUID()
    public let bbBody: String
    public let blogId: Int
    public let time: Date?
    public let body: String
    public let threadId: Int
    public let title: String
    
    internal init(_ blogPost: GazelleAPI.OrpheusBlogPost) {
        bbBody = blogPost.bbBody
        blogId = blogPost.blogId
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        time = formatter.date(from: blogPost.blogTime)
        body = blogPost.body
        threadId = blogPost.threadId
        title = blogPost.title
    }
}

public class Announcements: Identifiable {
    public let id = UUID()
    public var announcements: [Announcement]
    public var blogPosts: [BlogPost]
    public let successful: Bool
    public let requestJson: [String: Any]?
    
    internal init(announcements: GazelleAPI.RedactedAnnouncements, requestJson: [String: Any]?, tracker: GazelleTracker) {
        var temp: [Announcement] = []
        for announcement in announcements.response.announcements {
            temp.append(Announcement(announcement))
        }
        var temp2: [BlogPost] = []
        for blogPost in announcements.response.blogPosts {
            temp2.append(BlogPost(blogPost))
        }
        self.announcements = temp
        self.blogPosts = temp2
        successful = announcements.status == "success"
        self.requestJson = requestJson
        
        if tracker == .redacted {
            self.announcements.reverse()
            self.blogPosts.reverse()
        }
    }
    
    public func containsNullAnnouncements() -> Bool {
        for announcement in announcements {
            if announcement.announcementId == nil || announcement.title == nil || announcement.bbBody == nil || announcement.time == nil {
                return true
            }
        }
        return false
    }
}
