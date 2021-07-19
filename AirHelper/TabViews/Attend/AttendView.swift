//
//  AttendView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/07/19.
//

import SwiftUI

struct RoomListView: View {
    var body: some View {
        GeometryReader { gp in
            ScrollView(.vertical, showsIndicators: true){
                VStack(alignment:.leading, spacing: 5){
                    NavigationLink(destination: AttendView()){
                        VStack(alignment: .leading){
                            Text("교류전")
                                .multilineTextAlignment(.leading)
                            Text("폭탄전")
                        }
                        .frame(width: gp.size.width * 0.9, height: gp.size.height * 0.2)
                        .background(Color.blue)
                        .cornerRadius(5)
                        .foregroundColor(Color.white)
                    }

                }
            }
            .frame(width: gp.size.width)
            .border(Color.green)
        }
    }
}

struct AttendView_Previews: PreviewProvider {
    static var previews: some View {
        AttendView()
    }
}

struct AttendView: View {
    var body: some View {
        GeometryReader { gp in
            ScrollView(.vertical, showsIndicators: true){
                
            }
        }
    }
}
