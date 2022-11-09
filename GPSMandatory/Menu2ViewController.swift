//
//  Menu2ViewController.swift
//  GPSMandatory
//
//  Created by Marco Alonso Rodriguez on 08/11/22.
//

import UIKit
import Combine
import CoreLocation
import MapKit

class Menu2ViewController: UIViewController {

    var locationVM = LocationViewModel.shared
    var tokens: Set<AnyCancellable> = []
    var coordenadas : (lat: Double, lon: Double) = (0,0)
    lazy var geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        observeCoordinateUpdates()
        observeDeniedLocationAccess()
        locationVM.requestLocationUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationVM.requestLocationUpdates()
        checkPermissonGrantted()
    }
    
    func checkPermissonGrantted(){
        locationVM.permisoOtorgado.receive(on: DispatchQueue.main)
            .sink { completion in
                print("Debug: Error \(completion)")
            } receiveValue: { permiso in
                if !permiso {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "AlertaViewController") as? AlertaViewController {
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                }
            }.store(in: &tokens)

    }
    
    func reverseGeocoding(with location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemarks = placemarks, let placemark = placemarks.first {
                print("Debug: placemark \(placemark.name)")
                print("Debug: placemark \(placemark.thoroughfare)")
                print("Debug: placemark \(placemark.locality)")
                print("Debug: placemark \(placemark.postalCode)")
                print("Debug: placemark \(placemark.subThoroughfare)")
                print("Debug: placemark \(placemark.subLocality)")
                print("Debug: placemark \(placemark.subAdministrativeArea)")
                
                let alerta = UIAlertController(title: "DIRECCION", message: placemark.compactAddress, preferredStyle: .alert)
                let accionAceptar = UIAlertAction(title: "OK", style: .default) { _ in
                    //Do something
                }
                alerta.addAction(accionAceptar)
                self.present(alerta, animated: true)
            }
        }
    }
    
    func observeCoordinateUpdates(){
        locationVM.coordinatesPublisher.receive(on: DispatchQueue.main)
            .sink { completion in
                print("Handle \(completion) for error and finished subscription.")
            } receiveValue: { coordenadas in
                self.coordenadas = (coordenadas.latitude, coordenadas.longitude)
                print("Debug: latitude \(coordenadas.latitude) longitude \(coordenadas.longitude)")
                let location = CLLocation(latitude: coordenadas.latitude, longitude: coordenadas.longitude)
                self.reverseGeocoding(with: location)
            }.store(in: &tokens)
    }
  
    
    func observeDeniedLocationAccess() {
        locationVM.deniedLocationAccessPublisher
            .receive(on: DispatchQueue.main)
            .sink {
                print("Handle access denied event, possibly with an alert.")
                let alerta = UIAlertController(title: "ERROR", message: "access denied", preferredStyle: .alert)
                let accionAceptar = UIAlertAction(title: "OK", style: .default) { _ in
                    //Do something
                }
                alerta.addAction(accionAceptar)
                self.present(alerta, animated: true)
            }
            .store(in: &tokens)
    }


}

extension CLPlacemark {
    
    var compactAddress: String? {
        if let name = name {
            var result = name
            
            if let street = thoroughfare {
                result += ", \(street)"
            }
            
            if let city = locality {
                result += ", \(city)"
            }
            
            if let country = country {
                result += ", \(country)"
            }
            
            return result
        }
        
        return nil
    }
    
}
