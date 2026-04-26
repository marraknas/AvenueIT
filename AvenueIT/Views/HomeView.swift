//
//  HomeView.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 15/4/26.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    @State private var eventsVM = EventsViewModel()
    @State private var savedEventsVM = SavedEventsViewModel()
    @Environment(LocationManager.self) private var locationManager
    @AppStorage("preferredRadius") private var radius = 25
    @State private var searchText = ""
    @State private var selectedFilter = "All events"
    @State private var showZipSheet = false
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

    private func fetchEvents(reset: Bool = true) async {
        guard let coord = locationManager.effectiveCoordinate else { return }
        await eventsVM.getData(latitude: coord.latitude, longitude: coord.longitude, radius: radius, reset: reset)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your location")
                            .font(.caption)
                            .foregroundStyle(Color("AvenueOffWhite").opacity(0.5))

                        if locationManager.isResolving {
                            ProgressView()
                                .tint(Color("AvenueNeonCyan"))
                                .frame(height: 28)
                        } else {
                            Button {
                                showZipSheet = true // zipcode entry
                            } label: {
                                HStack(spacing: 6) {
                                    Text(locationManager.displayName)
                                        .fontWeight(.bold)
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundStyle(Color("AvenueNeonCyan"))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Spacer()
                }

                HStack(spacing: 8) {
                    ForEach([10, 25, 50, 100], id: \.self) { miles in
                        Button {
                            radius = miles
                        } label: {
                            Text("\(miles) mi")
                                .font(.caption)
                                .fontWeight(radius == miles ? .bold : .regular)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(radius == miles ? Color("AvenueNeonCyan") : Color("AvenueSlate"))
                                .foregroundStyle(radius == miles ? Color("AvenueDeepNavy") : Color("AvenueOffWhite"))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
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
                                    NavigationLink(value: event) {
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
                                    NavigationLink(value: event) {
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
                            NavigationLink(value: event) {
                                EventListView(event: event)
                            }
                            .buttonStyle(.plain)
                            .task {
                                if eventsVM.events.last?.id == event.id && eventsVM.hasMorePages {
                                    await fetchEvents(reset: false)
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
                    } else if !eventsVM.isLoading {
                        Text(locationManager.effectiveCoordinate == nil
                             ? "Enable location to see nearby events."
                             : "No events found within \(radius) miles.")
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
        .navigationDestination(for: Event.self) { event in
            EventDetailView(event: event, savedEventsVM: savedEventsVM)
        }
        .sheet(isPresented: $showZipSheet) {
            ZipCodeSheetView(locationManager: locationManager)
        }
        .task {
            locationManager.requestLocation()
            if locationManager.effectiveCoordinate != nil {
                await fetchEvents()
            }
        }
        .onChange(of: locationManager.effectiveLatitude) {
            Task { await fetchEvents() }
        }
        .onChange(of: radius) {
            Task { await fetchEvents() }
        }
        // AI USAGE: Location task and on change
    }
}

private struct ZipCodeSheetView: View {
    let locationManager: LocationManager
    @Environment(\.dismiss) private var dismiss
    @State private var zipInput = ""
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("5-digit ZIP code", text: $zipInput)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color("AvenueSlate"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .onChange(of: zipInput) {
                        if zipInput.count > 5 {
                            zipInput = String(zipInput.prefix(5))
                        }
                    }

                if isSearching {
                    ProgressView()
                        .tint(Color("AvenueNeonCyan"))
                }

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Search by ZIP Code")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("AvenueDeepNavy"))
            .foregroundStyle(.white)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color("AvenueNeonCyan"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Search") {
                        Task {
                            isSearching = true
                            await locationManager.geocodeZipCode(zipInput)
                            isSearching = false
                            dismiss()
                        }
                    }
                    .foregroundStyle(Color("AvenueNeonCyan"))
                    .disabled(zipInput.count != 5 || isSearching)
                }
            }
        }
        .presentationDetents([.height(220)])
        .presentationDragIndicator(.visible)
    }
}
