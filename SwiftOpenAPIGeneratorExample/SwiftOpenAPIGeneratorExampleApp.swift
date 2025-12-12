//
//  SwiftOpenAPIGeneratorExampleApp.swift
//  SwiftOpenAPIGeneratorExample
//
//  Created by sangku on 12/10/25.
//

import SwiftUI
import AppUI
import AppService
import AppData

/// 샘플 앱의 진입점으로, 기본 Environment에 라이브 의존성을 제공해 바로 실행 가능한 상태를 만듭니다.
@main
struct SwiftOpenAPIGeneratorExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentFeature()
        }
    }
}
