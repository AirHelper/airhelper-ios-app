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

struct CreateView: View {
    @State var title: String = ""
    @State var password: String = ""
    @State var verboseLeft: String = ""
    @State var verboseRight: String = ""
    @State var minuties: String = ""
    
    let buttons = ["섬멸전", "폭탄전", "스파이전"]
    @State public var buttonSelected: Int?
    @State private var showingAlert = false
    
    @State var spyPercent : String = ""
    @State var spyMax : String = ""
    var body: some View {
        GeometryReader { gp in
            ScrollView(.vertical, showsIndicators: false){
                VStack(alignment:.center, spacing: 5) {
                    
                    TextField("방 제목", text: self.$title)
                        .padding()
                        .frame(width: gp.size.width * 0.9)
                    
                    Divider()
                        .frame(width: gp.size.width * 0.9)
                    
                    SecureField("비밀번호", text: self.$password)
                        .padding()
                        .frame(width: gp.size.width * 0.9)
                        .keyboardType(.numberPad)
                    
                    Divider()
                        .frame(width: gp.size.width * 0.9)
                    
                    HStack() {
                        TextField("5", text: self.$verboseLeft)
                            .keyboardType(.numberPad)
                            .padding()
                            .frame(width: gp.size.width * 0.2, alignment: .center)
                            .multilineTextAlignment(.center)
                        Text("VS")
                            .padding()
                        TextField("5", text: self.$verboseRight)
                            .keyboardType(.numberPad)
                            .padding()
                            .frame(width: gp.size.width * 0.2, alignment: .center)
                            .multilineTextAlignment(.center)
                    }
                    
                    Divider()
                        .frame(width: gp.size.width * 0.9)
                    
                    HStack(){
                        TextField("게임시간(분)", text: self.$minuties)
                            .keyboardType(.numberPad)
                            .padding()
                            .multilineTextAlignment(.trailing)
                            .frame(width: gp.size.width * 0.7)
                        
                        Text("분")
                            .padding()
                            .frame(width: gp.size.width * 0.2)
                    }
                    
                    Divider()
                        .frame(width: gp.size.width * 0.9)
                    
                    Group(){
                        HStack(){
                            Spacer()
                            Text("게임모드")
                                .padding()
                            Spacer()
                        }
                        HStack() {
                            ForEach(0..<buttons.count) { button in
                                Button(action: {
                                    self.buttonSelected = button
                                }) {
                                    VStack(){
                                        Image(self.buttonSelected == button ? self.buttons[button]+"-selected" : self.buttons[button])
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 80)
                                        Text("\(self.buttons[button])")
                                            .foregroundColor(self.buttonSelected == button ? Color.blue : Color.gray)
                                    }
                                    .frame(width: gp.size.width * 0.25, height: gp.size.width * 0.35)
                                    .clipShape(Rectangle())
                                    .border(self.buttonSelected == button ? Color.blue : Color.gray, width: 1)
                                }
                            }
                        }
                        
                        if self.buttonSelected == 1 {
                            Text("폭탄전")
                        }
                        else if self.buttonSelected == 2 {
                            HStack() {
                                TextField("스파이 발생확률", text: self.$spyPercent)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: gp.size.width * 0.7)
                                Text("%")
                            }
                            Divider()
                                .frame(width: gp.size.width * 0.9)
                            HStack() {
                                TextField("스파이 최대인원", text: self.$spyMax)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: gp.size.width * 0.7)
                                Text("명")
                            }
                            Divider()
                                .frame(width: gp.size.width * 0.9)
                        }
                    }
                    
                    Button(action: {
                        print("Button action")
                        if self.create_validation() == false {
                            self.showingAlert = true
                        }
                    }) {
                        HStack {
                            Text("생성하기")
                                .font(.title2)
                                .foregroundColor(Color.white)
                        }
                        .frame(width: gp.size.width * 0.6, height: gp.size.height * 0.1)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("입력"), message: Text("모든 항목을 입력해주세요."), dismissButton: .default(Text("확인")))
                    }
                    
                }.listRowInsets(EdgeInsets())
                
            }
            //        .onTapGesture(count: 1) { // 키보드밖 화면 터치시 키보드 사라짐
            //            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            //        }
            //        .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)}) // 키보드 밖 화면에서 스크롤시 키보드 사라짐
            .keyboardToolbar(toolbarItems)
        }
    }
    
    func create_validation() -> Bool {
        if self.title == "" {
            return false
        }
        else if self.password == "" {
            return false
        }
        else if self.verboseLeft == "" {
            return false
        }
        else if self.verboseRight == "" {
            return false
        }
        else if self.minuties == "" {
            return false
        }
        else if self.buttonSelected == nil {
            return false
        }
        
        return true
    }
}

struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateView()
    }
}
