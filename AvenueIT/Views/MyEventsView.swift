//
//  MyEventsView.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 24/4/26.
//

import SwiftUI

struct MyEventsView: View {
    @State private var savedEventsVM = SavedEventsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if savedEventsVM.savedEvents.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 48))
                            .foregroundStyle(Color("AvenueNeonCyan"))
                        Text("No saved events yet")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Tap Save on any event to add it here.")
                            .font(.subheadline)
                            .foregroundStyle(Color("AvenueOffWhite").opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(savedEventsVM.savedEvents) { event in
                            NavigationLink(value: event) {
                                EventListView(event: event)
                            }
                            .listRowBackground(Color("AvenueDeepNavy"))
                            .listRowSeparatorTint(Color("AvenueSlate"))
                        }
                        .onDelete { offsets in
                            savedEventsVM.remove(at: offsets)
                        } // IndexSet
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("My Events")
            .navigationDestination(for: Event.self) { event in
                EventDetailView(event: event, savedEventsVM: savedEventsVM)
            }
            .background(Color("AvenueDeepNavy"))
            .foregroundStyle(.white)
        }
        .onAppear {
            savedEventsVM.reload()
        }
    }
}

// removed Preview (some issue with location)
