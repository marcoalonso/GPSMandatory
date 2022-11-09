//
//  MapViewController.swift
//  GPSMandatory
//
//  Created by Marco Alonso Rodriguez on 08/11/22.
//

import UIKit
import Combine
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapa: MKMapView!
    var locationVM = LocationViewModel.shared
    var subscriptions: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
              }.store(in: &subscriptions)

      }

}
