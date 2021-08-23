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
    @State var userLatitude: Double
    @State var userLongitude: Double
    let view = NMFNaverMapView()
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        //let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: userLatitude, lng: userLongitude))
        view.showZoomControls = false
        view.mapView.zoomLevel = 18
        view.mapView.mapType = .hybrid
        //view.mapView.touchDelegate = context.coordinator
        view.mapView.addCameraDelegate(delegate: context.coordinator)
        view.mapView.addOptionDelegate(delegate: context.coordinator)
        
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
    @StateObject var locationManager = CurrentLocationManager()
    var userLatitude: Double {
        return locationManager.lastLocation?.coordinate.latitude ?? 0
    }

    var userLongitude: Double {
        return locationManager.lastLocation?.coordinate.longitude ?? 0
    }
    @Binding var hideBar: Bool
    @Environment(\.presentationMode) var presentation
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.50007773, longitude: -0.1246402), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    var body: some View {
        GeometryReader { gp in
            ZStack(){
                if self.userLatitude != 0 && self.userLongitude != 0 {
                    InGameMapView(userLatitude: self.userLatitude, userLongitude: self.userLongitude)
                        .edgesIgnoringSafeArea(.all)
                }
                    
            }.navigationBarHidden(self.hideBar)
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
