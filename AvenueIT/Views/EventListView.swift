//
//  EventListView.swift
//  AvenueIT
//
//  Created by Sankar Ram Subramanian on 15/4/26.
//

import SwiftUI

struct EventListView: View {
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
        HStack(spacing: 12) {
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
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.displayTag)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color("AvenueSlate"))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                Text(event.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(2)
                
                Text(event.formattedDate)
                    .font(.caption)
                    .foregroundStyle(Color("AvenueNeonCyan"))
                
                if let venue = event.venueName {
                    Text(venue)
                        .font(.caption)
                        .foregroundStyle(Color("AvenueOffWhite").opacity(0.5))
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
