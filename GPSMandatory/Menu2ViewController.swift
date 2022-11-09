//
//  Menu2ViewController.swift
//  GPSMandatory
//
//  Created by Marco Alonso Rodriguez on 08/11/22.
//

import UIKit
import Combine

class Menu2ViewController: UIViewController {

    var locationVM = LocationViewModel.shared
    var tokens: Set<AnyCancellable> = []
    var coordenadas : (lat: Double, lon: Double) = (0,0)
    
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
    
    func observeCoordinateUpdates(){
        locationVM.coordinatesPublisher.receive(on: DispatchQueue.main)
            .sink { completion in
                print("Handle \(completion) for error and finished subscription.")
            } receiveValue: { coordenadas in
                self.coordenadas = (coordenadas.latitude, coordenadas.longitude)
                print("Debug: latitude \(coordenadas.latitude) longitude \(coordenadas.longitude)")
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
