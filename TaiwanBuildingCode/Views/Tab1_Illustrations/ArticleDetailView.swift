//
//  ArticleDetailView.swift
//  Tab 1 - illustration detail page (zoomable image + summary).
//

import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @EnvironmentObject var bookmarks: BookmarkStore
    @EnvironmentObject var iap: IAPManager
    @State private var showZoom = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Hero image (tap to fullscreen zoom)
                ResourceJPEG(name: article.imageAssetName)
                    .aspectRatio(3/4, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .onTapGesture { showZoom = true }

                // Title
                VStack(alignment: .leading, spacing: 6) {
                    Text(article.article_no)
                        .font(.subheadline.bold())
                        .foregroundStyle(AppTheme.color(for: article.seriesId))
                    Text(article.title_zh).font(.title2.bold())
                    Text(article.title_en).font(.subheadline).foregroundStyle(.secondary)
                }

                // Key visual
                section(icon: "🎯", title: "圖解重點", body: article.key_visual)

                // Summary
                section(icon: "📜", title: "條文摘要", body: article.summary)

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("\(article.id)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if !bookmarks.toggle(article.id, isUnlocked: iap.isUnlocked) {
                        // Free-tier bookmark cap hit; in production show an alert/paywall.
                    }
                } label: {
                    Image(systemName: bookmarks.contains(article.id) ? "bookmark.fill" : "bookmark")
                }
            }
        }
        .fullScreenCover(isPresented: $showZoom) {
            ImageZoomView(assetName: article.imageAssetName)
        }
    }

    private func section(icon: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(icon) \(title)").font(.headline)
            Text(body).font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.cardBG, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Pinch-zoom full screen

struct ImageZoomView: View {
    let assetName: String
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ResourceJPEG(name: assetName)
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { scale = max(1, min(5, lastScale * $0)) }
                            .onEnded { _ in lastScale = scale },
                        DragGesture()
                            .onChanged { offset = CGSize(width: lastOffset.width + $0.translation.width,
                                                          height: lastOffset.height + $0.translation.height) }
                            .onEnded { _ in lastOffset = offset }
                    )
                )
                .onTapGesture(count: 2) {
                    withAnimation {
                        if scale > 1 { scale = 1; offset = .zero; lastScale = 1; lastOffset = .zero }
                        else        { scale = 2.5; lastScale = 2.5 }
                    }
                }
            VStack {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                    }
                    .padding()
                }
                Spacer()
            }
        }
    }
}
