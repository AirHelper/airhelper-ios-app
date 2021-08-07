//
//  AttendView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/07/19.
//

import SwiftUI
import Alamofire


struct RoomListView: View {
    
    var body: some View {
        GeometryReader { gp in
            VStack(){
                ScrollView(.vertical, showsIndicators: false){
                    Spacer()
                    NavigationLink(destination: PasswordView()){
                        VStack(alignment: .leading, spacing: 0){
                            Text("팀 내전")
                                .bold()
                                .font(.title3)
                            Text("폭탄전")
                                .font(.system(size: 13))
                            
                            HStack(alignment: .bottom, spacing: 10){
                                Text("5vs5")
                                    .font(.largeTitle.weight(.medium))
                                Image(systemName: "hourglass")
                                    .padding(.bottom, 6)
                                Text("30분")
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
                    Spacer()
                    NavigationLink(destination: PasswordView()){
                        VStack(alignment: .leading, spacing: 0){
                            Text("팀 내전")
                                .bold()
                                .font(.title3)
                            Text("스파이전")
                                .font(.system(size: 13))
                            
                            HStack(alignment: .bottom, spacing: 10){
                                Text("5vs5")
                                    .font(.largeTitle.weight(.medium))
                                Image(systemName: "hourglass")
                                    .padding(.bottom, 6)
                                Text("30분")
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
                    Spacer()
                    NavigationLink(destination: PasswordView()){
                        VStack(alignment: .leading, spacing: 0){
                            Text("팀 내전")
                                .bold()
                                .font(.title3)
                            Text("섬멸전")
                                .font(.system(size: 13))
                            
                            HStack(alignment: .bottom, spacing: 10){
                                Text("5vs5")
                                    .font(.largeTitle.weight(.medium))
                                Image(systemName: "hourglass")
                                    .padding(.bottom, 6)
                                Text("30분")
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
                .frame(width: gp.size.width)
                .border(Color.green)
                .navigationBarItems(
                    trailing:
                        Button(action: {
                            print("dd")
                        }) {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .foregroundColor(Color.black)
                                .scaledToFit()
                                .frame(width: gp.size.width * 0.06)
                        }
                )
                .onAppear(perform: {
                    print("dddd")
                    AF.request("http://airhelper.kro.kr/api/game/room", method: .get).responseJSON() { response in
                        switch response.result {
                        case .success(let responseObject):
                            do {
                                let data = try JSONSerialization.data(withJSONObject: responseObject, options: .prettyPrinted)
                                
                                let userlists = try JSONDecoder().decode([GameRoom].self, from: data)
                                print(userlists[0].title)
                            }
                            catch { }

                        case .failure(let error):
                            print("Error: \(error)")
                            return
                        }
                    }
                })
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

struct AttendView_Previews: PreviewProvider {
    static var previews: some View {
        RoomListView()
    }
}

