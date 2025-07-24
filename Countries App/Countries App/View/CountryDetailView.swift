//
//  CountryDetailView.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//

import SwiftUI

struct CountryDetailView: View {
    @StateObject private var viewModel: CountryDetailViewModel
    let country: CountryListItem
    
    init(country: CountryListItem) {
        _viewModel = StateObject(wrappedValue: DIManager.shared.makeCountryDetailViewModel())
        self.country = country
    }
    
    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    private let sidePadding: CGFloat = 16
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                flagSection
                    .padding(.bottom, 16)
                InfoRowBlock(items: regionItems)
                
                contentSection
            }
            .padding(.horizontal, sidePadding)
            .padding(.bottom, 16)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.toggleFavorite(country)
                } label: {
                    Image(systemName: country.isFavorite ? "bookmark.fill" : "bookmark")
                        .foregroundColor(.blue)
                }
            }
        }
        .task(id: country.id) {
            AppLogger.ui.debug("🖼️ CountryDetailView: Fetching details for \(country.name.common)")
            await viewModel.fetchCountryDetail(name: country.name.common)
        }
    }
    
    private var flagSection: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: country.flags.png)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, idealHeight: 220)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 220)
                    .overlay(ProgressView())
            }
            
            VStack(alignment: .center, spacing: 4) {
                Text(country.name.common)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(country.name.official)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            .offset(x: 16, y: 16)
        }
        .padding(.top, 8)
    }
    
    private var regionItems: [(String, String)] {
        guard let detail = viewModel.countryDetail else { return [] }
        return [
            ("Region", detail.region),
            ("Subregion", detail.subregion ?? "-"),
            ("Capital", detail.capitalString)
        ]
    }
    
    @ViewBuilder
    private var contentSection: some View {
        switch viewModel.state {
        case .loading:
            ProgressView().frame(maxWidth: .infinity)
            
        case .error(let message):
            Text("Error: \(message)")
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
            
        case .success, .idle:
            if let detail = viewModel.countryDetail {
                InfoGridSection(detail: detail, gridColumns: gridColumns)
            }
        }
    }

    private struct InfoRowBlock: View {
        let items: [(title: String, value: String)]
        private let blockHeight: CGFloat = 100

        var body: some View {
            HStack(spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                    VStack(spacing: 6) {
                        Text(item.title).font(.headline)
                        Text(item.value)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: blockHeight)
                    if idx < items.count-1 {
                        Divider()
                            .frame(width: 1, height: blockHeight * 0.3)
                            .background(Color(.systemGray))
                            
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
}





