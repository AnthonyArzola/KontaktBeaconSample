//
//  ViewController.swift
//  KontaktBeaconSample
//
//  Created by Anthony Arzola on 9/9/17.
//  Copyright © 2017 Anthony Arzola. All rights reserved.
//

import UIKit

import KontaktSDK
import Whisper

class BeaconTableViewController: UITableViewController, KTKBeaconManagerDelegate {

    // MARK: - Data Members
    
    var BeaconManager: KTKBeaconManager!
    var ProximityUuid: UUID!
    var BeaconRegion: KTKBeaconRegion!
    var BeaconList: [NSNumber : Beacon]!
    var RefreshTimer: Timer!
    
    // MARK: - Lifecyle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialize Beacon manager
        BeaconManager = KTKBeaconManager(delegate: self)
        
        // Create Beacon region (Default UUID, change to match your existing UUID)
        ProximityUuid = UUID(uuidString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")
        BeaconRegion = KTKBeaconRegion(proximityUUID: ProximityUuid!, identifier: "Region1")
        
        // List of beacons
        BeaconList = [NSNumber : Beacon]()
        
        // Whisper config
        Whisper.Config.modifyInset = false;
        
        // Timer used to update TableView
        RefreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { (Timer) in
            self.tableView.reloadData()
        })
        
        self.tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switch KTKBeaconManager.locationAuthorizationStatus() {
            
        case .notDetermined, .authorizedWhenInUse:
            // Value not set, request access
            BeaconManager.requestLocationWhenInUseAuthorization()
            
        case .denied, .restricted:
            //TODO: No access to Location Services, display message to user
            print("Access Denied/Restricted")
            
        case .authorizedAlways:
            print("Always Authorized")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        BeaconManager.stopMonitoringForAllRegions()
        
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataSource protocol methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        var sectionCount = 0
        
        if BeaconList.count > 0 {
            self.tableView.backgroundView = nil
            sectionCount = 1
            
        } else {
            let noBeaconLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
            noBeaconLabel.text = "No Beacons detected"
            noBeaconLabel.textColor = UIColor(red: 22.0/255.0, green: 106.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            noBeaconLabel.textAlignment = NSTextAlignment.center
            noBeaconLabel.font = UIFont.systemFont(ofSize: 21, weight: UIFontWeightThin)
            self.tableView.backgroundView = noBeaconLabel
        }
        
        return sectionCount
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BeaconList.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt IndexPath: IndexPath) -> UITableViewCell {
        
        if (BeaconList.count == 0) {
            let cell = UITableViewCell.init()
            cell.textLabel?.text = "No Beacons detected"
            
            return cell
        }
        else {
            let beaconArray = BeaconList.map{$0.value}
            let sortedArray = beaconArray.sorted { $0.Minor.intValue < $1.Minor.intValue }
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "beaconCell", for: IndexPath) as! BeaconCell

            if IndexPath.row < sortedArray.count {
                let beacon = sortedArray[IndexPath.row]
                cell.setProperties(withBeacon: beacon)
            }
            return cell
        }
    }

    // MARK: - KTKBeaconManagerDelegate protocol methods
    
    func beaconManager(_ manager: KTKBeaconManager, didStartMonitoringFor region: KTKBeaconRegion) {
        // Monitoring for a particular region was successfully initiated, start ranging
        print("Started monitoring region: \(region.identifier)")
        manager.startRangingBeacons(in: region)
        
    }
    
    func beaconManager(_ manager: KTKBeaconManager, monitoringDidFailFor region: KTKBeaconRegion?, withError error: Error?) {
        // Failed to start monitoring the region
        if let theRegion = region {
            print("Failed to start monitoring region: \(theRegion.identifier)")
        }
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didEnter region: KTKBeaconRegion) {
        // Decide what to do when a user enters a range of your region; usually used
        // for triggering a local notification and/or starting a beacon ranging
        print("Entered region: \(region.identifier)")
        manager.startRangingBeacons(in: region)
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didExitRegion region: KTKBeaconRegion) {
        // Decide what to do when a user exits a range of your region; usually used
        // for triggering a local notification and stoping a beacon ranging
        print("Existing region: \(region.identifier)")
        manager.stopRangingBeacons(in: region)
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didChangeLocationAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            // When status changes to CLAuthorizationStatus.authorizedWhenInUse, start region monitoring
            manager.startMonitoring(for: BeaconRegion)
        }
    }
    
    func beaconManager(_ manager: KTKBeaconManager, didRangeBeacons beacons: [CLBeacon], in region: KTKBeaconRegion) {
        for beacon in beacons {
            
            if let existingBeacon = BeaconList[beacon.minor] {
                // Update properties that continuously change
                existingBeacon.Proximity = beacon.proximity
                existingBeacon.LastUpdate = Date()
                
                // Update unreachable properties
                print("Beacon with minor \(existingBeacon.Minor) " +
                    "has proximity \(Beacon.proximityDescription(beacon.proximity)) \(existingBeacon.Proximity == CLProximity.unknown ? existingBeacon.unknownStatus() : "")")
                
                if beacon.proximity == CLProximity.unknown {
                    
                    let currentCount = existingBeacon.UnknownCount + 1
                    existingBeacon.UnknownCount = currentCount
                    
                    // If threshold is reached, remove it
                    if existingBeacon.Unreachable {
                        print(" * Removing beacon with minor \(beacon.minor)")
                        BeaconList[beacon.minor] = nil
                        showStatus(message: "Removing beacon...", color: .red)
                    }
                }
                else
                {
                    // Reset
                    existingBeacon.UnknownCount = 0;
                }
                
            } else {
                // Add new beacon
                if beacon.proximity != CLProximity.unknown {
                
                    print(" * Adding beacon with minor \(beacon.minor)")
                    BeaconList[beacon.minor] = Beacon(withBeacon: beacon, region: region.description)
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Helper methods
    
    func showStatus(message: String, color: UIColor) {
        
        let message = Message(title: message, backgroundColor: color)
        
        // Show and hide a message after delay
        Whisper.show(whisper: message, to: self.navigationController!, action: .show)
        
        // Present a permanent message
        Whisper.show(whisper: message, to: self.navigationController!, action: .present)
        
        // Hide a message
        Whisper.hide(whisperFrom: self.navigationController!)
    }
    
}

