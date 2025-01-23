//
//  LocationManager.swift
//  IOS204MapSample_28
//
//  Created by cmStudent on 2024/05/10.
//

import Foundation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate{
    let manager = CLLocationManager()
    
    @Published var center = CLLocationCoordinate2D(latitude: 35.68146605, longitude: 139.76720623100823)
    @Published var target : CLLocationCoordinate2D? = nil
    @Published var targetDirection : Double? = nil
    
    override init() {
        super.init()
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map { location in
            center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            if let tmp = target{
                (targetDirection, _) = calculateBearing(pos1: center, pos2: tmp)
            }
        }
    }

    // ありがとうChatGPT
    func calculateBearing(pos1: CLLocationCoordinate2D, pos2: CLLocationCoordinate2D) -> (bearing: Double, distance: Double) {
        let φ1 = pos1.latitude * .pi / 180 // A地点の緯度をラジアンに変換
        let φ2 = pos2.latitude * .pi / 180 // B地点の緯度をラジアンに変換
        let Δλ = (pos2.longitude - pos1.longitude) * .pi / 180 // 経度の差をラジアンに変換

        let y = sin(Δλ) * cos(φ2)
        let x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ)

        var θ = atan2(y, x) // ラジアンで方位を計算
        θ = θ * 180 / .pi // 度に変換
        θ = (θ + 360).truncatingRemainder(dividingBy: 360) // 0〜360度に正規化

        // 距離の計算（ハーバサインの公式）
        let R = 6371.0 // 地球の半径 (km)
        let Δφ = φ2 - φ1
        let a = sin(Δφ / 2) * sin(Δφ / 2) +
                cos(φ1) * cos(φ2) * sin(Δλ / 2) * sin(Δλ / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let distance = R * c * 1000 // 距離 (m)

        return (bearing: θ, distance: distance)
    }
}
