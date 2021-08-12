//
//  WaitingRoom.swift
//  AirHelper
//
//  Created by Junho Son on 2021/08/11.
//

import SwiftUI

final class RoomModel: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask? // 1
    var room_id: Int = 0
    
    // MARK: - Connection
    func connect() { // 2
        let url = URL(string: "ws://airhelper.kro.kr/ws/create/\(room_id)/")! // 3
        webSocketTask = URLSession.shared.webSocketTask(with: url) // 4
        webSocketTask?.receive(completionHandler: onReceive) // 5
        webSocketTask?.resume() // 6
    }
    
    func disconnect() { // 7
        webSocketTask?.cancel(with: .normalClosure, reason: nil) // 8
    }
    
    private func onReceive(incoming: Result<URLSessionWebSocketTask.Message, Error>) {
        // Nothing yet...
    }
    
    deinit { // 9
        disconnect()
    }
}

struct WaitingRoom: View {
    var roomData: RoomData
    @StateObject private var model = RoomModel()
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        GeometryReader { gp in
            VStack(alignment: .center, spacing: 0.5){
                //레드팀, 블루팀 구별
                HStack(alignment: .center, spacing: 3){
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
            }
            .frame(width: gp.size.width, height: gp.size.height, alignment: .center)
        }
        .onAppear(perform: {
            self.model.room_id = self.roomData.id
            self.model.connect()
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
