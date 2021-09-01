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
            VStack(alignment: .center, spacing: 1){
                HStack(alignment: .center){
                   Text("방 제목")
                    .bold()
                    .frame(width: gp.size.width * 0.2, alignment: .center)
                    Text(self.roomData.title)
                        .frame(width: gp.size.width * 0.7, alignment: .center)
                }
                .frame(width: gp.size.width, alignment: .center)

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
