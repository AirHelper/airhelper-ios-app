import SwiftUI
import KeyboardToolbar
import MapKit
import NMapsMap
import Combine

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel = MapSceneViewModel()
    @State var userLatitude: Double
    @State var userLongitude: Double
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()
        view.showZoomControls = false
        view.mapView.zoomLevel = 17
        view.mapView.mapType = .hybrid
        view.mapView.touchDelegate = context.coordinator
        
        
        //    let overlay = NMFOverlay()
        //
        //    overlay.touchHandler = { (overlay: NMFOverlay) -> Bool in
        //        print("오버레이 터치됨")
        //        return true
        //    }
        //    overlay.mapView = view.mapView
        //    let marker = NMFMarker()
        //    marker.position = NMGLatLng(lat: 37.5670135, lng: 126.9783740)
        //    marker.touchHandler = { (overlay) -> Bool in
        //        print("마커 1 터치됨")
        //        // 이벤트 전파
        //        return false
        //    }
        //    marker.mapView = view.mapView
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: userLatitude, lng: userLongitude))
        view.mapView.moveCamera(cameraUpdate)
        return view
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {}
    
    
    class Coordinator: NSObject, NMFMapViewTouchDelegate, NMFMapViewCameraDelegate, NMFMapViewOptionDelegate {
        @ObservedObject var viewModel: MapSceneViewModel
        var cancellable = Set<AnyCancellable>()
        let circle = NMFCircleOverlay()
        
        init(viewModel: MapSceneViewModel) {
            self.viewModel = viewModel
        }
        func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            if circle.mapView != nil {
                circle.mapView = nil
            }
            circle.center = NMGLatLng(lat: latlng.lat, lng: latlng.lng)
            circle.radius = 10
            circle.fillColor = UIColor.green.withAlphaComponent(0.75)
            circle.outlineWidth = 1
            circle.outlineColor = UIColor.red
            circle.touchHandler = { (overlay: NMFOverlay) -> Bool in
                overlay.mapView = nil
                return true
            }
            circle.mapView = mapView
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel: self.viewModel)
    }
}

class MapSceneViewModel: ObservableObject {
    
}
