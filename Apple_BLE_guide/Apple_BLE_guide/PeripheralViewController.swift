//
//  PeripheralViewController.swift
//  Apple_BLE_guide
//
//  Created by Carlos Huang on 2020-05-16.
//  Copyright © 2020 Carlos Huang. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralViewController: UIViewController, CBPeripheralManagerDelegate{
    
    var peripheralManager: CBPeripheralManager!
    var currTransferChar : CBMutableCharacteristic!

    
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        //Error handling if I want to implement later, lmao. Checks the state of bluetooth on the device.
        
        switch peripheral.state {
            case .unknown:
                print("Bluetooth Device is UNKNOWN")
            case .unsupported:
                print("Bluetooth Device is UNSUPPORTED")
            case .unauthorized:
                print("Bluetooth Device is UNAUTHORIZED")
            case .resetting:
                print("Bluetooth Device is RESETTING")
            case .poweredOff:
                print("Bluetooth Device is POWERED OFF")
            case .poweredOn:
                print("Bluetooth Device is POWERED ON")
                addService()
            @unknown default:
                print("Unknown State")
            
        }
    }
    
    private let value = 50.0
    
    func addService(){
        
        //Some stuff with bytes???? Turns the value into the type data.
        let valueData = withUnsafeBytes(of: value) {Data($0)}
        
        let myChar1 = CBMutableCharacteristic(type: CBUUID_numbers.characteristicUUID, properties: [.notify,.read,.write], value: nil, permissions: [.readable,.writeable])
        
    
        

        let myService = CBMutableService(type: CBUUID_numbers.serviceUUID, primary: true)
        
        myService.characteristics = [myChar1]
        currTransferChar = myChar1
        peripheralManager.add(myService)
        peripheralManager.updateValue(valueData, for: myChar1, onSubscribedCentrals: nil)
        startAdvertising()
        
        
    }
    
    func startAdvertising(){
        peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey:"BLE App"])
        
        print("Started advertising")
        
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    

  
}
