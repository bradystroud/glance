import Photos
import SwiftUI
import UIKit

/// Reads images straight from the on-device photo library (incl. iCloud) via PhotoKit.
/// Serves "pages": two portrait photos side by side, or a single landscape photo —
/// so portrait shots fill a landscape screen without black bars or heavy cropping.
@MainActor
final class PhotoService: ObservableObject {
    @Published var authorized = false
    @Published var images: [UIImage] = []   // 1 (landscape) or 2 (portrait pair)
    @Published var token = 0                 // bumps each load → drives the crossfade

    private var assets: [PHAsset] = []
    private var pageStart = 0
    private var currentCount = 1
    private let manager = PHImageManager.default()
    private var loadTask: Task<Void, Never>?

    var hasPhotos: Bool { !assets.isEmpty }

    func requestAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            Task { @MainActor in
                let ok = (status == .authorized || status == .limited)
                self?.authorized = ok
                if ok { self?.loadAssets() }
            }
        }
    }

    private func loadAssets() {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssets(with: options)
        var arr: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in arr.append(asset) }
        assets = arr.shuffled()
        pageStart = 0
        loadCurrent()
    }

    func advance() {
        guard hasPhotos else { return }
        pageStart = (pageStart + currentCount) % assets.count
        loadCurrent()
    }

    func retreat() {
        guard hasPhotos else { return }
        // Step back over the previous page (1 or 2 photos), mirroring forward pairing.
        let prev1 = (pageStart - 1 + assets.count) % assets.count
        if assets.count > 1, isPortrait(assets[prev1]) {
            let prev2 = (pageStart - 2 + assets.count) % assets.count
            pageStart = isPortrait(assets[prev2]) ? prev2 : prev1
        } else {
            pageStart = prev1
        }
        loadCurrent()
    }

    private func isPortrait(_ asset: PHAsset) -> Bool {
        asset.pixelHeight > asset.pixelWidth
    }

    /// The 1–2 assets that make up the current page.
    private func currentPageAssets() -> [PHAsset] {
        guard hasPhotos else { return [] }
        let first = assets[pageStart]
        if assets.count > 1, isPortrait(first) {
            let next = assets[(pageStart + 1) % assets.count]
            if isPortrait(next) { return [first, next] }
        }
        return [first]
    }

    private func loadCurrent() {
        let pageAssets = currentPageAssets()
        guard !pageAssets.isEmpty else { return }
        currentCount = pageAssets.count

        loadTask?.cancel()
        loadTask = Task {
            var loaded: [UIImage] = []
            for asset in pageAssets {
                if let img = await requestImage(asset) { loaded.append(img) }
            }
            guard !Task.isCancelled, !loaded.isEmpty else { return }
            withAnimation(.easeInOut(duration: 1.4)) {
                self.images = loaded
                self.token += 1
            }
        }
    }

    private func requestImage(_ asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { cont in
            let opts = PHImageRequestOptions()
            opts.deliveryMode = .highQualityFormat   // single callback (safe for continuation)
            opts.isNetworkAccessAllowed = true        // fetch full-res from iCloud if needed
            opts.resizeMode = .exact
            manager.requestImage(for: asset, targetSize: CGSize(width: 1536, height: 2048),
                                 contentMode: .aspectFill, options: opts) { img, _ in
                cont.resume(returning: img)
            }
        }
    }
}
