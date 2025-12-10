//
//  SwiftOpenAPIGeneratorExampleApp.swift
//  SwiftOpenAPIGeneratorExample
//
//  Created by sangku on 12/10/25.
//

import SwiftUI

/// 샘플 앱의 진입점으로, Preview 구성을 기본 Environment에 주입해 바로 실행 가능하게 합니다.
@main
struct SwiftOpenAPIGeneratorExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentFeature()
                .environment(\.appDependencies, .preview())
        }
    }
}
