//
//  GCPresentedView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/09/01.
//

import SwiftUI

struct GCPresentedView: View {
    @Environment(\.presentationMode) var mode
    @Binding var roomData: RoomData
    var body: some View {
        GeometryReader { gp in
            Form{
                Section(header: Text("기본 정보")){
                    HStack {
                        Text("방 제목")
                            .bold()
                        Spacer()
                        Text(self.roomData.title)
                    }
                    HStack {
                        Text("비밀번호")
                            .bold()
                        Spacer()
                        Text(self.roomData.password)
                    }
                    HStack {
                        Text("대결 인원")
                            .bold()
                        Spacer()
                        Text("\(self.roomData.verbose_left) vs \(self.roomData.verbose_right)")
                    }
                    HStack {
                        Text("게임 시간")
                            .bold()
                        Spacer()
                        Text("\(self.roomData.time)분")
                    }
                    HStack {
                        Text("게임 모드")
                            .bold()
                        Spacer()
                        switch self.roomData.game_type {
                        case 0:
                            Text("섬멸전")
                        case 1:
                            Text("폭탄전")
                        case 2:
                            Text("스파이전")
                        default:
                            Text("섬멸전")
                        }
                    }
                }
            }
            .navigationBarTitle(Text("방 정보"), displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    self.mode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                })
            )
        }
    }
}

//struct GCPresentedView_Previews: PreviewProvider {
//    static var previews: some View {
//        GCPresentedView()
//    }
//}
