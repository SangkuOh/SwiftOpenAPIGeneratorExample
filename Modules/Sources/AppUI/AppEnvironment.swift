import SwiftUI

public extension EnvironmentValues {
    /// 화면에서 공통 의존성을 읽어오는 커스텀 Environment 값입니다.
    @Entry
    var appDependencies: AppDependencies = .live()
}
