//
//  PasswordView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/07/20.
//

import SwiftUI
struct CustomTextField: UIViewRepresentable {
    
    class Coordinator: NSObject, UITextFieldDelegate {
        
        @Binding var text: String
        @Binding var nextResponder : Bool?
        @Binding var isResponder : Bool?
        
        
        init(text: Binding<String>,nextResponder : Binding<Bool?> , isResponder : Binding<Bool?>) {
            _text = text
            _isResponder = isResponder
            _nextResponder = nextResponder
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.isResponder = true
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.isResponder = false
                if self.nextResponder != nil {
                    self.nextResponder = true
                }
            }
        }
    }
    
    @Binding var text: String
    @Binding var nextResponder : Bool?
    @Binding var isResponder : Bool?
    
    var isSecured : Bool = false
    var keyboard : UIKeyboardType
    
    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.isSecureTextEntry = isSecured
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = keyboard
        textField.delegate = context.coordinator
        return textField
    }
    
    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text, nextResponder: $nextResponder, isResponder: $isResponder)
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text
        if isResponder ?? false {
            uiView.becomeFirstResponder()
        }
    }
    
}
struct PasswordView: View {
    @State var appeared: Double = 0
    @State var password: String = ""
    @Environment(\.presentationMode) var presentation

    @StateObject private var keyboardHandler = KeyboardHandler()
    init(){
        UINavigationBar.setAnimationsEnabled(false)
    }
    
    var body: some View {
        GeometryReader { gp in
            VStack(alignment: .center, spacing: 5){
                Text("방 비밀번호 입력")
                    .font(.title.bold())
                Text("참여코드를 입력해 주십시오.")
                    .font(.title3)
                    .foregroundColor(Color.gray)
                SecureField("", text: self.$password)
                    .onReceive(password.publisher.collect()) {
                        self.password = String($0.prefix(6))
                        if password.count == 6 {
                            print("6개")
                        }
                    }
                    .keyboardType(.numberPad)
                    .padding(.top, 20)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .frame(width: gp.size.width * 0.6, alignment: .center)
                    .foregroundColor(Color.blue)
                Divider()
                    .frame(width: gp.size.width * 0.4)
                
            }
            .frame(width:gp.size.width, height: gp.size.height / 1.0)
            .border(Color.green)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: navigationBarLeadingItems)
        }
        .opacity(appeared)
        .animation(Animation.easeInOut(duration: 3.0), value: appeared)
        .onAppear {self.appeared = 1.0}
        .onDisappear {self.appeared = 0.0}
        .padding(.bottom, keyboardHandler.keyboardHeight)
        .animation(.default)
        .keyboardToolbar(toolbarItems)
    }
    
    @ViewBuilder
    var navigationBarLeadingItems: some View {
        Button(action: {
            self.presentation.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
                .resizable()
                .foregroundColor(Color.black)
                .scaledToFit()
                .frame(width: 20)
                .opacity(0.6)
        }
    }
}


struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView()
    }
}
