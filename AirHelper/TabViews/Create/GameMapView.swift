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
import MapKit
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
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {}
    
    
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
struct GameMapView: View {
    @Binding var roomData: RoomData
    @Binding var hideBar: Bool
    @Environment(\.presentationMode) var presentation
    
    @State var showOutAlert = false
    var body: some View {
        GeometryReader { gp in
            ZStack(){
                InGameMapView()
                    .edgesIgnoringSafeArea(.all)
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
                
            }.navigationBarHidden(self.hideBar)
            .alert(isPresented: self.$showOutAlert){
                Alert(
                  title: Text("나가기"),
                  message: Text("정말로 게임에 나가시겠습니까?"),
                    primaryButton: .destructive(Text("네"), action: {self.presentation.wrappedValue.dismiss()}),
                    secondaryButton: .cancel(Text("아니오"), action: nil)
                )
            }
        }.onAppear(perform: {
            AppDelegate.orientationLock = UIInterfaceOrientationMask.landscape
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            UINavigationController.attemptRotationToDeviceOrientation()
        })
        .onDisappear(perform: {
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
