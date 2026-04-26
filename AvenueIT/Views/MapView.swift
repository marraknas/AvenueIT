//
//  MapView.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 24/4/26.
//

import SwiftUI
import MapKit
import CoreLocation

private struct VenueCluster: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let venueName: String?
    let events: [Event]
} // for when there are too many events in one place

struct MapView: View {
    @State private var eventsVM = EventsViewModel()
    @Environment(LocationManager.self) private var locationManager
    @AppStorage("preferredRadius") private var radius = 25
    @State private var selectedCluster: VenueCluster? = nil
    @State private var cameraPosition: MapCameraPosition = .automatic

    private var clusters: [VenueCluster] {
        let locatableEvents = eventsVM.events.filter { event in
            guard let loc = event.embedded?.venues?.first?.location,
                  let latStr = loc.latitude, let lonStr = loc.longitude,
                  Double(latStr) != nil, Double(lonStr) != nil else { return false }
            return true // only the ones with coordinates (to plot)
        }
        
        let grouped_events = Dictionary(grouping: locatableEvents) { event -> String in
            let loc = event.embedded!.venues!.first!.location!
            let lat = Double(loc.latitude!)!
            let lon = Double(loc.longitude!)!
            return String(format: "%.4f,%.4f", lat, lon)
        }

        return grouped_events.compactMap { key, events in
            guard let loc = events.first?.embedded?.venues?.first?.location,
                  let latStr = loc.latitude, let lonStr = loc.longitude,
                  let lat = Double(latStr), let lon = Double(lonStr) else { return nil }
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            return VenueCluster(id: key, coordinate: coord, venueName: events.first?.venueName, events: events)
        }
    }

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(clusters) { cluster in
                // custom pin
                Annotation("", coordinate: cluster.coordinate) {
                    Button {
                        selectedCluster = cluster
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color("AvenueNeonCyan"))
                                .frame(
                                    width: cluster.events.count > 1 ? 44 : 32,
                                    height: cluster.events.count > 1 ? 44 : 32
                                )
                                .shadow(radius: 4)
                            if cluster.events.count > 1 {
                                Text("\(cluster.events.count)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.black)
                            } else {
                                Image(systemName: "ticket.fill") // singular events
                                    .foregroundStyle(.black)
                                    .imageScale(.small)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(item: $selectedCluster) { cluster in
            ClusterSheetView(cluster: cluster)
        }
        .task {
            locationManager.requestLocation()
            if let coord = locationManager.effectiveCoordinate {
                cameraPosition = .region(MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
                ))
                await eventsVM.getData(latitude: coord.latitude, longitude: coord.longitude, radius: radius, reset: true)
            }
        }
        // AI USAGE: creating the task for a mapkit
        .onChange(of: locationManager.effectiveLatitude) {
            if let coord = locationManager.effectiveCoordinate {
                cameraPosition = .region(MKCoordinateRegion(
                    center: coord,
                    span: MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
                ))
                Task {
                    await eventsVM.getData(latitude: coord.latitude, longitude: coord.longitude, radius: radius, reset: true)
                }
            }
        }
        .onChange(of: radius) {
            if let coord = locationManager.effectiveCoordinate {
                Task {
                    await eventsVM.getData(latitude: coord.latitude, longitude: coord.longitude, radius: radius, reset: true)
                }
            }
        }
    }
}

// the sheet should open up from the bottom up
private struct ClusterSheetView: View {
    let cluster: VenueCluster
    @State private var savedEventsVM = SavedEventsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(cluster.events) { event in
                        NavigationLink(value: event) {
                            EventListView(event: event)
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                        Divider()
                            .background(Color("AvenueSlate"))
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle(cluster.venueName ?? "Events")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("AvenueDeepNavy"))
            .foregroundStyle(.white)
            .navigationDestination(for: Event.self) { event in
                EventDetailView(event: event, savedEventsVM: savedEventsVM)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        // Apple Guidelines suggest this
    }
}
