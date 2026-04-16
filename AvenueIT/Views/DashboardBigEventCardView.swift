//
//  DashboardBigEventCardView.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 15/4/26.
//

import SwiftUI

struct DashboardBigEventCardView: View {
    @State var event: Event
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // TODO: Image of the event should appear here instead of the rectangle
            Rectangle()
                .fill(Color.avenueSkyBlue)
                .frame(height: 250)
                .frame(minWidth: 0, maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(event.tag)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                
                Text(event.title)
                    .font(.title3)
                    .fontWeight(.heavy)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("\(event.date) • \(event.venue)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 250)
        .cornerRadius(25)
    }
}

#Preview {
    DashboardBigEventCardView(event: Event(
        id: "1",
        title: "Celtics vs. Knicks",
        date: "Apr 19 • 7:30 PM",
        venue: "TD Garden",
        tag: "Sports"
    ))
}
