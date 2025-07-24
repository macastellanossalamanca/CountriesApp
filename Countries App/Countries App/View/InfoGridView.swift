//
//  InfoGridView.swift
//  Countries App
//
//  Created by Temporal on 22/07/25.
//

import SwiftUI
import Kingfisher

struct InfoGridSection: View {
    let detail: CountryDetail
    let gridColumns: [GridItem]
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            InfoBlock(
                title: "Timezone(s)",
                value: detail.timezones.map { "• \($0)" }.joined(separator: "\n"),
                alignment: .leading,
                maxLines: 3
            )
            
            InfoBlock(
                title: "Population",
                value: NumberFormatter.localizedString(
                    from: NSNumber(value: detail.population),
                    number: .decimal
                )
            )
            
            InfoBlock(
                title: "Languages",
                value: detail.languages.map { "• \($0.value)" }.joined(separator: "\n"),
                alignment: .leading,
                maxLines: 3
            )
            
            InfoBlock(
                title: "Currencies",
                value: detail.currenciesString,
                alignment: .center,
                maxLines: 2
            )
            
            DriveSideBlock(side: detail.car.side)
            CoatOfArmsBlock(urlString: detail.coatOfArms?.png)
        }
        .padding(.top, 12)
    }
    
    // MARK: — Componente reutilizable para grid
    
    private struct InfoBlock: View {
        let title: String
        let value: String
        var alignment: HorizontalAlignment = .center
        var maxLines: Int? = nil           // <-- nuevo
        private let blockHeight: CGFloat = 100
        
        var body: some View {
            VStack(alignment: alignment, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(value)
                    .font(.subheadline)
                    .multilineTextAlignment(
                        alignment == .center ? .center : .leading
                    )
                    .foregroundColor(.secondary)
                    .lineLimit(maxLines)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity, minHeight: blockHeight)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: — Driving side
    
    private struct DriveSideBlock: View {
        let side: String
        private let blockHeight: CGFloat = 100
        
        var body: some View {
            VStack(spacing: 6) {
                Text("Car Drive Side").font(.headline)
                HStack(spacing: 8) {
                    Text("LEFT")
                        .font(.caption)
                        .fontWeight(side.lowercased()=="left" ? .semibold : .regular)
                        .foregroundColor(side.lowercased()=="left" ? .black : .secondary)
                    Image(systemName: "car")
                        .padding(5)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 0.5)
                        )
                    Text("RIGHT")
                        .font(.caption)
                        .fontWeight(side.lowercased()=="right" ? .semibold : .regular)
                        .foregroundColor(side.lowercased()=="right" ? .black : .secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: blockHeight)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: — Coat of Arms
    
    private struct CoatOfArmsBlock: View {
        let urlString: String?
        private let blockHeight: CGFloat = 100
        
        var body: some View {
            VStack(spacing: 6) {
                Text("Coat of Arms").font(.headline)
                if let urlString {
                    KFImage(URL(string: urlString))
                        .resizable().scaledToFit().frame(height: 50)
                } else {
                    Image(systemName: "shield")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: blockHeight)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
}
