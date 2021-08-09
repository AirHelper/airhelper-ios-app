//
//  MainTabView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/06/25.
//

import SwiftUI




struct MainTabView: View {
    @Binding var shouldPopToRoot : Bool
    @State private var currentTab: Tab = .reserve

    private enum Tab: String {
        case reserve="필드 예약", community="커뮤니티", add="방 생성", attend="방 참가", more="더보기"
    }
    var body: some View {
        TabView(selection: $currentTab) {
            
            FieldReservView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("필드 예약")
                }
                .tag(Tab.reserve)
                
            Text("2")
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("커뮤니티")
                }
                .tag(Tab.community)
            
            CreateView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("방 생성")
                }
                .tag(Tab.add)
            
            
            RoomListView()
                .tabItem {
                    Image(systemName: "gamecontroller.fill")
                    Text("방 참가")
                }
                .tag(Tab.attend)

            
            
            MoreView(shouldPopToRoot: self.$shouldPopToRoot)
                .tabItem {
                    VStack{
                        Image(systemName: "ellipsis.circle")
                        Text("더보기")
                    }
                }
                .tag(Tab.more)
        }
        //.navigationBarHidden(true)
        .navigationBarTitle(Text(currentTab.rawValue), displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        //.navigationBarItems(leading: navigationBarLeadingItems)
    }
    
//    @ViewBuilder
//    var navigationBarLeadingItems: some View {
//        if currentTab == .attend {
//            Button(action: {
//                
//            }) {
//                Image(systemName: "goforward")
//                    .resizable()
//                    .foregroundColor(Color.black)
//                    .scaledToFit()
//                    .frame(width: 20)
//                    .opacity(0.6)
//            }
//        }
//    }
}

//struct MainTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabView()
//    }
//}
