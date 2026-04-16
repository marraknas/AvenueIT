//
//  HomeView.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 15/4/26.
//

import SwiftUI

// TODO: Need to define models after designing UI
struct Event: Identifiable {
    var id: String
    var title: String
    var date: String
    var venue: String
    var tag: String
}

enum City: String, CaseIterable {
    case boston       = "Boston, MA"
    case newYork      = "New York, NY"
    case losAngeles   = "Los Angeles, CA"
    case chicago      = "Chicago, IL"
    case houston      = "Houston, TX"
    case miami        = "Miami, FL"
    case seattle      = "Seattle, WA"
    case austin       = "Austin, TX"
    case denver       = "Denver, CO"
    case sanFrancisco = "San Francisco, CA"
}

struct HomeView: View {
    let sampleEvents = [
        Event(
            id: "1",
            title: "Celtics vs. Knicks",
            date: "Apr 19 • 7:30 PM",
            venue: "TD Garden",
            tag: "Sports"
        ),
        Event(
            id: "2",
            title: "The Weeknd Live",
            date: "Aug 21 • 7:00 PM",
            venue: "Gilette Stadium",
            tag: "Concert"
        ),
        Event(
            id: "3",
            title: "Hamilton",
            date: "Jun 04 • 8:00 PM",
            venue: "Citizens Bank Opera House",
            tag: "Art"
        ),
        Event(
            id: "4",
            title: "Taylor Swift Eras Tour",
            date: "Jul 15 • 8:30 PM",
            venue: "Wembley Stadium",
            tag: "Concert"
        ),
        Event(
            id: "5",
            title: "Harry Potter: In Concert",
            date: "May 12 • 9:00 PM",
            venue: "Wilbur Theatre",
            tag: "Drama"
        ),
        Event(
            id: "6",
            title: "Red Sox vs. Yankees",
            date: "May 01 • 1:05 PM",
            venue: "Fenway Park",
            tag: "Sports"
        )
    ]
    
    @State private var selectedCity: City = .boston
    @State private var searchText = ""
    @State private var selectedFilter = "All events"
    let filterOptions = ["All events", "Art", "Sports", "Concert"]
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your location")
                            .font(.caption)
                            .foregroundStyle(Color("AvenueOffWhite").opacity(0.5))
                        
                        Picker("Location", selection: $selectedCity) {
                            ForEach(City.allCases, id: \.self) { city in
                                Text(city.rawValue).tag(city)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(Color("AvenueOffWhite"))
                        .fontWeight(.bold)
                        .font(.title3)
                        .padding(.leading, -12)
                    }
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search for events", text: $searchText)
                        .submitLabel(.search)
                        .autocorrectionDisabled()
                }
                .padding()
                .background(Color("AvenueOffWhite"))
                .cornerRadius(20)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(filterOptions, id: \.self) { filter in
                            Button() {
                                // TODO: actual filtering logic once models setup
                                selectedFilter = filter
                            } label : {
                                Text(filter)
                                    .font(.subheadline)
                                    .fontWeight(selectedFilter == filter ? .bold : .regular)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(selectedFilter == filter ? Color.white : Color.avenueSlate)
                                    .foregroundColor(selectedFilter == filter ? .black : .white)
                                    .cornerRadius(20)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(sampleEvents.prefix(5)) { event in
                            Button() {
                                // TODO: Add a new view navigation
                            } label: {
                                DashboardBigEventCardView(event: event)
                                    .containerRelativeFrame(.horizontal, count: 10, span: 9, spacing: 16)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Text("Events nearby")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(sampleEvents) { event in
                            Button() {
                                // TODO: Actually navigate
                            } label: {
                                DashboardSmallEventCardView(event: event)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
            .foregroundStyle(.white)
        }
        .background(Color("AvenueDeepNavy"))
    }
}

#Preview {
    HomeView()
}
