//
//  AlertaViewController.swift
//  GPSMandatory
//
//  Created by Marco Alonso Rodriguez on 08/11/22.
//

import UIKit
import Combine

class AlertaViewController: UIViewController {
    
    var anyCancellable: [AnyCancellable] = []
    let vc = ViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscriptions()
    }
    
    
    func showAlert() {
        let alerta = UIAlertController(title: "ATENCION", message: "Necesitas activar tu GPS para continuar", preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Configuracion", style: .default) { _ in
            print("Debug: Abrir configuracion")
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
    }

    func subscriptions(){
        
        vc.coordinatesPublisher.sink { completion in
            print("Debug: \(completion)")
        } receiveValue: { coordinates in
            print("Debug: longitude \(coordinates.longitude)")
            print("Debug: latitude\(coordinates.latitude)")
        }.store(in: &anyCancellable)

        
        vc.permisoOtorgado.sink { completion in
            print("Debug: Handle \(completion) for error and finished subscription.")
        } receiveValue: { [weak self] otorgado in
            if otorgado {
                self?.dismiss(animated: true)
            } else {
                self?.showAlert()
            }
        }.store(in: &anyCancellable)
    }
    
    @IBAction func configButton(_ sender: UIButton) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
            })
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelarButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}
