//
//  NotificationsRequest.swift
//  GazelleKit
//
//  Created by Tarball on 12/3/22.
//

import Foundation

public extension GazelleAPI {
    func requestNotifications(page: Int) async throws -> Notifications {
        guard let url = URL(string: "\(tracker.rawValue)/ajax.php?action=notifications&page=\(page)") else { throw GazelleAPIError.urlParseError }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        #if DEBUG
        print(json as Any)
        #endif
        let decoder = JSONDecoder()
        return try Notifications(notifications: decoder.decode(RedactedNotifications_Notifications.self, from: data), requestJson: json)
    }
    
    internal struct RedactedNotifications_Notifications: Codable {
        var status: String
        var response: RedactedNotificationsResponse
    }
    
    internal struct RedactedNotificationsResponse: Codable {
        var currentPages: Int
        var pages: Int
        var numNew: Int
        var results: [GazelleAPI.RedactedNotification]
    }
    
    internal struct RedactedNotification: Codable {
        var torrentId: Int
        var groupId: Int
        var groupName: String
        var groupCategoryId: Int
        var torrentTags: String
        var size: Int
        var fileCount: Int
        var format: String
        var encoding: String
        var media: String
        var scene: Bool
        var groupYear: Int
        var remasterYear: Int
        var remasterTitle: String
        var snatched: Int
        var seeders: Int
        var leechers: Int
        var notificationTime: String
        var hasLog: Bool
        var hasCue: Bool
        var logScore: Int
        var freeTorrent: Bool
        var isNeutralleech: Bool
        var isFreeload: Bool
        var logInDb: Bool
        var unread: Bool
    }
}

public class Notifications {
    public let successful: Bool
    public let currentPage: Int
    public let pages: Int
    public let newNotifications: Int
    public let notifications: [GazelleNotification]
    internal init(notifications: GazelleAPI.RedactedNotifications_Notifications, requestJson: [String: Any]?) {
        successful = notifications.status == "success"
        currentPage = notifications.response.currentPages
        pages = notifications.response.pages
        newNotifications = notifications.response.numNew
        var temp: [GazelleNotification] = []
        for notification in notifications.response.results {
            temp.append(GazelleNotification(notification))
        }
        self.notifications = temp
    }
}

public class GazelleNotification {
    public let torrentId: Int
    public let groupId: Int
    public let groupName: String
    public let groupCategoryId: Int
    public let torrentTags: String
    public let size: Int
    public let fileCount: Int
    public let format: String
    public let encoding: String
    public let media: String
    public let scene: Bool
    public let groupYear: Int
    public let remasterYear: Int
    public let remasterTitle: String
    public let snatched: Int
    public let seeders: Int
    public let leechers: Int
    public let notificationTime: String
    public let hasLog: Bool
    public let hasCue: Bool
    public let logScore: Int
    public let freeTorrent: Bool
    public let isNeutralLeech: Bool
    public let isFreeload: Bool
    public let logInDb: Bool
    public let unread: Bool
    internal init(_ notification: GazelleAPI.RedactedNotification) {
        torrentId = notification.torrentId
        groupId = notification.groupId
        groupName = notification.groupName
        groupCategoryId = notification.groupCategoryId
        torrentTags = notification.torrentTags
        size = notification.size
        fileCount = notification.fileCount
        format = notification.format
        encoding = notification.format
        media = notification.media
        scene = notification.scene
        groupYear = notification.groupYear
        remasterYear = notification.remasterYear
        remasterTitle = notification.remasterTitle
        snatched = notification.snatched
        seeders = notification.seeders
        leechers = notification.leechers
        notificationTime = notification.notificationTime
        hasLog = notification.hasLog
        hasCue = notification.hasCue
        logScore = notification.logScore
        freeTorrent = notification.freeTorrent
        isNeutralLeech = notification.isNeutralleech
        isFreeload = notification.isFreeload
        logInDb = notification.logInDb
        unread = notification.unread
    }
}
