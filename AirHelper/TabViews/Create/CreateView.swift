//
//  CreateView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/07/07.
//

import SwiftUI
struct TextFieldWithLabel: View {
    var label: String
    var placeholder : String
    @State var text: String = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            Text(label).font(.headline)
            TextField(placeholder, text: $text)
                .padding(.all)
                .clipShape(RoundedRectangle(cornerRadius: 5.0))
                .background(Color(red: 239.0/255.0, green: 243.0/255, blue: 244.0/255.0, opacity:1.0))
        }.padding(.horizontal,15)
    }
}

struct CreateView: View {
    @State var title: String = ""
    @State var password: String = ""
    @State var verboseLeft: String = ""
    @State var verboseRight: String = ""
    @State var minuties: String = ""
    
    let buttons = ["섬멸전", "폭탄전", "스파이전"]
    @State public var buttonSelected: Int?
    @State private var showingAlert = false
    
    var body: some View {
        GeometryReader { gp in
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
                    
                }
                
                
                Button(action: {
                    print("Button action")
                    self.create_validation()
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
                .padding(.top, 30)
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("입력"), message: Text("모든 항목을 입력해주세요."), dismissButton: .default(Text("확인")))
                }
                
            }.listRowInsets(EdgeInsets())

        }
    }
    
    func create_validation() -> Bool {
        if self.title == "" {
            self.showingAlert = true
            return false
        }
        else if self.password == "" {
            self.showingAlert = true
            return false
        }
        else if self.verboseLeft == "" {
            self.showingAlert = true
            return false
        }
        else if self.verboseRight == "" {
            self.showingAlert = true
            return false
        }
        else if self.minuties == "" {
            self.showingAlert = true
            return false
        }
        else if self.buttonSelected == nil {
            self.showingAlert = true
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
