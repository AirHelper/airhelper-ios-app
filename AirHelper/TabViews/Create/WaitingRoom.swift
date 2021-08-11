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
    
    var body: some View {
        GeometryReader { gp in
            Text(self.roomData.title)
        }
        .onAppear(perform: {
            self.model.room_id = self.roomData.id
            self.model.connect()
        })
        .onDisappear(perform: {
            self.model.disconnect()
        })
    }
}

//struct WaitingRoom_Previews: PreviewProvider {
//    static var previews: some View {
//        WaitingRoom()
//    }
//}
