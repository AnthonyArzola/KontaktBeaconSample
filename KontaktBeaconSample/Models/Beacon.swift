//
//  Beacon.swift
//  KontaktBeaconSample
//
//  Created by Anthony Arzola on 9/10/17.
//  Copyright © 2017 Anthony Arzola. All rights reserved.
//

import Foundation
import CoreLocation

class Beacon {
    
    let RemoveThreshold = 7
    
    // MARK: - Properties
    var Region: String
    var Major: NSNumber
    var Minor: NSNumber
    var Proximity: CLProximity
    var LastUpdate: Date
    var UnknownCount: Int
    var Unreachable:Bool {
        get {
            return UnknownCount >= RemoveThreshold
        }
    }
    
    // MARK: - Constructors
    
    init() {
        self.Region = ""
        self.Major = 0;
        self.Minor = 0;
        self.Proximity = CLProximity.unknown
        self.LastUpdate = Date()
        self.UnknownCount = 0
    }
    
    init(withBeacon beacon: CLBeacon, region: String) {
        self.Region = region
        self.Major = beacon.major
        self.Minor = beacon.minor
        self.Proximity = beacon.proximity
        self.LastUpdate = Date()
        self.UnknownCount = 0
    }
    
    // MARK: - Methods
    func description() -> String {
        return "\(Major).\(Minor) in \(Region) with \(Beacon.proximityDescription(Proximity)) @ \(LastUpdate)"
    }
    
    func unknownStatus() -> String {
        return "Received \(UnknownCount)/\(RemoveThreshold)"
    }
    
    static func proximityDescription(_ proximity: CLProximity) -> String {
        switch proximity {
            
        case .unknown:
            return "Unknown"
            
        case .immediate:
            return "Immediate"
            
        case .near:
            return "Near"
            
        case .far:
            return "Far"
            
        }
    }
    
}
