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
class CurrentLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        print(#function, location)
    }
}
struct FieldReservView: View {
    @StateObject var locationManager = CurrentLocationManager()
    var userLatitude: Double {
        return locationManager.lastLocation?.coordinate.latitude ?? 0
    }

    var userLongitude: Double {
        return locationManager.lastLocation?.coordinate.longitude ?? 0
    }
    
    var body: some View {
        GeometryReader { gp in
            ZStack(){
                if self.userLatitude != 0 && self.userLongitude != 0 {
                    InGameMapView(userLatitude: self.userLatitude, userLongitude: self.userLongitude)
                        .frame(width: gp.size.width, height: gp.size.height)
                }
//                VStack(alignment: .leading) {
//                    Text("location status: \(locationManager.statusString)")
//                    HStack {
//                        Text("latitude: \(userLatitude)")
//                        Text("longitude: \(userLongitude)")
//                    }
//                    .foregroundColor(Color.red)
//                }
            }
        }

    }
}

struct FieldReservView_Previews: PreviewProvider {
    static var previews: some View {
        FieldReservView()
    }
}
