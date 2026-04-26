//
//  Event.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 15/4/26.
//

import Foundation

struct Event: Codable, Identifiable, Hashable {
    static func == (lhs: Event, rhs: Event) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    // AI Usage: how to compare and have hash for swiftdata

    let id: String
    let name: String
    let url: String?
    let images: [EventImage]
    let dates: EventDates
    let classifications: [EventClassification]?
    let embedded: EventEmbedded?
    let info: String?
    let pleaseNote: String? // new fields

    enum CodingKeys: String, CodingKey {
        case id, name, url, images, dates, classifications, info, pleaseNote
        case embedded = "_embedded"
    }
    
    // There is a need to pick the best image as it was a bit distorted
    var mainImageURL: URL? {
        let preferred = images
            .filter { $0.ratio == "16_9" && ($0.width ?? 0) >= 640 }
            .sorted { ($0.width ?? 0) > ($1.width ?? 0) }
            .first
        let raw = (preferred ?? images.first)?.url
        return raw.flatMap(URL.init)
    }
    
    // Need to display the date like "Apr 18 • 7:30pm"
    var formattedDate: String {
        guard let localDate = dates.start.localDate else { return "Date TBA" }
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = inputFormatter.date(from: localDate) else { return localDate }
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d"
        let datePart = displayFormatter.string(from: date)
        
        if dates.start.timeTBA == true || dates.start.noSpecificTime == true {
            return datePart
        }
        
        if let localTime = dates.start.localTime {
            let parts = localTime.split(separator: ":").compactMap { Int($0) }
            if parts.count >= 2 {
                let h = parts[0], m = parts[1]
                let displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h)
                let ampm = h >= 12 ? "PM" : "AM"
                return "\(datePart) • \(displayH):\(String(format: "%02d", m)) \(ampm)"
            }
        }
        return datePart
    }
    
    var venueName: String? {
        embedded?.venues?.first?.name
    }
    
    var cityName: String? {
        embedded?.venues?.first?.city?.name
    }
    
    var segment: String? {
        primaryClassification?.segment?.name
    }
    
    var genre: String? {
        primaryClassification?.genre?.name
    }
    
    // In case they dont exist ^
    var displayTag: String {
        let tag = genre ?? segment
        return (tag == "Undefined" || tag == nil) ? "Event" : tag!
    }
    
    var eventDate: Date? {
        guard let localDate = dates.start.localDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: localDate)
    }

    private var primaryClassification: EventClassification? {
        classifications?.first(where: { $0.primary == true }) ?? classifications?.first
    }
}

// Structs for JSON decoding

struct EventImage: Codable {
    let ratio: String?
    let url: String
    let width: Int?
    let height: Int?
    let fallback: Bool?
}

struct EventDates: Codable {
    let start: EventDateStart
    let timezone: String?
    let status: EventStatus?
}

struct EventDateStart: Codable {
    let localDate: String?
    let localTime: String?
    let dateTime: String?
    let dateTBD: Bool?
    let dateTBA: Bool?
    let timeTBA: Bool?
    let noSpecificTime: Bool?
}

struct EventStatus: Codable {
    let code: String
}

struct EventClassification: Codable {
    let primary: Bool?
    let segment: EventClassificationItem?
    let genre: EventClassificationItem?
    let subGenre: EventClassificationItem?
    let type: EventClassificationItem?
    let subType: EventClassificationItem?
}

struct EventClassificationItem: Codable {
    let id: String
    let name: String
}

struct EventEmbedded: Codable {
    let venues: [EventVenue]?
    let attractions: [EventAttraction]?
}

struct EventVenue: Codable {
    let name: String?
    let id: String?
    let city: EventCity?
    let state: EventState?
    let country: EventCountry?
    let address: EventAddress?
    let location: EventCoordinates?
}

struct EventCity: Codable {
    let name: String
}

struct EventState: Codable {
    let name: String?
    let stateCode: String?
}

struct EventCountry: Codable {
    let name: String?
    let countryCode: String?
}

struct EventAddress: Codable {
    let line1: String?
    let line2: String?
}

struct EventCoordinates: Codable {
    let longitude: String?
    let latitude: String?
}


struct EventAttraction: Codable {
    let id: String
    let name: String
    let url: String?
    let images: [EventImage]?
}
