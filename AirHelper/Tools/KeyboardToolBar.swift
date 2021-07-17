import SwiftUI
import KeyboardToolbar

//extension View { // 키보드 밖 화면에서 스크롤시 키보드 사라짐
//    func endEditing(_ force: Bool) {
//        UIApplication.shared.windows.forEach { $0.endEditing(force)}
//    }
//}
//extension UIApplication { // 키보드밖 화면 터치시 키보드 사라짐
//    func endEditing() {
//        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}
let toolbarItems: [KeyboardToolbarItem] = [
    .dismissKeyboard
]
