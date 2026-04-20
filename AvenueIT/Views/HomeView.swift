//
//  HomeView.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 15/4/26.
//

import SwiftUI

struct HomeView: View {
    @State private var eventsVM = EventsViewModel()
    @AppStorage("preferredCity") private var selectedCity: City = .boston
    @State private var searchText = ""
    @State private var selectedFilter = "All events"
    let filterOptions = ["All events", "Art", "Sports", "Concert"]
    
    private var displayedEvents: [Event] {
        eventsVM.events.filter { event in
            let matchesFilter = selectedFilter == "All events"
                || event.segment == selectedFilter
                || event.genre == selectedFilter
                || event.displayTag == selectedFilter
            let matchesSearch = searchText.isEmpty
                || event.name.localizedCaseInsensitiveContains(searchText)
                || (event.venueName ?? "").localizedCaseInsensitiveContains(searchText)
            return matchesFilter && matchesSearch
        }
    }

    private var sections: (featured: [Event], thisWeek: [Event], list: [Event]) {
        let all = displayedEvents

        if !searchText.isEmpty {
            return ([], [], all)
        }

        let featured = Array(all.prefix(5)) // top 5
        let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
        let today = Calendar.current.startOfDay(for: .now)
        let thisWeek = Array(
            all.dropFirst(5).filter { event in
                guard let date = event.eventDate else { return false }
                return date >= today && date <= weekFromNow
            }.prefix(7) // top 7
        )
        let skipIDs = Set((featured + thisWeek).map { $0.id }) // redundant
        let list = all.filter { !skipIDs.contains($0.id) }
        return (featured, thisWeek, list)
    }

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
                        .foregroundStyle(.black)
                    if !searchText.isEmpty {
                        Button { searchText = "" } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .padding()
                .background(Color("AvenueOffWhite"))
                .cornerRadius(20)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(filterOptions, id: \.self) { filter in
                            Button {
                                selectedFilter = filter
                            } label: {
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

                if eventsVM.isLoading && eventsVM.events.isEmpty {
                    ProgressView()
                        .tint(Color("AvenueNeonCyan"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else {
                    if !sections.featured.isEmpty {
                        Text("Featured")
                            .font(.title2)
                            .fontWeight(.bold)

                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 16) {
                                ForEach(sections.featured) { event in
                                    Button { } label: {
                                        DashboardBigEventCardView(event: event)
                                            .containerRelativeFrame(.horizontal, count: 10, span: 9, spacing: 16)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    
                    if !sections.thisWeek.isEmpty {
                        Text("Happening This Week")
                            .font(.title2)
                            .fontWeight(.bold)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(sections.thisWeek) { event in
                                    Button { } label: {
                                        DashboardSmallEventCardView(event: event)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    
                    // New list section here
                    if !sections.list.isEmpty {
                        Text(searchText.isEmpty ? "All Upcoming Events" : "Results")
                            .font(.title2)
                            .fontWeight(.bold)

                        ForEach(sections.list) { event in
                            Button { } label: {
                                EventListView(event: event)
                            }
                            .buttonStyle(.plain)
                            .task {
                                if eventsVM.events.last?.id == event.id && eventsVM.hasMorePages {
                                    await eventsVM.getData(for: selectedCity)
                                }
                            }
                            Divider()
                                .background(Color("AvenueSlate"))
                        }

                        if eventsVM.isLoading {
                            ProgressView()
                                .tint(Color("AvenueNeonCyan"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                    } else if !eventsVM.isLoading { // not loading new events
                        Text("No events found in \(selectedCity.cityName).")
                            .font(.subheadline)
                            .foregroundStyle(Color("AvenueOffWhite").opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    }
                }
            }
            .padding()
            .foregroundStyle(.white)
            .animation(.easeInOut(duration: 0.25), value: searchText.isEmpty)
        }
        .background(Color("AvenueDeepNavy"))
        .task {
            await eventsVM.getData(for: selectedCity, reset: true)
        }
        .onChange(of: selectedCity) {
            Task { await eventsVM.getData(for: selectedCity, reset: true) }
        }
    }
}

#Preview {
    HomeView()
}
