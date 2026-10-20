import Foundation

/// Single source of truth for what formats Satsuma can convert to/from.
/// Used both by the Compatibility settings matrix and (eventually) to
/// gate wheel segments when a conversion is impossible.
enum CompatibilityCatalog {
    struct Section {
        let title: String
        let rows: [String]
        let cols: [String]
        /// Returns true if row -> col is supported.
        let supports: (String, String) -> Bool
    }

    static let sections: [Section] = [
        imagesSection,
        videoSection,
        audioSection,
        documentsSection,
        archivesSection
    ]

    private static let imagesSection = Section(
        title: "Images",
        rows: ["JPG","PNG","WEBP","HEIC","TIFF","AVIF","BMP","SVG"],
        cols: ["JPG","PNG","WEBP","HEIC","TIFF","AVIF","BMP","PDF"],
        supports: { src, dst in
            // ImageIO handles everything except SVG as source.
            if src == dst { return false }
            let imageInputs: Set<String> = ["JPG","PNG","WEBP","HEIC","TIFF","AVIF","BMP"]
            return imageInputs.contains(src)
        }
    )

    private static let videoSection = Section(
        title: "Video",
        rows: ["MP4","MOV","M4V"],
        cols: ["MP4","MOV","M4V","WEBM"],
        supports: { src, dst in
            if src == dst { return false }
            // AVFoundation can read these and write MP4/MOV/M4V. WEBM encode unsupported.
            if dst == "WEBM" { return false }
            return true
        }
    )

    private static let audioSection = Section(
        title: "Audio",
        rows: ["M4A","WAV","AAC","AIFF","MP3","FLAC"],
        cols: ["M4A","WAV","AAC","AIFF","MP3","FLAC"],
        supports: { src, dst in
            if src == dst { return false }
            // AVFoundation can read almost anything; MP3/FLAC encode not supported.
            if dst == "MP3" || dst == "FLAC" { return false }
            return true
        }
    )

    private static let documentsSection = Section(
        title: "Documents",
        rows: ["PDF","RTF","DOCX","PAGES","TXT","MD","HTML"],
        cols: ["PDF","RTF","DOCX","HTML","TXT","MD"],
        supports: { src, dst in
            if src == dst { return false }
            // textutil pipeline: anything textual converts between most formats.
            // PDF-as-source isn't rendered by textutil; mark unsupported.
            if src == "PDF" { return false }
            return true
        }
    )

    private static let archivesSection = Section(
        title: "Archives",
        rows: ["Folder","Multi-file","Single file"],
        cols: ["ZIP","TAR","TGZ","GZ"],
        supports: { src, dst in
            // GZ compresses one file at a time only.
            if dst == "GZ" { return src == "Single file" }
            return true
        }
    )
}
