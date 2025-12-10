//
//  ContentFeature.swift
//  SwiftOpenAPIGeneratorExample
//
//  Created by sangku on 12/10/25.
//

import SwiftUI

extension ContentFeature: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            TextField("Name (optional)", text: $name)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)
            Button("Fetch greeting") {
                Task { await loadGreeting() }
            }
            .disabled(isLoading)
            if isLoading {
                ProgressView("Fetching greeting...")
            } else {
                Text(greeting)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("greeting-label")
            }
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("greeting-error-label")
            }
        }
        .padding()
    }
}

#Preview {
    ContentFeature()
        .environment(\.appDependencies, .preview())
}
