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
                VStack(alignment:.center, spacing: 5){
                    NavigationLink(destination: AttendView()){
                        
                    }
                }
            }
            .frame(width: gp.size.width)
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
