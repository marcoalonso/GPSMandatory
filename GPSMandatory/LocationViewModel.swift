//
//  LocationViewModel.swift
//  GPSMandatory
//
//  Created by Marco Alonso Rodriguez on 08/11/22.
//

import Foundation
import CoreLocation
import Combine

final class LocationViewModel:  NSObject, CLLocationManagerDelegate {
    
    var permisoOtorgado = PassthroughSubject<Bool, Error>()
    var deniedLocationAccessPublisher = PassthroughSubject<Void, Never>()
    var coordinatesPublisher = PassthroughSubject<CLLocationCoordinate2D, Error>()
    
    override init() {
        super.init()
    }
    
    static let shared = LocationViewModel()
    
    private lazy var locationManager: CLLocationManager = {
            let manager = CLLocationManager()
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.delegate = self
            return manager
        }()
    
    func requestLocationUpdates() {
            switch locationManager.authorizationStatus {
            
            case .denied:
                permisoOtorgado.send(false)
                
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            case .authorizedWhenInUse, .authorizedAlways:
                locationManager.startUpdatingLocation()
                
            default:
                deniedLocationAccessPublisher.send()
            }
        }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
                
            case .authorizedWhenInUse, .authorizedAlways:
                manager.startUpdatingLocation()
                
            default:
                manager.stopUpdatingLocation()
                deniedLocationAccessPublisher.send()
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            coordinatesPublisher.send(location.coordinate)
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            coordinatesPublisher.send(completion: .failure(error))
        }
}
 
