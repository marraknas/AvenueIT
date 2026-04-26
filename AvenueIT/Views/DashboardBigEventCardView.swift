//
//  DashboardBigEventCardView.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 15/4/26.
//

import SwiftUI

struct DashboardBigEventCardView: View {
    let event: Event
    
    private var imagePlaceholder: some View {
        Rectangle()
            .fill(Color("AvenueSlate"))
            .overlay(
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(Color("AvenueOffWhite").opacity(0.2))
            )
    }
    
    var body: some View {
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
            .frame(height: 250)
            .frame(minWidth: 0, maxWidth: .infinity)
            .clipped()
            
            // in case the text is not visible
            LinearGradient(
                colors: [.clear, .black.opacity(0.80)],
                startPoint: .center,
                endPoint: .bottom
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(event.displayTag)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text(event.name)
                    .font(.title3)
                    .fontWeight(.heavy)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .imageScale(.small)
                    Text(event.formattedDate)
                    if let venue = event.venueName {
                        Text("•")
                        Text(venue)
                    }
                }
                .font(.caption)
                .foregroundStyle(Color("AvenueOffWhite").opacity(0.75))
                .lineLimit(1)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}
