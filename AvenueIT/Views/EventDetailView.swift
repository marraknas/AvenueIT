//
//  EventDetailView.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 24/4/26.
//

import SwiftUI

struct EventDetailView: View {
    let event: Event
    let savedEventsVM: SavedEventsViewModel
    
    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color("AvenueSlate"))
            .overlay(
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(Color("AvenueOffWhite").opacity(0.2))
            )
    }
    
    private var venue: EventVenue? {
        event.embedded?.venues?.first
    }
    
    private var venueAddress: String? {
        guard let line1 = venue?.address?.line1 else { return nil }
        let parts = [line1, venue?.city?.name, venue?.state?.stateCode]
            .compactMap { $0 }
        return parts.joined(separator: ", ")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // just the same
                AsyncImage(url: event.mainImageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if phase.error != nil {
                        imagePlaceholder
                    } else {
                        imagePlaceholder
                            .overlay(ProgressView().tint(Color("AvenueNeonCyan")))
                    }
                }
                .frame(height: 300)
                .frame(minWidth: 0, maxWidth: .infinity)
                .clipped()
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        colors: [.clear, Color("AvenueDeepNavy")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.displayTag)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color("AvenueSlate"))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Text(event.name)
                            .font(.title2)
                            .fontWeight(.heavy)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Image(systemName: "calendar")
                                .foregroundStyle(Color("AvenueNeonCyan"))
                                .frame(width: 20)
                            Text(event.formattedDate)
                                .font(.subheadline)
                        }
                        
                        if let venueName = event.venueName {
                            HStack(spacing: 10) {
                                Image(systemName: "building.2")
                                    .foregroundStyle(Color("AvenueNeonCyan"))
                                    .frame(width: 20)
                                Text(venueName)
                                    .font(.subheadline)
                            }
                        }
                        
                        if let address = venueAddress {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "mappin")
                                    .foregroundStyle(Color("AvenueNeonCyan"))
                                    .frame(width: 20)
                                Text(address)
                                    .font(.subheadline)
                                    .foregroundStyle(Color("AvenueOffWhite").opacity(0.7))
                            }
                        }
                    }
                    
                    Divider()
                    
                    // if there are performers involved
                    if let attractions = event.embedded?.attractions, !attractions.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Performers")
                                .font(.headline)
                                .fontWeight(.bold)
                            ForEach(attractions, id: \.id) { attraction in
                                HStack(spacing: 10) {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(Color("AvenueNeonCyan"))
                                        .frame(width: 20)
                                    Text(attraction.name)
                                        .font(.subheadline)
                                }
                            }
                        }
                        
                        Divider()
                    }
                    
                    if let info = event.info {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text(info)
                                .font(.subheadline)
                                .foregroundStyle(Color("AvenueOffWhite").opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    if let note = event.pleaseNote {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Please Note")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text(note)
                                .font(.subheadline)
                                .foregroundStyle(Color("AvenueOffWhite").opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        if let urlString = event.url, let url = URL(string: urlString) {
                            Link(destination: url) {
                                Text("Buy on Ticketmaster")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(Color("AvenueNeonCyan"))
                                    .foregroundStyle(Color("AvenueDeepNavy"))
                                    .clipShape(RoundedRectangle(cornerRadius: 13))
                            }
                        }
                        
                        Button {
                            savedEventsVM.toggleSave(event)
                        } label: {
                            HStack {
                                Image(systemName: savedEventsVM.isSaved(event) ? "bookmark.fill" : "bookmark")
                                Text(savedEventsVM.isSaved(event) ? "Saved to My Events" : "Save to My Events")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color("AvenueSlate"))
                            .foregroundStyle(savedEventsVM.isSaved(event) ? Color("AvenueNeonCyan") : Color("AvenueOffWhite"))
                            .clipShape(RoundedRectangle(cornerRadius: 13))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom, 40)
            }
            .containerRelativeFrame(.horizontal)
        }
        .background(Color("AvenueDeepNavy"))
        .foregroundStyle(.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AvenueDeepNavy"), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .ignoresSafeArea(edges: .top)
    }
}
