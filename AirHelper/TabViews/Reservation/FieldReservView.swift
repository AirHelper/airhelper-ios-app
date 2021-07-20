//
//  FieldReservView.swift
//  AirHelper
//
//  Created by Junho Son on 2021/07/20.
//

import SwiftUI
import MapKit

struct FieldReservView: View {
    //서울 좌표
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.5666791, longitude: 126.9782914), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: false, userTrackingMode: .constant(.follow))
            .frame(width: 200, height: 200)
    }
}

struct FieldReservView_Previews: PreviewProvider {
    static var previews: some View {
        FieldReservView()
    }
}
