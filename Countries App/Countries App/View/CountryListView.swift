//
//  CountryListView.swift
//  Countries App
//
//  Created by Temporal on 20/07/25.
//

import SwiftUI
import Kingfisher

struct CountryListView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @ObservedObject var viewModel: CountryListViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(viewModel.filteredCountries) { country in
                    CountryRow(country: country, toggleFavorite: { viewModel.toggleFavorite(country) })
                }
            }
        }
        .padding(.horizontal, 15)
        .task { await viewModel.fetchCountries() }
    }
}

struct CountryRow: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    let country: CountryListItem
    let toggleFavorite: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            KFImage(URL(string: country.flags.png))
                .resizable().scaledToFit().frame(width: 100, height: 60)
            VStack(alignment: .leading) {
                Text(country.name.common).font(.headline).lineLimit(nil)
                Text(country.name.official).font(.subheadline).lineLimit(nil)
                Text(country.capitalString).font(.caption).foregroundColor(.gray).lineLimit(nil)
            }
            Spacer()
            Button(action: toggleFavorite) {
                Image(systemName: country.isFavorite ? "bookmark.fill" : "bookmark")
                    .foregroundColor(.blue)
            }
        }
        .padding(10)
        .frame(width: UIScreen.main.bounds.width * 0.9, height: 100)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 4, y: 4)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: -1, y: -1)
        .contentShape(Rectangle())
        .onTapGesture { coordinator.showCountryDetail(country) }
    }
}
