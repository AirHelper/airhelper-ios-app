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
import Alamofire

struct TeamPlayerCount: Equatable {
    var redTeam: Int = -1
    var blueTeam: Int = -1
}

final class GameModel: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask? // 1
    var game_id: Int = 0
    
    @Published var players: Dictionary<String, Player> = [String: Player]() //팀 위치정보
    @Published var checkpoints: [CheckPoint] = [CheckPoint]() //체크 포인트 정보
    @Published var endTime = ""
    @Published var player_cnt = TeamPlayerCount()
    @Published var endGame = false
    @Published var newRoomID = -1
    @Published var bomb_data: Bomb = Bomb()
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
                
                if json["type"] as! String == "timer" {
                    DispatchQueue.main.async { // 6
                        self.endTime = json["end_time"] as! String
                    }
                }
                else if json["type"] as! String == "location" {
                    if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) {
                        do {
                            let decoding_player = try JSONDecoder().decode(Player.self, from: jsonData)
                            DispatchQueue.main.async {
                                self.players[decoding_player.user] = decoding_player
                            }
                            if let redTeam_cnt = json["redTeam_player_count"], let blueTeam_cnt = json["blueTeam_player_count"] {
                                DispatchQueue.main.async {
                                    self.player_cnt.redTeam = redTeam_cnt as! Int
                                    self.player_cnt.blueTeam = blueTeam_cnt as! Int
                                }
                            }
                        } catch {
                            print("ERROR:", error)
                        }
                    }
                }
                else if json["type"] as! String == "game_end" {
                    print("게임 종료")
                    if let redTeam_cnt = json["redTeam_player_count"], let blueTeam_cnt = json["blueTeam_player_count"], let room_id = json["room_id"] {
                        self.disconnect()
                        DispatchQueue.main.async {
                            self.endGame = true
                            self.player_cnt.redTeam = redTeam_cnt as! Int
                            self.player_cnt.blueTeam = blueTeam_cnt as! Int
                            self.newRoomID = room_id as! Int
                        }
                    }
                }
                else if json["type"] as! String == "checkpoint" {
                    print("체크포인트 공유")
                    if let lat = json["lat"], let lng = json["lng"], let team = json["team"] {
                        self.checkpoints.append(CheckPoint(lat: lat as! Double, lng: lng as! Double, team: team as! String))
                    }
                }
                else if json["type"] as! String == "bomb_install" {
                    print("폭탄 설치 메시지")
                    if let lat = json["lat"], let lng = json["lng"], let start_time = json["start_time"], let end_time = json["end_time"]{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm:ss"
                        DispatchQueue.main.async {
                            self.bomb_data.lat = lat as! Double
                            self.bomb_data.lng = lng as! Double

                            if let endTime = formatter.date(from: end_time as! String),
                               let startTime = formatter.date(from: formatter.string(from: Date())) {
                                self.bomb_data.bomb_time = Int(endTime.timeIntervalSince(startTime))
                            }
                            self.bomb_data.start_time = start_time as! String
                            self.bomb_data.end_time = end_time as! String
                            self.bomb_data.is_install = true
                        }
                    }
                }
                else if json["type"] as! String == "bomb_uninstall" {
                    DispatchQueue.main.async {
                        self.bomb_data.is_install = false
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
    @StateObject var model: GameModel
    var team: String
    var locationManager: GameLocationManager
    
    @State var bomb_marker: NMFMarker = NMFMarker()
    func makeUIView(context: Context) -> NMFNaverMapView {
        
        view.showZoomControls = false
        view.mapView.zoomLevel = 18
        view.mapView.mapType = .satellite
        
        
        view.mapView.addOptionDelegate(delegate: context.coordinator)
        if self.team != "옵저버" {
            view.mapView.addCameraDelegate(delegate: context.coordinator)
            view.mapView.positionMode = .direction
            view.mapView.touchDelegate = context.coordinator
        }
        
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        //폭탄 설치
        if self.players.bomb_data.is_install {
            self.bomb_marker.iconImage = NMFOverlayImage(name: "bomb")
            self.bomb_marker.width = 30
            self.bomb_marker.height = 30
            self.bomb_marker.position = NMGLatLng(lat: self.players.bomb_data.lat, lng: self.players.bomb_data.lng)
            self.bomb_marker.mapView = uiView.mapView
        }
        else {
            self.bomb_marker.mapView = nil
        }
        
        
        //체크포인트
        if self.players.checkpoint.count != 0 {
            for ping in self.players.checkpoint {
                if ping.team == self.team {
                    
                    var checkMarker = NMFMarker()
                    checkMarker.iconImage = NMFOverlayImage(name: "ping_marker")
                    checkMarker.width = 40
                    checkMarker.height = 40
                    checkMarker.position = NMGLatLng(lat: ping.lat, lng: ping.lng)
                    checkMarker.mapView = uiView.mapView
                    let when = DispatchTime.now() + 10
                    DispatchQueue.main.asyncAfter(deadline: when){
                        // your code with delay
                        checkMarker.mapView = nil
                    }
                }
            }
            self.players.checkpoint = []
        }
        
        if self.team == "옵저버", let location = self.locationManager.location {
            uiView.mapView.moveCamera(NMFCameraUpdate(scrollTo: NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)))
        }
        for (key, value) in self.players.player {
            if self.team != "옵저버" {
                if let user_id = UserDefaults.standard.string(forKey: "user_id") {
                    if user_id != key { //자신꺼 제외한 마커 표시
                        if self.team == value.team { //같은 팀이면
                            DispatchQueue.global(qos: .default).async {
                                // 백그라운드 스레드
                                
                                if self.markers[key]?.mapView != nil {
                                    self.markers[key]?.mapView = nil
                                }
                                self.markers[key] = NMFMarker()
                                self.markers[key]?.position = NMGLatLng(lat: value.lat, lng: value.lng)
                                self.markers[key]?.width = CGFloat(NMF_MARKER_SIZE_AUTO)
                                self.markers[key]?.height = CGFloat(NMF_MARKER_SIZE_AUTO)
                                self.markers[key]?.captionText = value.call_sign
                                self.markers[key]?.captionAligns = [NMFAlignType.top]
                                self.markers[key]?.captionColor = UIColor.red
                                if value.alive == false {
                                    self.markers[key]?.iconImage = NMF_MARKER_IMAGE_BLACK
                                }
                                DispatchQueue.main.async {
                                    // 메인 스레드
                                    self.markers[key]?.mapView = uiView.mapView
                                }
                            }
                        }
                    }
                }
            }
            else {
                if value.team == "레드팀" {
                    DispatchQueue.global(qos: .default).async {
                        // 백그라운드 스레드
                        if self.markers[key]?.mapView != nil {
                            self.markers[key]?.mapView = nil
                        }
                        self.markers[key] = NMFMarker()
                        self.markers[key]?.position = NMGLatLng(lat: value.lat, lng: value.lng)
                        self.markers[key]?.width = CGFloat(NMF_MARKER_SIZE_AUTO)
                        self.markers[key]?.height = CGFloat(NMF_MARKER_SIZE_AUTO)
                        self.markers[key]?.captionText = value.call_sign
                        self.markers[key]?.captionAligns = [NMFAlignType.top]
                        self.markers[key]?.captionColor = UIColor.red
                        if value.alive == false {
                            self.markers[key]?.iconImage = NMF_MARKER_IMAGE_BLACK
                        }
                        else {
                            self.markers[key]?.iconImage = NMF_MARKER_IMAGE_RED
                        }
                        DispatchQueue.main.async {
                            // 메인 스레드
                            self.markers[key]?.mapView = uiView.mapView
                        }
                    }
                }
                else if value.team == "블루팀" {
                    DispatchQueue.global(qos: .default).async {
                        // 백그라운드 스레드
                        if self.markers[key]?.mapView != nil {
                            self.markers[key]?.mapView = nil
                        }
                        self.markers[key] = NMFMarker()
                        self.markers[key]?.position = NMGLatLng(lat: value.lat, lng: value.lng)
                        self.markers[key]?.width = CGFloat(NMF_MARKER_SIZE_AUTO)
                        self.markers[key]?.height = CGFloat(NMF_MARKER_SIZE_AUTO)
                        self.markers[key]?.captionText = value.call_sign
                        self.markers[key]?.captionAligns = [NMFAlignType.top]
                        self.markers[key]?.captionColor = UIColor.red
                        if value.alive == false {
                            self.markers[key]?.iconImage = NMF_MARKER_IMAGE_BLACK
                        }
                        else {
                            self.markers[key]?.iconImage = NMF_MARKER_IMAGE_BLUE
                        }
                        DispatchQueue.main.async {
                            // 메인 스레드
                            self.markers[key]?.mapView = uiView.mapView
                        }
                    }
                }
            }
        }
    }
    
    
    class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate, NMFMapViewOptionDelegate {
        @ObservedObject var viewModel: MapSceneViewModel
        var cancellable = Set<AnyCancellable>()
        let marker = NMFMarker()
        var model: GameModel
        
        init(viewModel: MapSceneViewModel, model: GameModel) {
            self.viewModel = viewModel
            self.model = model
        }
        
        //카메라 이동이 끝나면 호출
        func mapViewCameraIdle(_ mapView: NMFMapView) {
            mapView.positionMode = .direction
        }
        
        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
//            marker.iconImage = NMFOverlayImage(name: "ping_marker")
//            marker.width = 40
//            marker.height = 40
//            marker.position = NMGLatLng(lat: latlng.lat, lng: latlng.lng)
//            marker.touchHandler = { (overlay: NMFOverlay) -> Bool in
//                overlay.mapView = nil
//                return true // 이벤트 소비, -mapView:didTapMap:point 이벤트는 발생하지 않음
//            }
//            marker.mapView = mapView
            self.checkpoint_send(lat: latlng.lat, lng: latlng.lng)
        }
        
        func checkpoint_send(lat: Double, lng: Double) -> Void {
            var dict = Dictionary<String, Any>()
            if let user_id = UserDefaults.standard.string(forKey: "user_id"){
                dict = ["type": "checkpoint", "user": user_id, "lat": lat, "lng": lng]
                if let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                    let theJSONText = String(data: theJSONData, encoding: .utf8)
                    model.send(text: theJSONText!)
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel: self.viewModel, model: self.model)
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
    @Published var checkpoint: [CheckPoint] = [CheckPoint]()
    @Published var bomb_data: Bomb = Bomb()
}

struct CheckPoint: Equatable { //체크포인트 정보
    var lat: Double
    var lng: Double
    var team: String
}

struct Player: Codable, Equatable { //유저 정보
    var alive: Bool
    var lat: Double
    var lng: Double
    var user: String
    var call_sign: String
    var team: String
    var type: String
}

struct Bomb: Equatable {
    var lat: Double = 0
    var lng: Double = 0
    var start_time: String = ""
    var end_time: String = ""
    var is_install: Bool = false
    var bomb_time: Int = 0
}
struct RoundedRectProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14)
                .frame(width: 250, height: 28)
                .foregroundColor(.white)
                .overlay(Color.white.opacity(0.5)).cornerRadius(14)
            
            RoundedRectangle(cornerRadius: 14)
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 250, height: 28)
                .foregroundColor(.blue)
        }
        .padding()
    }
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
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeRemaining: Int = 0
    @Binding var rootIsActive: Bool
    @State private var bombAmount: Double = 0.0
    @State private var progressIsActive: Bool = false
    @State private var dissolveIsActive: Bool = false
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
    
    func gameEnd_send() -> Void {
        AF.request("http://airhelper.kro.kr/api/game/room", method: .post, parameters: [
            "title": self.roomData.title,
            "password": self.roomData.password,
            "verbose_left": self.roomData.verbose_left,
            "verbose_right": self.roomData.verbose_right,
            "time": self.roomData.time,
            "game_type": self.roomData.game_type
        ], encoding: URLEncoding.httpBody).responseJSON() { response in
            switch response.result {
            case .success:
                if let data = try! response.result.get() as? [String: Any]{ //응답 데이터 체크
                    print(data)
                    if let room_id = data["id"] {
                        self.roomData.id = room_id as! Int
                        self.timeRemaining = -1
                        var dict = Dictionary<String, Any>()
                        dict = ["type": "game_end", "room_id": room_id as! Int]
                        if let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                            let theJSONText = String(data: theJSONData, encoding: .utf8)
                            model.send(text: theJSONText!)
                        }
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
                return
            }
        }
    }
    
    var body: some View {
        GeometryReader { gp in
            ZStack(){
                InGameMapView(model: self.model, team: self.team, locationManager: self.locationManager)
                    .edgesIgnoringSafeArea(.all)
                    .onChange(of: self.locationManager.location, perform: { newValue in //위치 변경때마다 전송
                        if self.team != "옵저버" {
                            self.location_send()
                        }
                    })
//                    .onChange(of: self.alive, perform: { newValue in //사망시 전송
//                        self.location_send()
//                    })
                    .onChange(of: self.model.players, perform: { newValue in //위치정보 받아서 지도에 마커표시
                        self.players.player = self.model.players
                    })
                    .onChange(of: self.model.checkpoints, perform: { newValue in //체크포인트 정보
                        if self.model.checkpoints.count != 0 {
                            self.players.checkpoint = self.model.checkpoints
                            self.model.checkpoints = []
                        }
                    })
                    .onChange(of: self.model.endTime, perform: { newValue in //남은시간 계산
                        let format = DateFormatter()
                        format.dateFormat = "HH:mm:ss"
                        if let startTime = format.date(from: format.string(from: Date())),
                           let endTime = format.date(from: self.model.endTime) {
                            
                            self.timeRemaining = Int(endTime.timeIntervalSince(startTime))
                        }
                    })
                    .onChange(of: self.model.player_cnt, perform: { newValue in //전사시 승패
                        if self.model.endGame == false { //게임이 끝나지 않았을 때
                            if self.roomData.game_type == 0 {
                                if self.model.player_cnt.redTeam == 0 || self.model.player_cnt.blueTeam == 0  {
                                    if self.is_admin {
                                        AF.request("http://airhelper.kro.kr/api/game/room", method: .post, parameters: [
                                            "title": self.roomData.title,
                                            "password": self.roomData.password,
                                            "verbose_left": self.roomData.verbose_left,
                                            "verbose_right": self.roomData.verbose_right,
                                            "time": self.roomData.time,
                                            "game_type": self.roomData.game_type
                                        ], encoding: URLEncoding.httpBody).responseJSON() { response in
                                            switch response.result {
                                            case .success:
                                                if let data = try! response.result.get() as? [String: Any]{ //응답 데이터 체크
                                                    print(data)
                                                    if let room_id = data["id"] {
                                                        print("방만들기 완료")
                                                        
                                                        self.roomData.id = room_id as! Int
                                                        self.timeRemaining = -1
                                                        var dict = Dictionary<String, Any>()
                                                        dict = ["type": "game_end", "room_id": room_id as! Int]
                                                        if let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                                                            let theJSONText = String(data: theJSONData, encoding: .utf8)
                                                            model.send(text: theJSONText!)
                                                        }
                                                    }
                                                }
                                            case .failure(let error):
                                                print("Error: \(error)")
                                                return
                                            }
                                        }
                                    }
                                }
                            }
                            else if self.roomData.game_type == 1 { //폭탄전 진행시 전사버튼 눌렀을 때 승패판정 (즉 한쪽팀이 전멸했을 때 승패판정)
                                if self.model.bomb_data.is_install {
                                    if self.model.player_cnt.blueTeam == 0 {
                                        if self.is_admin {
                                            gameEnd_send()
                                        }
                                    }
                                }
                                else{
                                    if self.model.player_cnt.redTeam == 0 {
                                        if self.is_admin {
                                            gameEnd_send()
                                        }
                                    }
                                }
                            }
                        }
                    })
                    .onChange(of: self.model.bomb_data, perform: { newValue in
                        self.progressIsActive = false
                        self.players.bomb_data = newValue
                        if newValue.is_install == false {
                            if self.is_admin {
                                AF.request("http://airhelper.kro.kr/api/game/room", method: .post, parameters: [
                                    "title": self.roomData.title,
                                    "password": self.roomData.password,
                                    "verbose_left": self.roomData.verbose_left,
                                    "verbose_right": self.roomData.verbose_right,
                                    "time": self.roomData.time,
                                    "game_type": self.roomData.game_type
                                ], encoding: URLEncoding.httpBody).responseJSON() { response in
                                    switch response.result {
                                    case .success:
                                        if let data = try! response.result.get() as? [String: Any]{ //응답 데이터 체크
                                            print(data)
                                            if let room_id = data["id"] {
                                                print("방만들기 완료")
                                                
                                                self.roomData.id = room_id as! Int
                                                self.timeRemaining = -1
                                                var dict = Dictionary<String, Any>()
                                                dict = ["type": "game_end", "room_id": room_id as! Int]
                                                if let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                                                    let theJSONText = String(data: theJSONData, encoding: .utf8)
                                                    model.send(text: theJSONText!)
                                                }
                                            }
                                        }
                                    case .failure(let error):
                                        print("Error: \(error)")
                                        return
                                    }
                                }
                            }
                        }
                    })
                    .onReceive(timer) { time in // 타이머
                        if self.model.endTime != "" {
                            if self.timeRemaining > 0 {
                                if self.roomData.game_type == 0 {
                                    self.timeRemaining -= 1
                                }
                                else if self.roomData.game_type == 1 {
                                    if self.model.bomb_data.is_install == false {
                                        self.timeRemaining -= 1
                                    }
                                }
                            }
                            else if self.timeRemaining == 0 { //시간 만료시
                                if self.is_admin, self.roomData.game_type == 0 {
                                    AF.request("http://airhelper.kro.kr/api/game/room", method: .post, parameters: [
                                        "title": self.roomData.title,
                                        "password": self.roomData.password,
                                        "verbose_left": self.roomData.verbose_left,
                                        "verbose_right": self.roomData.verbose_right,
                                        "time": self.roomData.time,
                                        "game_type": self.roomData.game_type
                                    ], encoding: URLEncoding.httpBody).responseJSON() { response in
                                        switch response.result {
                                        case .success:
                                            if let data = try! response.result.get() as? [String: Any]{ //응답 데이터 체크
                                                print(data)
                                                if let room_id = data["id"] {
                                                    print("게임 시간 만료!! 섬멸방만들기 완료")
                                                    
                                                    self.roomData.id = room_id as! Int
                                                    var dict = Dictionary<String, Any>()
                                                    dict = ["type": "game_end", "room_id": room_id as! Int]
                                                    if let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                                                        let theJSONText = String(data: theJSONData, encoding: .utf8)
                                                        model.send(text: theJSONText!)
                                                    }
                                                    self.timeRemaining = -1
                                                }
                                            }
                                        case .failure(let error):
                                            print("Error: \(error)")
                                            return
                                        }
                                    }
                                }
                                else if self.is_admin, self.roomData.game_type == 1 {
                                    AF.request("http://airhelper.kro.kr/api/game/room", method: .post, parameters: [
                                        "title": self.roomData.title,
                                        "password": self.roomData.password,
                                        "verbose_left": self.roomData.verbose_left,
                                        "verbose_right": self.roomData.verbose_right,
                                        "time": self.roomData.time,
                                        "game_type": self.roomData.game_type
                                    ], encoding: URLEncoding.httpBody).responseJSON() { response in
                                        switch response.result {
                                        case .success:
                                            if let data = try! response.result.get() as? [String: Any]{ //응답 데이터 체크
                                                print(data)
                                                if let room_id = data["id"] {
                                                    print("게임 시간 만료!! 폭탄방만들기 완료")
                                                    
                                                    self.roomData.id = room_id as! Int
                                                    var dict = Dictionary<String, Any>()
                                                    dict = ["type": "game_end", "room_id": room_id as! Int]
                                                    if let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                                                        let theJSONText = String(data: theJSONData, encoding: .utf8)
                                                        model.send(text: theJSONText!)
                                                    }
                                                    self.timeRemaining = -1
                                                }
                                            }
                                        case .failure(let error):
                                            print("Error: \(error)")
                                            return
                                        }
                                    }
                                }
                                self.timer.upstream.connect().cancel() //게임 시간 만료로 인한 타이머 종료
                            }
                            
                            if self.model.bomb_data.is_install, self.model.bomb_data.bomb_time > 0 {
                                self.model.bomb_data.bomb_time -= 1
                            }
                            else if self.model.bomb_data.is_install, self.model.bomb_data.bomb_time < 1 {
                                if self.is_admin {
                                    AF.request("http://airhelper.kro.kr/api/game/room", method: .post, parameters: [
                                        "title": self.roomData.title,
                                        "password": self.roomData.password,
                                        "verbose_left": self.roomData.verbose_left,
                                        "verbose_right": self.roomData.verbose_right,
                                        "time": self.roomData.time,
                                        "game_type": self.roomData.game_type
                                    ], encoding: URLEncoding.httpBody).responseJSON() { response in
                                        switch response.result {
                                        case .success:
                                            if let data = try! response.result.get() as? [String: Any]{ //응답 데이터 체크
                                                print(data)
                                                if let room_id = data["id"] {
                                                    print("폭탄 설치!! 폭탄전 방만들기 완료")
                                                    
                                                    self.roomData.id = room_id as! Int
                                                    self.timeRemaining = -1
                                                    var dict = Dictionary<String, Any>()
                                                    dict = ["type": "game_end", "room_id": room_id as! Int]
                                                    if let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                                                        let theJSONText = String(data: theJSONData, encoding: .utf8)
                                                        model.send(text: theJSONText!)
                                                    }
                                                }
                                            }
                                        case .failure(let error):
                                            print("Error: \(error)")
                                            return
                                        }
                                    }
                                }
                                
                                self.timer.upstream.connect().cancel() //게임 시간 만료로 인한 타이머 종료
                            }

                        }
                    }
                    .environmentObject(self.players)
                    .alert(isPresented: self.$model.endGame, content: {
                        var message = ""
                        if self.roomData.game_type == 0 {
                            if self.team != "옵저버" {
                                if self.model.player_cnt.redTeam > self.model.player_cnt.blueTeam {
                                    if self.team == "레드팀" {
                                        message = "승리하셨습니다."
                                    }
                                    else {
                                        message = "패배하셨습니다."
                                    }
                                }
                                else if self.model.player_cnt.redTeam < self.model.player_cnt.blueTeam {
                                    if self.team == "레드팀" {
                                        message = "패배하셨습니다."
                                    }
                                    else {
                                        message = "승리하셨습니다."
                                    }
                                }
                                else {
                                    message = "무승부입니다."
                                }
                            }
                            else {
                                message = "게임이 종료되었습니다."
                            }
                        }
                        
                        else if self.roomData.game_type == 1 { //폭탄전 승패 판정
                            if self.team == "레드팀" {
                                if self.model.bomb_data.is_install { //폭탄 설치 된상태에서 게임 종료
                                    message = "승리하셨습니다."
                                }
                                else { // 시간 만료
                                    message = "패배하셨습니다."
                                }
                            }
                            else if self.team == "블루팀" {
                                if self.model.bomb_data.is_install { //폭탄 설치 된상태에서 게임 종료
                                    message = "패배하셨습니다."
                                }
                                else { // 시간 만료
                                    message = "승리하셨습니다."
                                }
                            }
                            else if self.team == "옵저버" {
                                message = "게임이 종료되었습니다."
                            }
                        }
                        
                        self.roomData.id = self.model.newRoomID
                        return Alert(title: Text("게임 종료"), message: Text(message), dismissButton: .default(Text("나가기"), action: {
                            self.presentation.wrappedValue.dismiss()
                        }))
                    })
                
                if self.roomData.game_type == 1 { //폭탄전
                    if self.model.bomb_data.is_install { //폭탄 설치됬으면 타이머 보이게 하기
                        HStack(){
                            Image("폭탄전")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color.white)
                                .frame(width: 35)
                            
                            Text("\(String(format: "%02d" , self.model.bomb_data.bomb_time / 60)):\(String(format: "%02d", self.model.bomb_data.bomb_time % 60))")
                                .foregroundColor(Color.white)
                                .bold()
                                .font(.system(size: 30))
                                .minimumScaleFactor(0.001)
                        }
                        .frame(width: gp.size.width / 5, height: gp.size.height / 6)
                        .background(Color.black.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4).stroke(Color(.white), lineWidth: 1)
                        )
                        .offset(x: 0, y: -gp.size.height / 2.5)
                    }
                    if self.team == "레드팀"{
                        if self.progressIsActive {
                            ProgressView("폭탄 설치중... \(Int(self.bombAmount))%", value: self.bombAmount, total: 100)
                                .progressViewStyle(RoundedRectProgressViewStyle())
                                .onReceive(timer) { _ in
                                    if self.bombAmount < 100 {
                                        self.bombAmount += 10
                                    }
                                    else {
                                        self.progressIsActive = false
                                        if let location = self.locationManager.location?.coordinate {
                                            print("폭탄 설치 좌표 : \(location)")
                                            var dict = Dictionary<String, Any>()
                                            dict = ["type": "bomb_install", "lat": location.latitude, "lng": location.longitude]
                                            if let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                                                let theJSONText = String(data: theJSONData, encoding: .utf8)
                                                model.send(text: theJSONText!)
                                            }
                                        }
                                    }
                                }
                        }
                        Button(action: {
                            print("설치")
                            if self.players.bomb_data.is_install == false{
                                self.bombAmount = 0
                                self.progressIsActive = true
                            }

                        }){
                            HStack(){
                                Image("폭탄전")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40)
                                Text("설치")
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
                        .offset(x: -gp.size.width / 2.5, y: gp.size.height / 3)


                    }
                    else if self.team == "블루팀" {
                        if self.dissolveIsActive {
                            ProgressView("폭탄 해체중... \(Int(self.bombAmount))%", value: self.bombAmount, total: 100)
                                .progressViewStyle(RoundedRectProgressViewStyle())
                                .onReceive(timer) { _ in
                                    if self.bombAmount < 100 {
                                        self.bombAmount += 10
                                    }
                                    else {
                                        self.dissolveIsActive = false
                                        var dict = Dictionary<String, Any>()
                                        
                                        dict = ["type": "bomb_uninstall"]
                                        if let theJSONData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                                            let theJSONText = String(data: theJSONData, encoding: .utf8)
                                            model.send(text: theJSONText!)
                                        }
                                        
                                    }
                                    
                                }
                        }
                        Button(action: {
                            let bomb_location = CLLocation(latitude: self.model.bomb_data.lat, longitude: self.model.bomb_data.lng)
                            if let distanceInMeters = self.locationManager.location?.distance(from: bomb_location){
                                print("폭탄 해체 좌표 : \(distanceInMeters)")
                                if distanceInMeters <= 100 {
                                    self.bombAmount = 0
                                    self.dissolveIsActive = true
                                }
                                
                            }
                            
                        }){
                            HStack(){
                                Image(systemName: "wrench.and.screwdriver")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(Color.white)
                                    .frame(width: 40)
                                Text("해체")
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
                        .offset(x: -gp.size.width / 2.5, y: gp.size.height / 3)
                    }
                }
                
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
                .alert(isPresented: self.$showOutAlert){
                    Alert(
                        title: Text("나가기"),
                        message: Text("정말로 게임에 나가시겠습니까?"),
                        primaryButton: .destructive(Text("네"), action: {
                            self.rootIsActive = false
                            self.presentation.wrappedValue.dismiss()
                        }),
                        secondaryButton: .cancel(Text("아니오"), action: nil)
                    )
                }
                
                Text("남은 시간  \(String(format: "%02d" ,self.timeRemaining / 60)):\(String(format: "%02d", self.timeRemaining % 60))")
                    .padding(2)
                    .background(Color.black)
                    .opacity(0.8)
                    .foregroundColor(Color.white)
                    .offset(x: -gp.size.width / 2.2, y: -gp.size.height / 2.2)
                
                if self.team != "옵저버" {
                    Button(action: {
                        print("전사")
                        self.alive = false
                        self.location_send()
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
            }
            .navigationBarHidden(self.hideBar)
 
        }
        .onAppear(perform: {
            AppDelegate.orientationLock = UIInterfaceOrientationMask.landscape
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
            self.model.game_id = self.game_id
            self.model.connect()
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
