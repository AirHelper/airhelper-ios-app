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
                if json["type"] as! String == "user_attend" {
                    let decoder = JSONDecoder()
                    if let test = try? decoder.decode(ResData.self, from: data) {
                        
                        DispatchQueue.main.async { // 6
                            
                        }
                        
                    }
                }
                else if json["type"] as! String == "room_delete" {
                    DispatchQueue.main.async { // 6
                        
                    }
                }
                else if json["type"] as! String == "game_start" {
                    DispatchQueue.main.async { // 6
                        
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
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        //let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: userLatitude, lng: userLongitude))
        view.showZoomControls = false
        view.mapView.zoomLevel = 18
        view.mapView.mapType = .hybrid
        //view.mapView.touchDelegate = context.coordinator
        view.mapView.addCameraDelegate(delegate: context.coordinator)
        view.mapView.addOptionDelegate(delegate: context.coordinator)

        view.mapView.positionMode = .direction
        print(view.mapView.cameraPosition)
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        
        
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
    @Published var cnt = 0
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        print("위치 업뎃 \(location.coordinate.latitude)  :  \(location.coordinate.longitude)")
        DispatchQueue.main.async {
            self.location = location
            self.geoCode(with: location)
            self.cnt += 1
        }

    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // TODO
    }
}


struct GameMapView: View {
    @ObservedObject var locationManager: GameLocationManager = GameLocationManager()
    
    @Binding var roomData: RoomData
    @Binding var hideBar: Bool
    @Environment(\.presentationMode) var presentation
    
    @State var showOutAlert = false
    @StateObject private var model = GameModel()
    var body: some View {
        GeometryReader { gp in
            ZStack(){
                InGameMapView()
                    .edgesIgnoringSafeArea(.all)
                    .onChange(of: self.locationManager.location, perform: { newValue in
                        print("lat변경 : \(newValue)")
                    })

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
