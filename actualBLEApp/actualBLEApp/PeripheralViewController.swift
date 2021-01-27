//
//  PeripheralViewController.swift
//  actualBLEApp
//
//  Created by Carlos Huang on 2020-05-04.
//  Copyright © 2020 Carlos Huang. All rights reserved.
//

import UIKit
import CoreBluetooth
import os

//TODO: reformat this whole file into several smaller ones to made it more modular and more readable. Whoever did this at apple was lowkey lazy, no offence.

//Holy shit some parts of this is pretty jank. Actually gotta refactor most of this

class PeripheralViewController: UIViewController {
    @IBOutlet weak var volumeLabel: UILabel!
    
    let serviceUUID = CBUUID(string: "E20A39F4-73F5-4BC4-A12F-17D1AD07A961")
    let characteristicUUID = CBUUID(string: "08590F7E-DB05-467E-8757-72F6FAEB13D4")

    var some_data: String = "0.5"
    
    var dataToSend = Data()
    
    var peripheralManager: CBPeripheralManager!
    
    var transferCharacteristic: CBMutableCharacteristic?
    var centralConnection : CBCentral?
    var sendDataIndex: Int = 0
    
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        peripheralManager.stopAdvertising()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
//        if peripheralManager.isAdvertising{
//            peripheralManager.stopAdvertising()
//
//        }
//        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [serviceUUID]])
//
        volumeLabel.text = String(sender.value)
//        some_data = String(sender.value)
        dataToSend = String(sender.value).data(using: .utf8)!
    }
    
    
    
    
    //MARK: Helper funcs
    
    static var sendingEOM = false
    
    
    //MARK: Sending Data to Central
    private func sendData(){
        guard let currTransferCharacteristic = transferCharacteristic else{
            os_log("no transfer characteristics available")
            return
        }
        
        if PeripheralViewController.sendingEOM{
            //sending it
            let didSend  = peripheralManager.updateValue("EOM".data(using: .utf8)!, for: currTransferCharacteristic, onSubscribedCentrals: nil)
            
            if didSend{
                //Mark it as sent
                PeripheralViewController.sendingEOM = false
                os_log("Sent the EOM")
                
            }
            return
            //Exited and waiting for peripheralManagerIsReadyToUpdateSubs to call sendData again
        }
        
        if sendDataIndex >= dataToSend.count{
            //Finished sending all the data
            return
        }
        
        var didSend = true
        
        while didSend{
            
            
            //Could make next three lines into one if want to...
            //Literally just finds the max amount of data possible to send
            var amountToSend = dataToSend.count - sendDataIndex
            if let mtu = centralConnection?.maximumUpdateValueLength{
                amountToSend = min(amountToSend,mtu)
            }
            
            let chunk = dataToSend.subdata(in: sendDataIndex..<(sendDataIndex + amountToSend))
            
            didSend = peripheralManager.updateValue(chunk, for: currTransferCharacteristic, onSubscribedCentrals: nil)
            
            //Didnt send, drop out and wait for callback again. Redo process
            if !didSend{
                return
            }
            
            let stringFromData = String(data:chunk,encoding: .utf8)
            os_log("Sent %d bytes: %s", chunk.count,String(describing: stringFromData))
            
            //Update index value bc it got sent.
            sendDataIndex += amountToSend
            
            //Check if its last one.
            if sendDataIndex >= dataToSend.count{
                //Sending EOM
                
                
                //Insurance in case EOM fails to send.
                
                PeripheralViewController.sendingEOM = true
                
                let eomSent = peripheralManager.updateValue("EOM".data(using: .utf8)!, for: currTransferCharacteristic, onSubscribedCentrals: nil)
                
                if eomSent{
                    PeripheralViewController.sendingEOM = false
                    os_log("Sent the EOM")
                }
                return
                
            }
            
        }
        
        
        
    }
    
    //MARK: Building service
    private func setupPeripheral(){
        
        
        //The one and only characteristic
        let transferCharacteristic = CBMutableCharacteristic(type: characteristicUUID, properties: [.notify,.writeWithoutResponse], value: nil, permissions: [.readable,.writeable])
        
        //The one and only service
        let transferService = CBMutableService(type: serviceUUID, primary: true)
        
        //Adding the service
        peripheralManager.add(transferService)
        
        
        self.transferCharacteristic = transferCharacteristic
        
        
        
    }


    
    

}

extension PeripheralViewController: CBPeripheralManagerDelegate{
    internal func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        //MARK: Literally copying this from apple bc it's not worth doing myself
        
            
//            let curr_state = peripheral.state == .poweredOn
            
            switch peripheral.state {
            case .poweredOn:
                // ... so start working with the peripheral
                os_log("CBManager is powered on")
                setupPeripheral()
            case .poweredOff:
                os_log("CBManager is not powered on")
                // In a real app, you'd deal with all the states accordingly
                return
            case .resetting:
                os_log("CBManager is resetting")
                // In a real app, you'd deal with all the states accordingly
                return
            case .unauthorized:
                os_log("Unauthorized to use bluetooth")
            case .unknown:
                os_log("CBManager state is unknown")
                // In a real app, you'd deal with all the states accordingly
                return
            case .unsupported:
                os_log("Bluetooth is not supported on this device")
                // In a real app, you'd deal with all the states accordingly
                return
            @unknown default:
                os_log("A previously unknown peripheral manager state occurred")
                // In a real app, you'd deal with yet unknown cases that might occur in the future
                return
            }
        
    }
    
    
    //Send data after central subscribes to characteristic

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        os_log("Central subscribed to characteristic")
        
        dataToSend = some_data.data(using: .utf8)!
        
        sendDataIndex = 0
        
        centralConnection = central
        
        sendData()
    }
    
    //Unsubbing
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        os_log("The central has unsubbed from characteristic")
        centralConnection = nil
    }
    
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        sendData()
    }
    
    //Might implement write to characteristics?? don't need it though...
    
    
}
