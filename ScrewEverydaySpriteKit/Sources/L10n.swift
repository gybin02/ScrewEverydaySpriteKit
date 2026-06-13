import Foundation

extension String {
    var localized: String {
        // 使用 iOS 系统标准的本地化接口，读取 Localizable.xcstrings 里的多语言翻译
        return NSLocalizedString(self, comment: "")
    }
    
    func localizedFormat(_ arguments: CVarArg...) -> String {
        let format = self.localized
        return String(format: format, arguments: arguments)
    }
}

