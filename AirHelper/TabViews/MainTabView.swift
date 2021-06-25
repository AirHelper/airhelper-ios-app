//
//  MainTabView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/06/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var user: User
    //@Binding var gotoTab: Bool
    var body: some View {
        
        TabView {
            Text("1")
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("필드 예약")
                }
            
            NavigationView {
                List(1...10, id: \.self) { index in
                    NavigationLink(
                        destination: Text("Item #\(index) Details"),
                        label: {
                            Text("Item #\(index)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                        })
                    
                }
                .navigationTitle("TabView Demo")
            }
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
            
            
            NavigationView {
                MoreView()
            }
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
