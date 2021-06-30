//
//  UserInfo.swift
//  AirHelper
//
//  Created by Junho Son on 2021/06/30.
//

import SwiftUI

struct UserInfoView: View {
    var body: some View {
        
        NavigationLink(destination: Text("ddd")) {
            HStack {
                Image(systemName: "person.fill")
                Text("ddfs")
            }
        }
        .navigationTitle("ddd")
    }
}

struct UserInfo_Previews: PreviewProvider {
    static var previews: some View {
        UserInfoView()
    }
}
