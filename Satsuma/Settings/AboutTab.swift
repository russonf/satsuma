import SwiftUI

struct AboutTab: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("🍊").font(.system(size: 64))
            Text("Satsuma").font(.title).bold()
            Text("Drag a file, hold a modifier, pick a segment.")
                .foregroundStyle(.secondary)
            Text("Version 0.1.0").font(.caption).foregroundStyle(.secondary)
            Spacer()
        }.padding()
    }
}
