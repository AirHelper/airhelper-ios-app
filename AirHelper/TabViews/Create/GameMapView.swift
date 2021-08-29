//
//  GameMapView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/08/22.
//

import SwiftUI
import NMapsMap
import CoreLocation
import Combine
import Foundation

final class GameModel: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask? // 1
    var game_id: Int = 0
    
    @Published var players: Dictionary<String, Player> = [String: Player]()
    // MARK: - Connection
    func connect() { // 2
        let url = URL(string: "ws://airhelper.kro.kr/ws/game/\(game_id)/")! // 3
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
                print("실시간 데이터 : \(json)")
                let decoder = JSONDecoder()
                if json["type"] as! String == "timer" {
                    
                    if let data = try? decoder.decode(ResData.self, from: data) {
                        
                        DispatchQueue.main.async { // 6
                            
                        }
                        
                    }
                }
                else if json["type"] as! String == "location" {
                    if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [])
                    {
                        do {
                            let decoding_player = try JSONDecoder().decode(Player.self, from: jsonData)
                            self.players[decoding_player.user] = decoding_player
                        } catch {
                            print("ERROR:", error)
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

struct InGameMapView: UIViewRepresentable {
    @ObservedObject var viewModel = MapSceneViewModel()
    let view = NMFNaverMapView()
    
    @EnvironmentObject var players: PlayerData
    
    @State var markers: [String: NMFMarker] = [String: NMFMarker]()

    func makeUIView(context: Context) -> NMFNaverMapView {
        //let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: userLatitude, lng: userLongitude))
        view.showZoomControls = false
        view.mapView.zoomLevel = 18
        view.mapView.mapType = .hybrid
        //view.mapView.touchDelegate = context.coordinator
        view.mapView.addCameraDelegate(delegate: context.coordinator)
        view.mapView.addOptionDelegate(delegate: context.coordinator)

        view.mapView.positionMode = .direction
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        print("updateUIView 호출")
        
        for (key, value) in self.players.player {
            print("(\(key) : \(value))")
            DispatchQueue.global(qos: .default).async {
                // 백그라운드 스레드
                self.markers[key]?.mapView = nil
                self.markers[key] = NMFMarker()
                self.markers[key]?.position = NMGLatLng(lat: value.lat, lng: value.lng)
                self.markers[key]?.width = 25
                self.markers[key]?.height = 40
                self.markers[key]?.captionText = value.call_sign
                self.markers[key]?.captionAligns = [NMFAlignType.top]
                self.markers[key]?.captionColor = UIColor.red
                DispatchQueue.main.async {
                    // 메인 스레드
                    self.markers[key]?.mapView = uiView.mapView
                }
            }
//            var marker: [String: NMFMarker] = [String: NMFMarker]()
//            marker[key]?.position = NMGLatLng(lat: value.lat, lng: value.lng)
//            marker[key]?.width = 25
//            marker[key]?.height = 40
//            marker[key]?.captionText = value.call_sign
//            marker[key]?.captionAligns = [NMFAlignType.top]
//            marker[key]?.captionColor = UIColor.red
//            marker[key]?.mapView = uiView.mapView

//            self.markers[key] = NMFMarker(position: NMGLatLng(lat: 37.5666102, lng: 126.9783881))
//            self.markers[key]?.mapView = uiView.mapView

        }
    }
    
    
    class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate, NMFMapViewOptionDelegate {
        @ObservedObject var viewModel: MapSceneViewModel
        var cancellable = Set<AnyCancellable>()
        
        init(viewModel: MapSceneViewModel) {
            self.viewModel = viewModel
        }
        
        //카메라 이동이 끝나면 호출
        func mapViewCameraIdle(_ mapView: NMFMapView) {
            mapView.positionMode = .direction
        }
        
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel: self.viewModel)
    }
}

extension AppDelegate {
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        return AppDelegate.orientationLock
        
    }
    
}

class GameLocationManager: NSObject, ObservableObject {

    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()

    @Published var location: CLLocation?
    @Published var placemark: CLPlacemark?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func geoCode(with location: CLLocation) {

        geoCoder.reverseGeocodeLocation(location) { (placemark, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                self.placemark = placemark?.first
            }
        }
    }
}

extension GameLocationManager: CLLocationManagerDelegate {
    func locationManagerStop() -> Void {
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManagerStart() -> Void {
        self.locationManager.startUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
//        print("위치 업뎃 \(location.coordinate.latitude)  :  \(location.coordinate.longitude)")
        DispatchQueue.main.async {
            self.location = location
            self.geoCode(with: location)
        }

    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // TODO
    }
}

class PlayerData: ObservableObject {
    @Published var player: Dictionary<String, Player> = [String: Player]()
}

struct Player: Codable, Equatable {
    var alive: Bool
    var lat: Double
    var lng: Double
    var user: String
    var call_sign: String
    var team: String
    var type: String
}

struct GameMapView: View {
    @ObservedObject var locationManager: GameLocationManager = GameLocationManager()
    
    @Binding var roomData: RoomData
    @Binding var hideBar: Bool
    @Environment(\.presentationMode) var presentation
    
    @State var showOutAlert = false
    @StateObject var model = GameModel()
    @State var alive = true
    @Binding var is_admin: Bool
    @Binding var game_id: Int
    @Binding var team: String
    @StateObject var players = PlayerData()
    
    func location_send() -> Void {
        var dict = Dictionary<String, Any>()
        if let user_id = UserDefaults.standard.string(forKey: "user_id"), let location = self.locationManager.location?.coordinate {
            dict = ["type": "location", "user": user_id, "lat": location.latitude, "lng": location.longitude, "alive": self.alive]
            if let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                let theJSONText = String(data: theJSONData, encoding: .utf8)
//                print("위치 데이터 전송 = \(theJSONText!)")
                model.send(text: theJSONText!)
            }
        }
    }
    
    func get_timer() -> Void {
        var dict = Dictionary<String, Any>()
        dict = ["type": "timer"]
        if let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
            let theJSONText = String(data: theJSONData, encoding: .utf8)
            model.send(text: theJSONText!)
        }
    }
    
    var body: some View {
        GeometryReader { gp in
            ZStack(){
                InGameMapView()
                    .edgesIgnoringSafeArea(.all)
                    .onChange(of: self.locationManager.location, perform: { newValue in
                        self.location_send()
                    })
                    .onChange(of: self.alive, perform: { newValue in
                        self.location_send()
                    })
                    .onChange(of: self.model.players, perform: { newValue in
                        self.players.player = self.model.players
                        print("위치정보 변경완료")
                    })
                    .environmentObject(self.players)
                
                    Button(action: {
                        print("나가기")
                        self.showOutAlert = true
                    }){
                        Image(systemName: "clear")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .background(Color.black)
                            .border(Color.white)
                            .foregroundColor(Color.white)
                            .opacity(0.6)
                    }
                    .offset(x: gp.size.width / 2, y: -gp.size.height / 2.2)
                    
                    
                    Text("남은 시간  15:00")
                        .padding(2)
                        .background(Color.black)
                        .opacity(0.8)
                        .foregroundColor(Color.white)
                        .offset(x: -gp.size.width / 2.2, y: -gp.size.height / 2.2)
                    
                    Button(action: {
                        print("무전")
                    }){
                        HStack(){
                            Image(systemName: "mic.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color.white)
                                .frame(width: 20)
                            Text("무전")
                                .foregroundColor(Color.white)
                                .bold()
                                .font(.system(size: 20))
                        }
                        .frame(width: gp.size.width / 7, height: gp.size.height / 6)
                        .background(Color.black.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4).stroke(Color(.white), lineWidth: 1)
                        )
                        
                    }
                    .offset(x: gp.size.width / 2.5, y: gp.size.height / 8)
                    
                    Button(action: {
                        print("전사")
                        self.alive = false
                        self.locationManager.locationManagerStop()
                    }){
                        HStack(){
                            Image(systemName: "eye.slash")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color.white)
                                .frame(width: 30)
                            Text("전사")
                                .foregroundColor(Color.white)
                                .bold()
                                .font(.system(size: 20))
                        }
                        .frame(width: gp.size.width / 7, height: gp.size.height / 6)
                        .background(Color.red.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4).stroke(Color(.white), lineWidth: 1)
                        )
                        
                    }
                    .offset(x: gp.size.width / 2.5, y: gp.size.height / 3)
                
                
            }
            .navigationBarHidden(self.hideBar)
            .alert(isPresented: self.$showOutAlert){
                Alert(
                    title: Text("나가기"),
                    message: Text("정말로 게임에 나가시겠습니까?"),
                    primaryButton: .destructive(Text("네"), action: {self.presentation.wrappedValue.dismiss()}),
                    secondaryButton: .cancel(Text("아니오"), action: nil)
                )
            }
            
        }
        .onAppear(perform: {
            AppDelegate.orientationLock = UIInterfaceOrientationMask.landscape
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
            self.model.game_id = self.game_id
            self.model.connect()
            if self.is_admin {
                self.get_timer()
            }
        })
        .onDisappear(perform: {
            self.model.disconnect()
            self.hideBar = false
            DispatchQueue.main.async {
                AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                UINavigationController.attemptRotationToDeviceOrientation()
            }
        })
        
    }
    
}

//struct GameMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        GameMapView()
//    }
//}
