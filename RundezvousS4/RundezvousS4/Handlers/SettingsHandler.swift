//
//  SettingsHandler.swift
//  RundezvousS4
//
//  Created by Niko Arellano on 2017-11-17.
//  Copyright © 2017 Mobilux. All rights reserved.
//

import Foundation


class SettingsHandler {
    
    static let _instance = SettingsHandler()
    
    static var Instance : SettingsHandler {
        return _instance;
    }
    
    var gridInMeters    : Double = 5
    var rundePointsCount: Int    = 10
    
}
