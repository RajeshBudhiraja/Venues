//
//  MapDelegate.swift
//  Venues
//
//  Created by Rajesh Budhiraja on 04/01/19.
//  Copyright © 2019 Rajesh Budhiraja. All rights reserved.
//

import Foundation
import MapKit

protocol MapDelegate {
    var initialLocation : CLLocation {get set}
    var destinationLocation : CLLocation {get set}
    var name:String {get set}
    func centerMap(location:CLLocation)
    
}
