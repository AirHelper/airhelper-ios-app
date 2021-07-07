//
//  CreateView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/07/07.
//

import SwiftUI


struct CreateView: View {
    @State var title: String = ""
    @State var password: String = ""
    
    var body: some View {
        GeometryReader { gp in
                VStack(alignment:.center, spacing: 5) {
                    HStack() {
                        Text("방 제목")
                            .frame(width: gp.size.width * 0.2, alignment: .center)
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .padding()
                        
                        TextField("", text: self.$title)
                            .frame(width: gp.size.width * 0.65)
                            .font(.system(size: 20, weight: .light, design: .default))
                            .overlay(
                                Rectangle()
                                    .frame(height: 0.25)
                                    .foregroundColor(.gray),
                                alignment: .bottom
                            )
                    }
                    HStack() {
                        Text("비밀번호")
                            .frame(width: gp.size.width * 0.2, alignment: .center)
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .padding()
                        
                        SecureField("", text: self.$password)
                            .keyboardType(.numberPad)
                            .frame(width: gp.size.width * 0.65)
                            .font(.system(size: 20, weight: .light, design: .default))
                            .overlay(
                                Rectangle()
                                    .frame(height: 0.5)
                                    .foregroundColor(.gray),
                                alignment: .bottom
                            )
                    }
                    
                    HStack() {
                        Text("인원 수")
                            .frame(width: gp.size.width * 0.2, alignment: .center)
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .padding()
                        
                        
                        Text("vs")
                            .font(.system(size: 20, weight: .light, design: .default))
                            .padding()
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
                    .padding(.vertical,10.0)
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
