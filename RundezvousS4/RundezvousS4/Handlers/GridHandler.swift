//
//  GridHandler.swift
//  RundezvousS4
//
//  Created by Niko Arellano on 2017-11-16.
//  Copyright © 2017 Mobilux. All rights reserved.
//


import CoreLocation
import Foundation
import SwiftyJSON
import MapKit

typealias Handler = (_ points : [Square]) -> Void

class GridHandler {
    
    var locManager = CLLocationManager()
    
    //instantiated in
    var lines : JSON?
    
    static let _instance = GridHandler()
    
    static var Instance : GridHandler {
        return _instance;
    }
    
    
    // Add a random point
    public func getPoints(handler : Handler?) -> Void {
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse)
        {
            print("getting triggered")
            
            var lat, long : Double
            // Rounding Lat/Long to 6 decimal places
            //lat = Double(round(1000000*(locManager.location?.coordinate.latitude ?? -1))/1000000)
            //long = Double(round(1000000*(locManager.location?.coordinate.longitude ?? -1))/1000000)
            lat = Double(locManager.location?.coordinate.latitude ?? -1)
            long = Double(locManager.location?.coordinate.longitude ?? -1)
            print("Latitude---> \(lat) ")
            print("Longitude--> \(long) ")
            
            
            // Variable for the grid nw=NorthWest se=SouthEast
            // 0.000027 = about 3m
            let nwLat = lat + (30*0.00003)
            let nwLong = long - (30*0.00003)
            let seLat = lat - (30*0.00003)
            let seLong = long + (30*0.00003)
            
            //Sample URL for the api call: https://api.what3words.com/v2/grid?bbox=52.208867,0.117540,52.207988,0.116126&format=json&key=BJEVPZLZ
            // Subbing in the calucalted bounding
            let url = URL(string: "https://api.what3words.com/v2/grid?bbox=\(nwLat),\(nwLong),\(seLat),\(seLong)&format=json&key=BJEVPZLZ")
            
            
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                
                if let data = data {
                    // Convert the data to JSON
                    let json = JSON(data: data)
                    
                    GridHandler.Instance.lines = json["lines"]
                    GridHandler.Instance.lines!["error"] = JSON.null
                    let lineObject = self.lines!
                    
                    var lats = Set<Double>()
                    var longs = Set<Double>();
                    var points = [[CLLocationCoordinate2D]]();
                    for i in 0...lineObject.count-1 {
                        lats.insert(lineObject[i]["start"]["lat"].double!)
                        lats.insert(lineObject[i]["end"]["lat"].double!)
                        longs.insert(lineObject[i]["start"]["lng"].double!)
                        longs.insert(lineObject[i]["end"]["lng"].double!)
                    }
                    
                    // Sorting so that first element in 'points' is top-left, last element is bottom-right.
                    // In other words, 'points' goes left to right, top to bottom.
                    let sortedLats  = lats.sorted(by: >)
                    let sortedLongs = longs.sorted()
                    
                    for latitude in sortedLats {
                        var currentRow = [CLLocationCoordinate2D]()
                        
                        for longitude in sortedLongs {
                            let point = CLLocationCoordinate2D(latitude : latitude, longitude : longitude);
                            currentRow.append(point)
                        }
                        
                        points.append(currentRow)
                    }
                    
                    var randomSquares = [Square]()
                    var i = 0
                    
                    print("The count of lats:  \(sortedLats.count)")
                    print("The count of longs: \(sortedLongs.count)")
                    
                    while i < 10 {
                        let randomRow    = Int(arc4random_uniform(UInt32(sortedLats.count  - 1)))
                        let randomColumn = Int(arc4random_uniform(UInt32(sortedLongs.count - 1)))
                        
                        print("Random row: \(randomRow)")
                        print("Random column: \(randomColumn)")
                        
                        if ((randomRow + 1) > sortedLats.count || (randomColumn + 1) > sortedLongs.count) {
                            i -= 1
                        } else {
                            
                            let square : Square = Square(
                                topLeftCoord     : points[randomRow][randomColumn],
                                bottomRightCoord : points[randomRow + 1][randomColumn + 1])
                            randomSquares.append(square)
                            i += 1
                            
                        }
                    }
                    
                    handler?(randomSquares)
                    
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            task.resume()
            // Infinitely run the main loop to wait for our request.
            // Only necessary if you are testing in the command line.
            //RunLoop.main.run()
        }
    }
    
    
}



