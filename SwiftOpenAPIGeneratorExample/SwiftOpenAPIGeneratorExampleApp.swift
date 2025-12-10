//
//  SwiftOpenAPIGeneratorExampleApp.swift
//  SwiftOpenAPIGeneratorExample
//
//  Created by sangku on 12/10/25.
//

import SwiftUI

@main
struct SwiftOpenAPIGeneratorExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentFeature()
                .environment(\.appDependencies, .preview())
        }
    }
}
