//
//  MainController.swift
//  Rundezvous
//
//  Created by Niko Arellano on 2017-09-21.
//  Copyright © 2017 MobiluxBC. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON

class MapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    //DEBUG OPTION CHANGE WHEN PUBLISHING.
    var DEBUG_MODE : Bool = false
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet var mapView: MKMapView!
    
    
    enum PopUpState {
        case OPEN
        case CLOSED
    }
    var time = 60;
    var timerObject = Timer();
    var score = 0;
    
    
    @IBOutlet weak var timer: UILabel!
    private var locationManager = CLLocationManager()
    private var userLocation : CLLocationCoordinate2D?
    private var isFirstLocationUpdate : Bool = true
    private var polylines : [MKPolyline] = [MKPolyline]()
    var overlays : [MKOverlay]!
    let dgHavePoints : DispatchGroup = DispatchGroup()
    let dgHaveDrawnPolyLines : DispatchGroup = DispatchGroup()
    var popUpState : PopUpState = PopUpState.CLOSED
    var squares : [Square]?
    
    
    @objc func action(){
        let dgTimerUpdate = DispatchGroup()
        dgTimerUpdate.enter()
        time -= 1
        dgTimerUpdate.leave()
        dgTimerUpdate.notify(queue: .main, execute: {
            self.timer.text = String(self.time);
            if(self.time == 0){
                self.performSegue(withIdentifier: "outOfTimeSegue", sender: nil)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer.text = String(time);
        initializeLocationManager()
        mapView.delegate = self
        DEBUG_MODE = SettingsHandler.Instance.DEBUG_MODE

        // Do any additional setup after loading the view.
        
        
        
        if DEBUG_MODE {
            let mapLTGRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMapPress))
            //Where is the UIElem we're listening for taps? This class.
            //Where is the function to handle the action defined? In the class of the delegate/order taker
            mapLTGRecognizer.delegate = self //The view is responsible to provide the function. It can modify the necessary data to carry it out
            mapView.addGestureRecognizer(mapLTGRecognizer)
        }
    }
    
    //For Debug only
    @objc func handleMapPress(gestureRecognizer: UILongPressGestureRecognizer) {
        print("In handlemap press")
        self.becomeFirstResponder()
        let location = gestureRecognizer.location(in: mapView)
        let coordinate : CLLocationCoordinate2D = mapView.convert(location,toCoordinateFrom: mapView)
        userLocation = coordinate
        popUpIfInSquare()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if (segue.identifier == "outOfTimeSegue") {
            let secondViewController = segue.destination as! ScoreViewController
            secondViewController.finalScore = String(score);
        }
    }
    
    private func dropPoints() {
        GridHandler.Instance.getPoints { (squares) in
            self.squares = squares
            for square in squares {
                self.dropPinAtCoordinate(c: square.center!)
            }
            self.dgHavePoints.leave()
        }
    }
    
    private func initializeLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.activityType = CLActivityType.fitness
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func dismissPopUp(_ : UIAlertAction) -> Void{
        print("in dismiss Popup")
        scoreLabel.text = String(score)
        popUpState = PopUpState.CLOSED
    }
    
    func popUp(message: String) -> Void {
        score += 1; 
        print("In popup")
        var alertText : String = "\n\n\n\n\n\n\n\n\n\n\n\n"
        if(!message.isEmpty){
            alertText += message
        }
        let alertMessage = UIAlertController(title: "My Title", message: alertText, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: self.dismissPopUp)
        alertMessage.addAction(action)
        self.present(alertMessage, animated: true, completion: nil)
        let xPosition = alertMessage.view.frame.origin.x + 80
        let rectImg = #imageLiteral(resourceName: "goldbag")
        let rect : CGRect = CGRect(x: xPosition, y: 100, width: 100, height: 100)
        //rectImg.draw(in: rect)
        let imageView = UIImageView(frame: rect)
        imageView.image = rectImg
        alertMessage.view.addSubview(imageView)
    }
    
    func popUpIfInSquare(){
        if(!self.isFirstLocationUpdate && squares != nil){
            if(userLocation != nil && isUserInSquares(location: userLocation!)){
                if(popUpState == .CLOSED){
                    popUp(message: "You found a bag of gold")
                    //TODO: Increment score
                    
                    
                }
            }
        }
    }
    
    func locationInit(){
        if let location = locationManager.location?.coordinate {
            self.userLocation = location
            let region = MKCoordinateRegion(center : self.userLocation!,
            span : MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta : 0.0001 ))
        
            mapView.setRegion(region , animated : true)
            dgHavePoints.enter()
            dgHaveDrawnPolyLines.enter()
            self.dropPoints()
            dgHavePoints.notify(queue: .main, execute: {
                self.drawGridPolyLines()
            })
            dgHaveDrawnPolyLines.notify(queue: .main, execute: {
                self.timerObject = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MapController.action), userInfo: nil, repeats: true)
            })
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if self.isFirstLocationUpdate {
            // Drop the points once the user location has been set
            // only if this is the first location update
            locationInit()
            self.isFirstLocationUpdate = false
        }
        // If you're using the emulator, disregard the locationmanger. Click to set location
        if DEBUG_MODE {
                //location Updates will be manually updated
                locationManager.stopUpdatingLocation()
                popUpIfInSquare()
        //use when published
        } else {
            // if we have the coordinates from the manager
            if let location = locationManager.location?.coordinate {
                
                userLocation = CLLocationCoordinate2D(latitude : location.latitude, longitude : location.longitude)
                popUpIfInSquare()
            }
        }
    }
    
    //lattitude increases north, longitude increases west
    func isUserInSquares(location: CLLocationCoordinate2D) -> Bool {
        for square in squares! {
            if(!square.visited!){
                if(Double(userLocation!.latitude) < Double(square.topLeftCoords!.latitude) && Double(square.bottomRightCoords!.latitude) <
                    Double(userLocation!.latitude) &&
                        Double(square.topLeftCoords!.longitude) < Double(userLocation!.longitude) && Double(userLocation!.longitude) <
                                Double(square.bottomRightCoords!.longitude)){
                    //set square as visited
                    square.visited = true
                    return true
                }
            }
        }
        return false
    }
    
    func dropPinAtCoordinate(c : CLLocationCoordinate2D) {
        print("\(c.latitude) \(c.longitude)")
        
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(c.latitude, c.longitude);
        
        let myPinAnnotation : MKPinAnnotationView = MKPinAnnotationView()
        myPinAnnotation.annotation = myAnnotation
        myPinAnnotation.backgroundColor = UIColor.black
        
        mapView.addAnnotation(myAnnotation)
    }
    
    func drawGridPolyLines() {
        let lines = GridHandler.Instance.lines ?? JSON(["error": "no lines"])
        //let polyline = MKPolyline(coordinates: &points, count: 2)
        if(lines["error"] == JSON.null ){
            for i in 0...lines.count-1 {
                let start = CLLocationCoordinate2D(latitude: lines[i]["start"]["lat"].double!, longitude: lines[i]["start"]["lng"].double!)
                let end = CLLocationCoordinate2D(latitude: lines[i]["end"]["lat"].double!, longitude: lines[i]["end"]["lng"].double!)
                let line = [CLLocationCoordinate2D](arrayLiteral: start, end)
                let polyline = MKPolyline(coordinates: line, count: 2)
                self.mapView.add(polyline, level: .aboveRoads)
            }
            /*
            for item : MKOverlay in mapView.overlays {
                print(item.debugDescription ?? "overlay is null")
            }
             */
            self.dgHaveDrawnPolyLines.leave()
        }else {
            print(lines["error"])
            self.dgHaveDrawnPolyLines.leave()
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKPolyline.self) {
            // draw the track
            print("calling overlay renderer")
            let polyLine = overlay
            let polyLineRenderer = MKPolylineRenderer(overlay: polyLine)
            polyLineRenderer.strokeColor = UIColor.blue
            polyLineRenderer.lineWidth = 2.0
            
            return polyLineRenderer
        }
        return MKPolylineRenderer()
    }
    
    func getTopLeftCorner(_ map: MKMapView) -> CLLocationCoordinate2D {
        return map.convert(CGPoint(x: 0, y:0), toCoordinateFrom: map)
    }
    
    func getTopRightCorner(_ map: MKMapView) -> CLLocationCoordinate2D {
        return map.convert(CGPoint(x: map.frame.width, y:0), toCoordinateFrom: map)
    }
    
    func getBottomRightCorner(_ map: MKMapView) -> CLLocationCoordinate2D {
        return map.convert(CGPoint(x: map.frame.width, y:0), toCoordinateFrom: map)
    }
    
    func getBottomLeftCorner(_ map: MKMapView) -> CLLocationCoordinate2D {
        return map.convert(CGPoint(x: 0, y:map.frame.height), toCoordinateFrom: map)
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

