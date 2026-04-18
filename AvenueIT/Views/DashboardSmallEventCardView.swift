//
//  DashboardSmallEventCardView.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 15/4/26.
//

import SwiftUI

struct DashboardSmallEventCardView: View {
    let event: Event
    
    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color("AvenueSlate"))
            .overlay(
                Image(systemName: "photo")
                    .foregroundStyle(Color("AvenueOffWhite").opacity(0.2))
            )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomLeading) {
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
                .frame(width: 200, height: 140)
                .clipped()
                
                Text(event.displayTag)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Text(event.formattedDate)
                    .font(.caption2)
                    .foregroundStyle(Color("AvenueNeonCyan"))
            }
            .frame(width: 200, alignment: .leading)
            .padding(.horizontal, 4)
        }
    }
}

#Preview {
    DashboardSmallEventCardView(event: Event(
        id: "1",
        name: "Celtics vs. Knicks",
        url: nil,
        images: [],
        dates: EventDates(start: EventDateStart(localDate: "2026-04-19", localTime: "19:30:00", dateTime: nil, dateTBD: false, dateTBA: false, timeTBA: false, noSpecificTime: false), timezone: nil, status: nil),
        classifications: nil,
        embedded: nil
    ))
    .padding()
    .background(Color("AvenueDeepNavy"))
}
