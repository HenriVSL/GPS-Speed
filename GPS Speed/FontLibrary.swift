//
//  FontLibrary.swift
//  GPS Speed
//
//  Discovers and registers every font bundled with the app at launch, then
//  exposes them as selectable options (alongside the iOS system font). Fonts
//  are found by recursively scanning the app bundle, so it doesn't matter which
//  folder they live in — just add the .ttf/.otf to the target and it shows up.
//

import SwiftUI
import CoreText

/// Loose grouping used to order fonts and decide which ones get the segment
/// ghost. A font still works regardless of which bucket it lands in. The raw
/// value also defines sort order in the font menu.
enum FontCategory: Int {
    case system
    case dseg
    case arcade
    case other

    /// Best-effort categorization from a font's family/PostScript name.
    static func detect(from name: String) -> FontCategory {
        let n = name.lowercased().replacingOccurrences(of: " ", with: "")
        if n.contains("dseg") { return .dseg }
        if ["arcade", "pressstart", "pixel", "8bit", "retro", "vcr", "press-start"].contains(where: n.contains) {
            return .arcade
        }
        return .other
    }
}

/// A single selectable display font.
struct FontOption: Identifiable, Hashable {
    /// "system", or the font's PostScript name.
    let id: String
    /// Full name including style, e.g. "DSEG7 Classic Bold".
    let displayName: String
    /// Family without style, e.g. "DSEG7 Classic".
    let familyName: String
    /// Style only, e.g. "Bold" / "Italic" / "Regular".
    let styleName: String
    let category: FontCategory
    /// nil for the system font; otherwise the PostScript name to render with.
    let postScriptName: String?

    func font(size: CGFloat) -> Font {
        if let postScriptName {
            // fixedSize keeps the big readout's proportions (no Dynamic Type scaling).
            return .custom(postScriptName, fixedSize: size)
        }
        return .system(size: size, weight: .semibold)
    }

    /// Whether this font emulates a physical segment display — only those get
    /// the dim "off segment" ghost behind the speed readout.
    var isSegmented: Bool { category == .dseg }

    static let system = FontOption(
        id: "system",
        displayName: "System",
        familyName: "System",
        styleName: "",
        category: .system,
        postScriptName: nil
    )
}

@MainActor
final class FontLibrary {
    static let shared = FontLibrary()

    /// System font first, then discovered fonts grouped by category.
    let options: [FontOption]

    private init() {
        var discovered: [FontOption] = []
        var seen = Set<String>()

        for url in Self.bundledFontURLs() {
            // Register so SwiftUI can resolve the font by PostScript name.
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)

            for face in Self.faces(in: url) where !seen.contains(face.postScriptName) {
                seen.insert(face.postScriptName)
                discovered.append(
                    FontOption(
                        id: face.postScriptName,
                        displayName: face.displayName,
                        familyName: face.familyName,
                        styleName: face.styleName,
                        category: FontCategory.detect(from: face.familyName + " " + face.postScriptName),
                        postScriptName: face.postScriptName
                    )
                )
            }
        }

        discovered.sort {
            $0.category.rawValue != $1.category.rawValue
                ? $0.category.rawValue < $1.category.rawValue
                : $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
        }

        options = [.system] + discovered
    }

    func option(for id: String) -> FontOption {
        options.first { $0.id == id } ?? .system
    }

    /// Default on launch: the classic 7-segment speedometer look if present,
    /// then any DSEG7 face, then any DSEG face, otherwise the system font.
    var defaultOption: FontOption {
        options.first { $0.postScriptName == "DSEG7Classic-Bold" }
            ?? options.first { $0.category == .dseg && ($0.postScriptName?.contains("DSEG7") ?? false) }
            ?? options.first { $0.category == .dseg }
            ?? .system
    }

    /// Custom (non-system) options only.
    var customOptions: [FontOption] {
        options.filter { $0.category != .system }
    }

    // MARK: Discovery

    private struct Face {
        let postScriptName: String
        let familyName: String
        let styleName: String
        let displayName: String
    }

    /// Recursively find every font file in the app bundle, wherever it sits.
    private static func bundledFontURLs() -> [URL] {
        guard let root = Bundle.main.resourceURL else { return [] }
        let exts: Set<String> = ["ttf", "otf", "ttc"]
        guard let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil) else {
            return []
        }
        var urls: [URL] = []
        for case let url as URL in enumerator where exts.contains(url.pathExtension.lowercased()) {
            urls.append(url)
        }
        return urls
    }

    private static func faces(in url: URL) -> [Face] {
        guard let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [CTFontDescriptor] else {
            return []
        }
        return descriptors.compactMap { descriptor in
            guard let postScript = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute) as? String else {
                return nil
            }
            let family = CTFontDescriptorCopyAttribute(descriptor, kCTFontFamilyNameAttribute) as? String ?? postScript
            let style = CTFontDescriptorCopyAttribute(descriptor, kCTFontStyleNameAttribute) as? String ?? "Regular"
            let display = style == "Regular" ? family : "\(family) \(style)"
            return Face(postScriptName: postScript, familyName: family, styleName: style, displayName: display)
        }
    }
}
