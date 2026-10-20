import SwiftUI

struct GeneralTab: View {
    @AppStorage("appearance.style")      private var style: String = "glass"
    @AppStorage("general.launchAtLogin") private var launchAtLogin = false
    @AppStorage("general.haptics")       private var haptics = true
    @AppStorage("mod.conversion")        private var modConversion = "shift"
    @AppStorage("mod.tools")             private var modTools = "command"
    @AppStorage("mod.actions")           private var modActions = "control"
    @AppStorage("float.behaviour")       private var floatBehaviour = "new"
    @AppStorage("terminal.app")          private var terminalApp = "Terminal"

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Style", selection: $style) {
                    Text("Glass").tag("glass"); Text("Solid").tag("solid")
                }.pickerStyle(.segmented)
            }
            Section("General") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                Toggle("Sound and haptic feedback", isOn: $haptics)
            }
            Section("Drag Modifiers") {
                modifierPicker("Conversion wheel", $modConversion)
                modifierPicker("Tools wheel", $modTools)
                modifierPicker("Actions wheel", $modActions)
                Text("Tap the chosen modifier combination while dragging files.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Section {
                Picker("Float behaviour", selection: $floatBehaviour) {
                    Text("Create a New Float").tag("new")
                    Text("Add to Existing Float").tag("existing")
                }
                Picker("Terminal app", selection: $terminalApp) {
                    Text("Terminal").tag("Terminal"); Text("iTerm").tag("iTerm"); Text("Ghostty").tag("Ghostty")
                }
            }
        }
        .padding()
    }

    private func modifierPicker(_ label: String, _ binding: Binding<String>) -> some View {
        Picker(label, selection: binding) {
            Text("Shift").tag("shift")
            Text("Command").tag("command")
            Text("Control").tag("control")
            Text("Option").tag("option")
        }
    }
}
