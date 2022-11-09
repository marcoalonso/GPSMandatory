//
//  ViewController.swift
//  GPSMandatory
//
//  Created by Marco Alonso Rodriguez on 04/11/22.
//

import UIKit
import CoreLocation
import Combine

class ViewController: UIViewController, ObservableObject {

    var locationManager = CLLocationManager()
    var anyCancellable: [AnyCancellable] = []
    
    var permisoDenegado = PassthroughSubject<Bool, Error>()
    var permisoOtorgado = PassthroughSubject<Bool, Error>()
    
    var coordinatesPublisher = PassthroughSubject<CLLocationCoordinate2D, Error>()
    var deniedLocationAccessPublisher = PassthroughSubject<Void, Never>()
    static let shared = ViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestLocation()
        locationManager.requestWhenInUseAuthorization()
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        subscriptions()
    }
    
    @IBAction func goDetailView(_ sender: UIButton) {
        
    }
    
    func subscriptions(){
        permisoDenegado.sink { _ in
            
        } receiveValue: { [weak self] permiso in
            //mandar llamar a la vista
            if permiso {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "AlertaViewController") as? AlertaViewController {
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
                }
            }
        }.store(in: &anyCancellable)
        
        

    }
    
    
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Debug: error al obtner ubicacion \(error.localizedDescription)")
        coordinatesPublisher.send(completion: .failure(error))
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          if let ubicacion = locations.first{
              locationManager.stopUpdatingLocation()
              coordinatesPublisher.send(ubicacion.coordinate)
          }
      }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
         switch status {
         case .notDetermined:
             print("No determinado")
         case .restricted:
             print("restricted")
         case .denied:
             print("Debug: denegado")
             self.permisoDenegado.send(true)
         case .authorizedAlways:
             locationManager.startUpdatingLocation()
             print("Debug: denauthorizedAlwaysegado")
             self.permisoOtorgado.send(true)
         case .authorizedWhenInUse:
             locationManager.startUpdatingLocation()
             print("Debug: denauthorauthorizedWhenInUseizedAlwaysegado")
             self.permisoOtorgado.send(true)
         @unknown default:
             print("Default")
         }
     }
}
