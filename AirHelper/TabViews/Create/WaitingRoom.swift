//
//  WaitingRoom.swift
//  AirHelper
//
//  Created by Junho Son on 2021/08/11.
//

import SwiftUI

struct ResData: Codable {
    let type: String
    let data: [AttendUser]
}

struct AttendUser: Codable {
    var id: Int
    var user: User
    var team: String
    var is_admin: Bool
    var room: Int
}
struct User: Codable {
    var id: Int
    var user_id: String
    var email: String
    var name: String
    var call_sign: String
    var profile_image: String
}

final class RoomModel: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask? // 1
    var room_id: Int = 0
    var is_admin = "attend"

    @Published var attend_user_list: [AttendUser] = []
    
    // MARK: - Connection
    func connect() { // 2
        let url = URL(string: "ws://airhelper.kro.kr/ws/\(is_admin)/\(room_id)/")! // 3
        webSocketTask = URLSession.shared.webSocketTask(with: url) // 4
        webSocketTask?.receive(completionHandler: onReceive) // 5
        webSocketTask?.resume() // 6
    }
    
    func disconnect() { // 7
        webSocketTask?.cancel(with: .normalClosure, reason: nil) // 8
    }
    
    private func onReceive(incoming: Result<URLSessionWebSocketTask.Message, Error>) {
        webSocketTask?.receive(completionHandler: onReceive) // 1

        if case .success(let message) = incoming { // 2
            onMessage(message: message)
        }
        else if case .failure(let error) = incoming { // 3
            print("Error", error)
        }
    }
    
    private func onMessage(message: URLSessionWebSocketTask.Message) {
            if case .string(let text) = message {
                if let data = text.data(using: .utf8) {
                    let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                    
                    if json["type"] as! String == "user_attend" {
                        let decoder = JSONDecoder()
                        if let test = try? decoder.decode(ResData.self, from: data) {
                           
                            DispatchQueue.main.async { // 6
                                self.attend_user_list = test.data
                            }
                            
                        }
                    }
                }
                else {
                    return
                }

            }
        }
    
    
    func send(text: String) {

        webSocketTask?.send(.string(text)) { error in // 3
            if let error = error {
                print("Error sending message", error) // 4
            }
        }
    }
    
    deinit { // 9
        disconnect()
    }
}

struct WaitingRoom: View {
    var roomData: RoomData
    @State var is_admin = false
    var team = "레드팀"
    @StateObject private var model = RoomModel()
    @Environment(\.presentationMode) var presentation

    private func onCommit(message: String) {
        model.send(text: message)
    }
    
    var body: some View {
        GeometryReader { gp in
            VStack(alignment: .center, spacing: 0.5){
                //레드팀, 블루팀 구별
                HStack(alignment: .center, spacing: 3){
                    Button(action: {
                        print("레드팀")
                    }){
                        
                        HStack(){
                            Image("sword")
                                .resizable()
                                .scaledToFit()
                                .frame(width: gp.size.width / 17)
                            Text("RED TEAM")
                                .fontWeight(.bold)
                                .font(.system(size: 25))
                        }
                        .frame(width: gp.size.width*0.47, height: gp.size.height/10, alignment: .center)
                        .background(Color.red)
                        .foregroundColor(Color.white)
                        .cornerRadius(5)
                    }
                    Button(action: {
                        print("블루팀")
                    }){
                        HStack(){
                            Image("shield")
                                .resizable()
                                .scaledToFit()
                                .frame(width: gp.size.width / 17)
                            Text("BLUE TEAM")
                                .fontWeight(.bold)
                                .font(.system(size: 25))
                        }
                        .frame(width: gp.size.width*0.47, height: gp.size.height/10, alignment: .center)
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(5)
                    }
                }
                
                
                //마크, 콜사인, 상태 구분
                HStack(alignment: .center, spacing: 3){
                    HStack(){
                        Text("마크")
                            .frame(width: gp.size.width*0.1)
                        Text("콜사인")
                            .frame(width: gp.size.width*0.2, alignment: .leading)
                        Text("상태")
                            .frame(width: gp.size.width*0.1)
                    }
                    .frame(width: gp.size.width*0.47, height: gp.size.height * 0.04, alignment: .center)
                    .background(Color(hex: 0x3A383C))
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
                    
                    HStack(){
                        Text("마크")
                            .frame(width: gp.size.width*0.1)
                        Text("콜사인")
                            .frame(width: gp.size.width*0.2, alignment: .leading)
                        Text("상태")
                            .frame(width: gp.size.width*0.1)
                    }
                    .frame(width: gp.size.width*0.47, height: gp.size.height * 0.04, alignment: .center)
                    .background(Color(hex: 0x3A383C))
                    .foregroundColor(Color.white)
                    .cornerRadius(5)
                }
                //플레이어 목록
                HStack(alignment: .center, spacing: 3){
                    
                    HStack(){
                        List(){
                            ForEach(0..<model.attend_user_list.count, id: \.self) { index in
                                if model.attend_user_list[index].team == "레드팀" {
                                    HStack(){
                                        if let user_id: String = UserDefaults.standard.string(forKey: "user_id") {
                                            if Int(user_id) == model.attend_user_list[index].user.id {
                                                if model.attend_user_list[index].is_admin {
                                                    Text(Image(systemName: "crown.fill"))
                                                        .foregroundColor(Color.yellow)
                                                        .frame(width: gp.size.width*0.1)
                                                }
                                                else {
                                                    Text("")
                                                        .frame(width: gp.size.width*0.1)
                                                }
                                            }
                                            else {
                                                Text("")
                                                    .frame(width: gp.size.width*0.1)
                                            }
                                        }
                                        Text(model.attend_user_list[index].user.call_sign)
                                            .frame(width: gp.size.width*0.2, alignment: .leading)
                                        Text(Image(systemName: "checkmark"))
                                            .frame(width: gp.size.width*0.1, alignment: .center)
                                    }
                                    .frame(width: gp.size.width*0.47, alignment: .leading)
                                }
                            }
                            
                        }
                        .frame(width: gp.size.width*0.47, height: gp.size.height / 3, alignment: .center)
                    }
                    HStack(){
                        List(){
                            ForEach(0..<model.attend_user_list.count, id: \.self) { index in
                                if model.attend_user_list[index].team == "블루팀" {
                                    HStack(){
                                        if let user_id: String = UserDefaults.standard.string(forKey: "user_id") {
                                            if Int(user_id) == model.attend_user_list[index].user.id {
                                                if model.attend_user_list[index].is_admin {
                                                    Text(Image(systemName: "crown.fill"))
                                                        .foregroundColor(Color.yellow)
                                                        .frame(width: gp.size.width*0.1)
                                                }
                                                else {
                                                    Text("")
                                                        .frame(width: gp.size.width*0.1)
                                                }
                                            }
                                            else {
                                                Text("")
                                                    .frame(width: gp.size.width*0.1)
                                            }
                                        }
                                        Text(model.attend_user_list[index].user.call_sign)
                                            .frame(width: gp.size.width*0.2, alignment: .leading)
                                        Text(Image(systemName: "checkmark"))
                                            .frame(width: gp.size.width*0.1, alignment: .center)
                                    }
                                    .frame(width: gp.size.width*0.47, alignment: .leading)
                                }
                            }
                        }
                        .frame(width: gp.size.width*0.47, height: gp.size.height / 3, alignment: .center)
                    }
                }
                .frame(width: gp.size.width, alignment: .leading)
               
                
                Divider()
                //옵저버
                HStack(alignment: .center, spacing: 3){
                    Button(action: {
                        print("옵저버")
                    }){
                        HStack(){
                            Image(systemName: "eye.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: gp.size.width / 17)
                            Text("Observer")
                                .fontWeight(.bold)
                                .font(.system(size: 25))
                        }
                        .frame(width: gp.size.width*0.8, height: gp.size.height/10, alignment: .center)
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .cornerRadius(5)
                    }
                }
                
                //마크, 콜사인, 상태 구분
                HStack(alignment: .center, spacing: 3){
                    Text("마크")
                        .frame(width: gp.size.width*0.2)
                    Text("콜사인")
                        .frame(width: gp.size.width*0.4, alignment: .leading)
                    Text("상태")
                        .frame(width: gp.size.width*0.2)
                }
                .frame(width: gp.size.width*0.8, height: gp.size.height * 0.04, alignment: .center)
                .background(Color(hex: 0x3A383C))
                .foregroundColor(Color.white)
                .cornerRadius(5)
                
                
                //플레이어 목록
                HStack(alignment: .center, spacing: 3){
                    List(){
                        ForEach(0..<model.attend_user_list.count, id: \.self) { index in
                            if model.attend_user_list[index].team == "옵저버" {
                                HStack(){
                                    if let user_id: String = UserDefaults.standard.string(forKey: "user_id") {
                                        if Int(user_id) == model.attend_user_list[index].user.id {
                                            if model.attend_user_list[index].is_admin {
                                                Text(Image(systemName: "crown.fill"))
                                                    .foregroundColor(Color.yellow)
                                                    .frame(width: gp.size.width*0.15, alignment: .leading)
                                            }
                                            else {
                                                Text("")
                                                    .frame(width: gp.size.width*0.15, alignment: .leading)
                                            }
                                        }
                                        else {
                                            Text("")
                                                .frame(width: gp.size.width*0.15, alignment: .leading)
                                        }
                                    }
                                    Text("HERLOCK")
                                        .frame(width: gp.size.width*0.4, alignment: .leading)
                                    Text(Image(systemName: "checkmark"))
                                        .frame(width: gp.size.width*0.15, alignment: .center)
                                }
                                .frame(width: gp.size.width*0.8, alignment: .leading)
                            }
                        }
                    }
                    .frame(width: gp.size.width*0.8, height: gp.size.height / 8, alignment: .center)
                }
                .frame(width: gp.size.width, alignment: .center)
                
                VStack(){
                    if self.is_admin == true {
                        Button(action: {
                            print("게임시작")
                        }){
                            Text("게임시작")
                                .frame(width: gp.size.width * 0.7, height: gp.size.height*0.1, alignment: .center)
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .cornerRadius(5)
                                .font(.system(size: 25))
                        }
                    }
                }

            }
            .frame(width: gp.size.width, height: gp.size.height, alignment: .center)
        }
        .onAppear(perform: {
            self.model.room_id = self.roomData.id
            var dict = Dictionary<String, String>()
            if self.is_admin == true { //방장이면
                self.model.is_admin = "create"
                if let user_id = UserDefaults.standard.string(forKey: "user_id") {
                    dict = ["type": "user_attend", "user": user_id, "team": self.team, "is_admin": "True"]
                }
            }
            else {
                if let user_id = UserDefaults.standard.string(forKey: "user_id") {
                    dict = ["type": "user_attend", "user": user_id, "team": self.team]
                }
            }
            self.model.connect()
            if let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                let theJSONText = String(data: theJSONData, encoding: .utf8)
                print("JSON string = \(theJSONText!)")
                model.send(text: theJSONText!)
            }
        })
        .onDisappear(perform: {
            self.model.disconnect()
        })
        .navigationBarTitle(self.roomData.title)
        .navigationBarItems(leading: navigationBarLeadingItems, trailing: navigationBarTrailingItems)
        .navigationBarBackButtonHidden(true)
        
    }
    
    @ViewBuilder
    var navigationBarLeadingItems: some View {
        Button(action: {
            self.presentation.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
                .resizable()
                .foregroundColor(Color.black)
                .scaledToFit()
                .frame(width: 20)
                .opacity(0.6)
        }
    }
    
    @ViewBuilder
    var navigationBarTrailingItems: some View {
        Button(action: {
            print("dd")
        }) {
            Image(systemName: "gearshape.fill")
                .resizable()
                .foregroundColor(Color.black)
                .scaledToFit()
                .frame(width: 20)
                .opacity(0.6)
        }
    }
}

//struct WaitingRoom_Previews: PreviewProvider {
//    static var previews: some View {
//        WaitingRoom()
//    }
//}
