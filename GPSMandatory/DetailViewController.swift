//
//  DetailViewController.swift
//  GPSMandatory
//
//  Created by Marco Alonso Rodriguez on 04/11/22.
//

import UIKit
import Combine

class DetailViewController: UIViewController {
    
    var anyCancellable: [AnyCancellable] = []
    let vc = ViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        subscriptions()
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
                
            }
        }.store(in: &anyCancellable)

    }

}
