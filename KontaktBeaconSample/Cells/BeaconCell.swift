//
//  BeaconCell.swift
//  KontaktBeaconSample
//
//  Created by Anthony Arzola on 9/10/17.
//  Copyright © 2017 Anthony Arzola. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class BeaconCell: UITableViewCell {
    
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var proximityLabel: UILabel!
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var beaconImageView: UIImageView!
    
    func setProperties(withBeacon beacon: Beacon) {
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "MMM dd, yyyy @ hh:mm:ss"
        
        self.informationLabel.text = "Beacon: \(beacon.Major).\(beacon.Minor)"
        self.proximityLabel.text = "Proximity: \(Beacon.proximityDescription((beacon.Proximity))) \(beacon.Proximity == CLProximity.unknown ? beacon.unknownStatus() : "") "
        self.lastSeenLabel.text = dateTimeFormatter.string(from: (beacon.LastUpdate))
        
        self.backgroundColor = beacon.Proximity == CLProximity.unknown ? UIColor.lightGray : UIColor.gray;
    }
    
}
