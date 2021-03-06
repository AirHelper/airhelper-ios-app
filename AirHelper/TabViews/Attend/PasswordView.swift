//
//  PasswordView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/07/20.
//

import SwiftUI
import AlertToast
import Alamofire

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
    @State var roomData: GameRoom
    @State private var showToast = false
    @State var toastTitle = ""
    @State var waitingroom_isActive = false
    
    @State var attend_room: RoomData = RoomData()
    var body: some View {
        GeometryReader { gp in
            VStack(alignment: .center, spacing: 5){
                NavigationLink(destination: WaitingRoom(roomData: self.attend_room, rootIsActive: self.$waitingroom_isActive), isActive: self.$waitingroom_isActive){
                    EmptyView()
                }
                Text("??? ???????????? ??????")
                    .font(.title.bold())
                Text("??????????????? ????????? ????????????.")
                    .font(.title3)
                    .foregroundColor(Color.gray)
                SecureField("", text: self.$password)
                    .onReceive(password.publisher.collect()) {
                        self.password = String($0.prefix(6))
                        if password.count == 6 {
                            //????????? ?????? ?????? ??????
                            print("6???")
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
            .frame(width:gp.size.width, height: gp.size.height / 1.1)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: navigationBarLeadingItems, trailing: navigationBarTrailingItems)
        }
        .opacity(appeared)
        .animation(Animation.easeInOut(duration: 3.0), value: appeared)
        .onAppear {self.appeared = 1.0}
        .onDisappear {self.appeared = 0.0}
        .padding(.bottom, keyboardHandler.keyboardHeight)
        .animation(.default)
        .keyboardToolbar(toolbarItems)
        .toast(isPresenting: $showToast){
            AlertToast(type: .error(Color.red), title: self.toastTitle)
        }
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
    
    @ViewBuilder
    var navigationBarTrailingItems: some View {
        Button(action: {
            if self.roomData.password == self.password {
                //????????? ????????????, ?????? ??????????????? ???????????????.
                AF.request("http://airhelper.kro.kr/api/game/room/\(self.roomData.id)", method: .get).responseJSON() { response in
                    switch response.result {
                    case .success:
                        if let data = try! response.result.get() as? [String: Any]{ //?????? ????????? ??????
                            if let detail = data["detail"] {
                                self.toastTitle = detail as! String
                                self.showToast = true
                            }
                            else {
                                //????????? ??????
                                self.attend_room.id = self.roomData.id
                                self.attend_room.title = self.roomData.title
                                self.attend_room.password = self.roomData.password
                                self.attend_room.verbose_left = self.roomData.verbose_left
                                self.attend_room.verbose_right = self.roomData.verbose_right
                                self.attend_room.time = self.roomData.time
                                self.attend_room.game_type = self.roomData.game_type
                                self.waitingroom_isActive = true
                            }
                        }
                    case .failure(let error):
                        print("Error: \(error)")
                        return
                    }
                }

            }
            else {
                self.toastTitle = "??????????????? ????????????."
                showToast = true
            }
        }){
            Text("??????")
        }
    }
    
    func room_exists() -> Void {

    }
}


//struct PasswordView_Previews: PreviewProvider {
//    static var previews: some View {
//        PasswordView()
//    }
//}
