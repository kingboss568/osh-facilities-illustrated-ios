//
//  ResourceJPEG.swift
//  Loads an optimized image that lives as a loose bundle resource (not in Asset Catalog).
//
//  We use this instead of `Image(name)` because SwiftUI's Image(name) only
//  finds Asset Catalog entries reliably; loose HEIC files need explicit bundle URL lookup.
//

import SwiftUI
import UIKit

struct ResourceJPEG: View {
    let name: String          // basename without extension
    let ext: String           // default "heic"

    init(name: String, ext: String = "heic") {
        self.name = name
        self.ext = ext
    }

    var body: some View {
        if let img = Self.loadCached(name: name, ext: ext) {
            Image(uiImage: img)
                .resizable()
        } else {
            // Visible placeholder so missing images are obvious during development
            ZStack {
                Color(.systemGray5)
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Cache

    /// Tiny in-memory cache so scrolling a grid doesn't reload the same image repeatedly.
    /// Uses NSCache so iOS can purge under memory pressure.
    private static let cache = NSCache<NSString, UIImage>()

    private static func loadCached(name: String, ext: String) -> UIImage? {
        let key = "\(name).\(ext)" as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }
        // Try multiple lookup strategies: Asset Catalog, bundle root, or subdirectory.
        // at bundle root, or in an arbitrary subdirectory.
        if let img = UIImage(named: name) {
            cache.setObject(img, forKey: key)
            return img
        }
        for candidateExt in [ext, "heic", "png", "jpg", "jpeg"] {
            if let url = Bundle.main.url(forResource: name, withExtension: candidateExt) {
                if let img = UIImage(contentsOfFile: url.path) {
                    cache.setObject(img, forKey: key)
                    return img
                }
            }
        }
        // Search recursively as last resort
        if let resourcePath = Bundle.main.resourcePath,
           let enumerator = FileManager.default.enumerator(atPath: resourcePath) {
            let targets = Set([ext, "heic", "png", "jpg", "jpeg"].map { "\(name).\($0)" })
            while let item = enumerator.nextObject() as? String {
                if targets.contains((item as NSString).lastPathComponent) {
                    let full = (resourcePath as NSString).appendingPathComponent(item)
                    if let img = UIImage(contentsOfFile: full) {
                        cache.setObject(img, forKey: key)
                        return img
                    }
                }
            }
        }
        return nil
    }
}
