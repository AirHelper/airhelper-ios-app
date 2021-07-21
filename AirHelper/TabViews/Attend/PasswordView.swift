//
//  PasswordView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/07/20.
//

import SwiftUI

struct PasswordView: View {
    @State var appeared: Double = 0
    var body: some View {
        GeometryReader { gp in
            VStack(alignment: .center, spacing: 5){
                Text("방 비밀번호 입력")
                    .font(.title.bold())
                Text("참여코드를 입력해 주십시오.")
                    .font(.title3)
                    .foregroundColor(Color.gray)
            }
            .frame(width:gp.size.width, height: gp.size.height / 1.5)
            .border(Color.green)
            .navigationBarBackButtonHidden(true)
            
        }
        .transition(AnyTransition.opacity.animation(.easeOut(duration: 2)))
        .opacity(appeared)
        .animation(Animation.easeInOut(duration: 3.0), value: appeared)
        .onAppear {self.appeared = 1.0}
        .onDisappear {self.appeared = 0.0}
        
        
    }
}


struct PasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordView()
    }
}
