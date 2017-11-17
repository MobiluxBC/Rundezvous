//
//  Square.swift
//  RundezvousS4
//
//  Created by Niko Arellano on 2017-11-16.
//  Copyright © 2017 Mobilux. All rights reserved.
//

import Foundation
import MapKit

class Square {
    var topLeftCoords     : CLLocationCoordinate2D?
    var bottomRightCoords : CLLocationCoordinate2D?
    var center            : CLLocationCoordinate2D?
    var words             : String?
    var visited           : Bool?
    var color             : String?
    
    convenience init(latMin : Double, longMin : Double, latMax : Double, longMax : Double) {
        
        self.init(topLeftCoord : CLLocationCoordinate2D(latitude: latMin, longitude: longMin), bottomRightCoord : CLLocationCoordinate2D(latitude: latMax, longitude: longMax))
    }
    
    init(topLeftCoord : CLLocationCoordinate2D, bottomRightCoord : CLLocationCoordinate2D) {
        self.visited            = false
        self.topLeftCoords      = topLeftCoord
        self.bottomRightCoords  = bottomRightCoord
        
        let centerLat  = ((topLeftCoords!.latitude - bottomRightCoords!.latitude) / 2)   + bottomRightCoords!.latitude
        let centerLong = ((bottomRightCoords!.longitude - topLeftCoords!.longitude) / 2) + topLeftCoords!.longitude
        
        self.center             = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLong)
    }
}
