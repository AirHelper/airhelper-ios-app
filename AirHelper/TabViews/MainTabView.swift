//
//  MainTabView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/06/25.
//

import SwiftUI

struct MainTabView: View {
    @Binding var shouldPopToRoot : Bool
    
    var body: some View {
        TabView {
            Text("1")
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("필드 예약")
                }
            
            Text("2")
            .tabItem {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                Text("커뮤니티")
            }
            
            Text("3")
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("방 생성")
                }
            
            Text("4")
                .tabItem {
                    Image(systemName: "gamecontroller.fill")
                    Text("방 참가")
                }
            
            
            MoreView(shouldPopToRoot: self.$shouldPopToRoot)
            .tabItem {
                VStack{
                    Image(systemName: "ellipsis.circle")
                    Text("더보기")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        
    }
}

//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView()
//    }
//}
