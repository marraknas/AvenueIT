//
//  DashboardSmallEventCardView.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 15/4/26.
//

import SwiftUI

struct DashboardSmallEventCardView: View {
    @State var event: Event
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomLeading) {
                
                Rectangle()
                    .fill(Color.avenueSkyBlue)
                    .frame(width: 200, height: 140)
                    .overlay(
                        Image(systemName: "progress.indicator")
                            .font(.largeTitle)
                            .foregroundStyle(.avenueOffWhite)
                    )
                
                Text(event.tag)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .padding(8)
            }
            .cornerRadius(16)
            
            Group {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .frame(width: 200, alignment: .leading)
                
                Text(event.date)
                    .font(.caption2)
                    .foregroundColor(.cyan)
            }
            .padding(.horizontal, 6)
        }
    }
}

#Preview {
    DashboardSmallEventCardView(event: Event(
        id: "1",
        title: "Celtics vs. Knicks",
        date: "Apr 19 • 7:30 PM",
        venue: "TD Garden",
        tag: "Sports"
    ))
}
