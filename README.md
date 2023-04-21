# GazelleKit

A work-in-progress Swift library for interacting with Gazelle-based torrent trackers.

Currently only officially supports RED and OPS, with more tracker support coming in the future.

## Adding GazelleKit to your project

### Swift Package Manager

Swift Package Manager is the only dependency manager supported by GazelleKit.<br/>
Select `File -> Add Packages...` in Xcode, then paste this repository's URL into the search bar.

## Example code

```swift
import GazelleKit

Task {
    let gazelle = GazelleAPI("api key here", tracker: .redacted)
    let personalProfile = try! await gazelle.requestPersonalProfile()
    let announcements = try! await gazelle.requestAnnouncements(perPage: 100)
    let searchResults = try! await gazelle.requestArtistSearchResults(term: "Pink Floyd", page: 1)
    // ...
}
```
