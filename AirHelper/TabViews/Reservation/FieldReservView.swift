//
//  FieldReservView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/07/20.
//

import SwiftUI
import CoreLocation

final class ChatScreenModel: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask? // 1
    
    // MARK: - Connection
    func connect() { // 2
        let url = URL(string: "ws://211.63.219.212:8000/ws/create/11/")! // 3
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

struct FieldReservView: View {
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        GeometryReader { gp in
            ZStack(){
                Text("Time: \(timeRemaining)")
                            .font(.largeTitle)
                    .onReceive(timer) { time in
                        if self.timeRemaining > 0 {
                            self.timeRemaining -= 1
                        }
                    }
            }
        }

    }
}

struct FieldReservView_Previews: PreviewProvider {
    static var previews: some View {
        FieldReservView()
    }
}
