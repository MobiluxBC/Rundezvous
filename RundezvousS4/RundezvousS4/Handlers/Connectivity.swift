//
//  Connectivity.swift
//  Collab
//
//  Created by Niko Arellano on 2017-11-21.
//  Copyright © 2017 Mobilux. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
