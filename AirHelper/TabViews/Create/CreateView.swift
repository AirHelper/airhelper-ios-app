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
                
                ForEach(0..<buttons.count) { button in
                    Button(action: {
                        self.buttonSelected = button
                    }) {
                        Text("\(self.buttons[button])")
                            .padding()
                            .foregroundColor(.white)
                            .background(self.buttonSelected == button ? Color.blue : Color.green)
                            .clipShape(Capsule())
                    }
                }
                
                Button(action: {}) {
                    HStack{
                        Spacer()
                        Text("생성하기")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .padding(.vertical, 10.0)
                .clipShape(RoundedRectangle(cornerRadius: 4.0))
                .background(Color.blue)
                .padding(.horizontal, 80)
                
            }.listRowInsets(EdgeInsets())
            
        }
    }
}

struct CreateView_Previews: PreviewProvider {
    static var previews: some View {
        CreateView()
    }
}
