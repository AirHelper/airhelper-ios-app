//
//  AttendView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/07/19.
//

import SwiftUI
import Alamofire
import SwiftUIPullToRefresh

struct RoomListView: View {
    @State var rooms: [GameRoom]? = nil
    
    var body: some View {
        GeometryReader { gp in
            RefreshableScrollView(onRefresh: { done in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    getRoomList()
                    done()
                }
            }) {
                VStack(){
                    if let gamerooms: [GameRoom] = self.rooms {
                        ForEach(0..<gamerooms.count, id: \.self) { index in
                            if gamerooms[index].game_type == 0 {
                                NavigationLink(destination: PasswordView(roomData: gamerooms[index])){
                                    VStack(alignment: .leading, spacing: 0){
                                        Text(gamerooms[index].title)
                                            .bold()
                                            .font(.title3)
                                        Text("섬멸전")
                                            .font(.system(size: 13))
                                        
                                        HStack(alignment: .bottom, spacing: 10){
                                            Text("\(gamerooms[index].verbose_left)vs\(gamerooms[index].verbose_right)")
                                                .font(.largeTitle.weight(.medium))
                                            Image(systemName: "hourglass")
                                                .padding(.bottom, 6)
                                            Text("\(gamerooms[index].time)분")
                                                .fontWeight(.light)
                                                .opacity(0.8)
                                                .padding(.bottom, 5)
                                        }
                                    }
                                    .background(
                                        Image("Room-Vs")
                                            .resizable()
                                            .opacity(0.3)
                                            .position(x: gp.size.width * 0.65, y: gp.size.height * 0.11)
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 110)
                                        ,
                                        alignment: .leading
                                    )
                                    .padding()
                                    .frame(width: gp.size.width * 0.9, height: gp.size.height * 0.2, alignment: .leading)
                                    .background(Color.green)
                                    .cornerRadius(5)
                                    .foregroundColor(Color.white)
                                }
                            }
                            else {
                                if gamerooms[index].game_type == 1 {
                                    NavigationLink(destination: PasswordView(roomData: gamerooms[index])){
                                        VStack(alignment: .leading, spacing: 0){
                                            Text(gamerooms[index].title)
                                                .bold()
                                                .font(.title3)
                                            Text("폭탄전")
                                                .font(.system(size: 13))
                                            
                                            HStack(alignment: .bottom, spacing: 10){
                                                Text("\(gamerooms[index].verbose_left)vs\(gamerooms[index].verbose_right)")
                                                    .font(.largeTitle.weight(.medium))
                                                Image(systemName: "hourglass")
                                                    .padding(.bottom, 6)
                                                Text("\(gamerooms[index].time)분")
                                                    .fontWeight(.light)
                                                    .opacity(0.8)
                                                    .padding(.bottom, 5)
                                            }
                                        }
                                        .background(
                                            Image("Room-Boom")
                                                .resizable()
                                                .opacity(0.3)
                                                .position(x: gp.size.width * 0.65, y: gp.size.height * 0.11)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 110)
                                            ,
                                            alignment: .leading
                                        )
                                        .padding()
                                        .frame(width: gp.size.width * 0.9, height: gp.size.height * 0.2, alignment: .leading)
                                        .background(Color.blue)
                                        .cornerRadius(5)
                                        .foregroundColor(Color.white)
                                        
                                    }
                                    .isDetailLink(false)
                                }
                                else{
                                    NavigationLink(destination: PasswordView(roomData: gamerooms[index])){
                                        VStack(alignment: .leading, spacing: 0){
                                            Text(gamerooms[index].title)
                                                .bold()
                                                .font(.title3)
                                            Text("스파이전")
                                                .font(.system(size: 13))
                                            
                                            HStack(alignment: .bottom, spacing: 10){
                                                Text("\(gamerooms[index].verbose_left)vs\(gamerooms[index].verbose_right)")
                                                    .font(.largeTitle.weight(.medium))
                                                Image(systemName: "hourglass")
                                                    .padding(.bottom, 6)
                                                Text("\(gamerooms[index].time)분")
                                                    .fontWeight(.light)
                                                    .opacity(0.8)
                                                    .padding(.bottom, 5)
                                            }
                                        }
                                        .background(
                                            Image("Room-Spy")
                                                .resizable()
                                                .opacity(0.3)
                                                .position(x: gp.size.width * 0.65, y: gp.size.height * 0.11)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 110)
                                            ,
                                            alignment: .leading
                                        )
                                        .padding()
                                        .frame(width: gp.size.width * 0.9, height: gp.size.height * 0.2, alignment: .leading)
                                        .background(Color.gray)
                                        .cornerRadius(5)
                                        .foregroundColor(Color.white)
                                    }
                                    .isDetailLink(false)
                                }
                            }
                            
                        }
                        
                    }
                    
                    
                }
                //.frame(width: gp.size.width, height: gp.size.height, alignment: .top)

            }
            .onAppear(perform: {
                getRoomList()
            })
        }
    }
    
    func getRoomList() -> Void {
        AF.request("http://airhelper.kro.kr/api/game/room", method: .get).responseJSON() { response in
            switch response.result {
            case .success(let responseObject):
                print(responseObject)
                do {
                    let data = try JSONSerialization.data(withJSONObject: responseObject, options: .prettyPrinted)
                    
                    self.rooms = try JSONDecoder().decode([GameRoom].self, from: data)
                    if self.rooms?.count == 0 {
                        self.rooms = nil
                    }
                }
                catch { }
                
            case .failure(let error):
                print("Error: \(error)")
                return
            }
        }
    }
    
}


struct GameRoom: Codable {
    var id: Int
    var title: String
    var password: String
    var verbose_left: Int
    var verbose_right: Int
    var time: Int
    var game_type: Int
}

//struct AttendView_Previews: PreviewProvider {
//    static var previews: some View {
//        RoomListView()
//    }
//}

