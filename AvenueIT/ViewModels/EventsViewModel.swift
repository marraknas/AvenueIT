//
//  EventsViewModel.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 15/4/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class EventsViewModel {

    struct Returned: Codable {
        var embedded: EmbeddedEvents?
        var page: Page?

        enum CodingKeys: String, CodingKey {
            case embedded = "_embedded"
            case page
        }
    }

    struct EmbeddedEvents: Codable {
        var events: [Event]
    }

    struct Page: Codable {
        var size: Int
        var totalElements: Int
        var totalPages: Int
        var number: Int
    }

    var events: [Event] = []
    var isLoading = false
    var hasMorePages: Bool { currentPage < totalPages }
    var urlString = ""

    private var currentPage = 0
    private var totalPages = 0

    func getData(latitude: Double, longitude: Double, radius: Int, reset: Bool = false) async {
        if reset {
            events = []
            currentPage = 0
            totalPages = 0
        } // adding reset so that whenever you go to view it will load

        guard !isLoading else { return }

        urlString = "https://app.ticketmaster.com/discovery/v2/events.json?apikey=hKZRlOQinBHsApWAXA2jBFbrxNZkzU6T&locale=*&countryCode=US&size=50&sort=date,asc&latlong=\(latitude),\(longitude)&radius=\(radius)&unit=miles&page=\(currentPage)"

        isLoading = true
        print("We are accessing the url \(urlString)")
        guard let url = URL(string: urlString) else {
            print("ERROR: Could not create URL from \(urlString)")
            isLoading = false
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let returned = try? JSONDecoder().decode(Returned.self, from: data) else {
                print("JSON ERROR: Could not decode the JSON data")
                isLoading = false
                return
            }
            print("JSON returned!")
            events = events + (returned.embedded?.events ?? [])
            totalPages = returned.page?.totalPages ?? 0
            currentPage += 1
            print("\(events.count) events loaded, page \(currentPage) of \(totalPages)")
        } catch {
            print("Could not get data from \(urlString)")
        }
        isLoading = false
    }
}
