//
//  SavedEventsViewModel.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 24/4/26.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class SavedEventsViewModel {
    // AI Usage: UserDefaults key usage
    private let key = "savedEvents"

    var savedEvents: [Event] = []

    init() {
        load()
    }

    func toggleSave(_ event: Event) {
        if isSaved(event) {
            savedEvents.removeAll { savedEvent in
                savedEvent.id == event.id
            }
        } else {
            savedEvents.append(event)
        }
        save()
    }

    // swipe to delete (using IndexSet to prevent removing more than once or removing other events)
    func remove(at offsets: IndexSet) {
        savedEvents.remove(atOffsets: offsets)
        save()
    }

    func isSaved(_ event: Event) -> Bool {
        savedEvents.contains { savedEvent in
            savedEvent.id == event.id
        }
    }

    func reload() {
        load()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(savedEvents) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let events = try? JSONDecoder().decode([Event].self, from: data) else { return }
        savedEvents = events
    }
    
    // AI Usage: Figuring out how to save and load
}
