//
//  CentralViewController.swift
//  Apple_BLE_guide
//
//  Created by Carlos Huang on 2020-05-16.
//  Copyright © 2020 Carlos Huang. All rights reserved.
//

import UIKit
import CoreBluetooth

class CentralViewController: UIViewController, CBCentralManagerDelegate {
    
    var centralManager: CBCentralManager!
    var connectedPeripheralInstance : CBPeripheral!
    

    @IBOutlet weak var mainLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)

        // Do any additional setup after loading the view.
    }

    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
          case .unknown:
            print("central.state is .unknown")
          case .resetting:
            print("central.state is .resetting")
          case .unsupported:
            print("central.state is .unsupported")
          case .unauthorized:
            print("central.state is .unauthorized")
          case .poweredOff:
            print("central.state is .poweredOff")
          case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: [CBUUID_numbers.serviceUUID])
        @unknown default:
            print("Some weird error we haven't handled")
        }
    }
    
    func retrievePeripherals(){
        let connectedPeripherals: [CBPeripheral] = (centralManager.retrieveConnectedPeripherals(withServices: [CBUUID_numbers.serviceUUID]))
        
        print("Found connected Peripherals with transfer service: %@", connectedPeripherals)
        
        if let connectedPeripheral = connectedPeripherals.last {
            print("Connecting to peripheral %@", connectedPeripheral)
            self.connectedPeripheralInstance = connectedPeripheral
            centralManager.connect(connectedPeripheral, options: nil)
        } else {
            // We were not connected to our counterpart, so start scanning
            centralManager.scanForPeripherals(withServices: [CBUUID_numbers.serviceUUID],
                                               options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
        
    }

}
