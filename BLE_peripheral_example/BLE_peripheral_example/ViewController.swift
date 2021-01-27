//
//  ViewController.swift
//  BLE_peripheral_example
//
//  Created by Carlos Huang on 2020-05-04.
//  Copyright © 2020 Carlos Huang. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController,CBPeripheralManagerDelegate {
    
    @IBOutlet weak var readValueLabel: UILabel!
    @IBOutlet weak var writeValueLabel: UILabel!
    
    private var peripheralManager: CBPeripheralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state{
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
                addServices()
            @unknown default:
                print("Unknown State")
            
        }
    }
    
    //MARK: helper funcs
    
    private var service: CBUUID!
    private let value = "AD34E"
    
    func addServices(){
        let valueData = value.data(using: .utf8)
        
        //CBMutatableCharacterisitic instance
        let myChar1 = CBMutableCharacteristic(type: CBUUID(nsuuid: UUID()), properties: [.notify,.write,.read], value: nil, permissions: [.readable,.writeable])
        
        let myChar2 = CBMutableCharacteristic(type: CBUUID(nsuuid: UUID()),properties: [.read],value: valueData,permissions: .readable)
        
        service = CBUUID(nsuuid: UUID())
        let myService = CBMutableService(type: service, primary: true)
        
        myService.characteristics = [myChar1,myChar2]
        
        peripheralManager.add(myService)
        
        startAdvertising()
        
        
        
    }
    
    func startAdvertising(){
        peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey: "BLEPeripheralApp",CBAdvertisementDataServiceUUIDsKey: [service]])
        
        print("start advertising")
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager,didReceiveWrite requests:[CBATTRequest]){
        print("writing Data")
        
        if let value = requests.first?.value{
            writeValueLabel.text = value.hexEncodingString()
            
        }
        
    }
    
    

}

extension Data{
    struct HexEncodingOptions: OptionSet{
        let rawValue: Int
        
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
        
    }
    
    func hexEncodingString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX": "%2hhx"
        //uppercase and lowercase I believe
        
        return map{String(format: format, $0)}.joined()
        
    }
    
    
}

