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

                if eventsVM.isLoading {
                    ProgressView()
                        .tint(Color("AvenueNeonCyan"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else if displayedEvents.isEmpty {
                    Text("No events found in \(selectedCity.cityName).")
                        .font(.subheadline)
                        .foregroundStyle(Color("AvenueOffWhite").opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 16) {
                            ForEach(displayedEvents.prefix(5)) { event in
                                Button {
                                    // TODO: Navigate to event detail
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
                            ForEach(displayedEvents) { event in
                                Button {
                                    // TODO: Navigate to event detail
                                } label: {
                                    DashboardSmallEventCardView(event: event)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding()
            .foregroundStyle(.white)
        }
        .background(Color("AvenueDeepNavy"))
        .task {
            await eventsVM.getData(for: selectedCity)
        }
        .onChange(of: selectedCity) { // Need to change to dynamic location
            Task { await eventsVM.getData(for: selectedCity) }
        }
    }
}

#Preview {
    HomeView()
}
