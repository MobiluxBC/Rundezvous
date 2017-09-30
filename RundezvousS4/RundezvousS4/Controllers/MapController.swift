//
//  MainController.swift
//  Rundezvous
//
//  Created by Niko Arellano on 2017-09-21.
//  Copyright © 2017 MobiluxBC. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var myMap: MKMapView!
    
    private var locationMAnager = CLLocationManager()
    private var userLocation : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeLocationManager()
        // Do any additional setup after loading the view.
    }
    
    private func initializeLocationManager() {
        locationMAnager.delegate = self
        locationMAnager.desiredAccuracy = kCLLocationAccuracyBest
        locationMAnager.requestWhenInUseAuthorization()
        locationMAnager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // if we have the coordinates from the manager
        if let location = locationMAnager.location?.coordinate {
            
            userLocation = CLLocationCoordinate2D(latitude : location.latitude, longitude : location.longitude)
            
            let region = MKCoordinateRegion(center : userLocation!,
                                            span : MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta : 0.01 ))
            
            myMap.setRegion(region , animated : true)
            myMap.removeAnnotations(myMap.annotations)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation!
            myMap.addAnnotation(annotation)
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOut(_ sender: Any) {
        if AuthProvider.Instance.logOut() {
            dismiss(animated: true, completion: nil)
        } else {
            // problem w/ signing out
        }
    }
    
}

