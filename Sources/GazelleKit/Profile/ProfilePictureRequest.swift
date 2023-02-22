//
//  ProfilePictureRequest.swift
//  GazelleKit
//
//  Created by Tarball on 12/4/22.
//

import Foundation
import SwiftUI

public extension GazelleAPI {
    public func requestProfilePicture(_ link: String) async throws -> Image? {
        guard let url = URL(string: link) else { throw GazelleAPIError.urlParseError }
        let (data, _) = try await URLSession.shared.data(from: url)
        let image = NSImage(data: data)
        guard let image = image else { return nil }
        return Image(nsImage: image)
    }
}
