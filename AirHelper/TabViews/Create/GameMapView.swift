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
    
    @Published var players: Dictionary<String, Player> = [String: Player]()
    @Published var endTime = ""
    @Published var player_cnt = TeamPlayerCount()
    @Published var endGame = false
    @Published var newRoomID = -1
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
                    if let redTeam_cnt = json["redTeam_player_count"], let blueTeam_cnt = json["blueTeam_player_count"], let room_id = json["room_id"] {
                        self.disconnect()
                        DispatchQueue.main.async {
                            self.player_cnt.redTeam = redTeam_cnt as! Int
                            self.player_cnt.blueTeam = blueTeam_cnt as! Int
                            self.newRoomID = room_id as! Int
                            self.endGame = true
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
    var team: String
    func makeUIView(context: Context) -> NMFNaverMapView {
        //let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: userLatitude, lng: userLongitude))
        view.showZoomControls = false
        view.mapView.zoomLevel = 18
        view.mapView.mapType = .hybrid
        //view.mapView.touchDelegate = context.coordinator
        
        view.mapView.addOptionDelegate(delegate: context.coordinator)
        if self.team != "옵저버" {
            view.mapView.addCameraDelegate(delegate: context.coordinator)
            view.mapView.positionMode = .direction
        }
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
//        print("updateUIView 호출")
        
        for (key, value) in self.players.player {
//            print("(\(key) : \(value))")
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
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeRemaining: Int = 0
    @Binding var rootIsActive: Bool

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
                InGameMapView(team: self.team)
                    .edgesIgnoringSafeArea(.all)
                    .onChange(of: self.locationManager.location, perform: { newValue in //위치 변경때마다 전송
                        self.location_send()
                    })
//                    .onChange(of: self.alive, perform: { newValue in //사망시 전송
//                        self.location_send()
//                    })
                    .onChange(of: self.model.players, perform: { newValue in //위치정보 받아서 지도에 마커표시
                        self.players.player = self.model.players
                        print("위치정보 변경완료")
                    })
                    .onChange(of: self.model.endTime, perform: { newValue in //남은시간 계산
                        let format = DateFormatter()
                        format.dateFormat = "HH:mm:ss"
                        if let startTime = format.date(from: format.string(from: Date())),
                           let endTime = format.date(from: self.model.endTime) {
                            
                            self.timeRemaining = Int(endTime.timeIntervalSince(startTime))
                        }
                    })
                    .onChange(of: self.model.player_cnt, perform: { newValue in //승패
                        if self.model.endGame == false { //게임이 끝나지 않았을 때
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
                                self.model.endGame = true
                            }
                        }
                    })
                    .onReceive(timer) { time in // 타이머
                        if self.model.endTime != "" {
                            if self.timeRemaining > 0 {
                                self.timeRemaining -= 1
                            }
                            else if self.timeRemaining == 0 { //시간 만료시
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
                            }
                        }
                    }
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
                .alert(isPresented: self.$model.endGame, content: {
                    var message = ""
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
                    self.roomData.id = self.model.newRoomID
                    return Alert(title: Text("게임 종료"), message: Text(message), dismissButton: .default(Text("나가기"), action: {
                        self.presentation.wrappedValue.dismiss()
                    }))
                })
                
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
