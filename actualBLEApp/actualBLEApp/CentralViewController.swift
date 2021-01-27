//
//  CentralViewController.swift
//  actualBLEApp
//
//  Created by Carlos Huang on 2020-05-04.
//  Copyright © 2020 Carlos Huang. All rights reserved.
//

import UIKit
import CoreBluetooth
import os

class CentralViewController: UIViewController {

    @IBOutlet weak var volumeLabel: UILabel!
    
    
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    var transferCharacteristic: CBCharacteristic?
    var writeIterationsComplete = 0
    var connectionIterationsComplete = 0
    
    let defaultIterations = 5
    var data = Data()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        centralManager.stopScan()
        os_log("Stopped scanning")
        data.removeAll()
        
        super.viewWillDisappear(animated)
    }
    
    //MARK: Class helper funcs
    
    private func retrievePeripheral(){
        let connectedPeripherals: [CBPeripheral] = (centralManager.retrieveConnectedPeripherals(withServices: [TheTransferService.serviceUUID]))
        
        os_log("Found peripherals with matching service UUID: %@",connectedPeripherals)
        
        if let currConnectedPeripheral = connectedPeripherals.last{
            os_log("Connecting to peripheral %@", currConnectedPeripheral)
            self.discoveredPeripheral = currConnectedPeripheral
            centralManager.connect(currConnectedPeripheral,options: nil)
        }else{
            
            //Have not found the right peripheral, start scanning
            //Why set the options to true? Why have multiple discoveries of same peripheral, if the peripheral value updates over time anyways? Investigate, might change to false
            centralManager.scanForPeripherals(withServices: [TheTransferService.serviceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        }
        
    }
    //When stuff breaks or you need to disconnect
    private func cleanup(){
        guard let discoveredPeripheral = discoveredPeripheral, case .connected = discoveredPeripheral.state else{
            return
        }
        //Unsubs from notifying characteristics
        for service in (discoveredPeripheral.services ?? [] as [CBService]){
            for characteristic in (service.characteristics ?? [] as [CBCharacteristic]){
                if characteristic.uuid == TheTransferService.characteristicUUID && characteristic.isNotifying{
                    self.discoveredPeripheral?.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        //not subscribed but still connected, so disconnect
        
        centralManager.cancelPeripheralConnection(discoveredPeripheral)
        
    }
    

}
//MARK: Central Manager delegation implementation

extension CentralViewController: CBCentralManagerDelegate{
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // ... so start working with the peripheral
            os_log("CBManager is powered on")
            retrievePeripheral()
        case .poweredOff:
            os_log("CBManager is not powered on")
            // In a real app, you'd deal with all the states accordingly
            return
        case .resetting:
            os_log("CBManager is resetting")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unauthorized:
            // In a real app, you'd deal with all the states accordingly
            os_log("Unathorized usage of bluetooth")
            return
        case .unknown:
            os_log("CBManager state is unknown")
            // In a real app, you'd deal with all the states accordingly
            return
        case .unsupported:
            os_log("Bluetooth is not supported on this device")
            // In a real app, you'd deal with all the states accordingly
            return
        @unknown default:
            os_log("A previously unknown central manager state occurred")
            // In a real app, you'd deal with yet unknown cases that might occur in the future
            return
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //Make sure signal strong enough
        guard RSSI.intValue >= -70 else{
            os_log("Discovered peripheral not in range, value: %d", RSSI.intValue)
            return
        }
        os_log("Discovered %s at %d", peripheral.name!, RSSI.intValue)
        
        //Check if device has already been seen
        if discoveredPeripheral != peripheral{
            discoveredPeripheral = peripheral
            
            os_log("Connecting to the peripheral %@", peripheral)
            
            //Might change some of the options when running this in the background
            centralManager.connect(peripheral, options: nil)
            
        }
    
    }
    
    //Could not connect for some reason, just throw an error and figure it out later
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        os_log("Failed to connect to %@. %s", peripheral, String(describing: error))
        cleanup()
    }
    
    
    //Connected, now to get the characteristics
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        os_log("Peripheral connected")
        
        //We've found it boys
        centralManager.stopScan()
        os_log("Stopped scanning")
        
        connectionIterationsComplete += 1
        writeIterationsComplete = 0
        
        data.removeAll()
        
        peripheral.delegate = self
        
        peripheral.discoverServices([TheTransferService.serviceUUID])
    }
    
    //Handling disconnection
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        os_log("peripheral has been disconnected")
        discoveredPeripheral = nil
        
        if connectionIterationsComplete < defaultIterations{
            retrievePeripheral()
        }else{
            os_log("Connection iterations complete")
            
        }
        
        
        
    }
    
    
}


//MARK: Peripheral delegation implementation
extension CentralViewController: CBPeripheralDelegate{
    
    
    //Services invalidated for some reason
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        for service in invalidatedServices where service.uuid == TheTransferService.serviceUUID{
            os_log("Transfer service is invalidated, rediscovering services")
            //What??? not sure what this does...
            peripheral.discoverServices([TheTransferService.serviceUUID])
        }
    }
    
    
    //Transfer service discovered
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        //Handling the error
        if let error = error{
            os_log("Error discovering the services: %s",error.localizedDescription)
            cleanup()
            return
        }
        
        guard let peripheralServices = peripheral.services else{
            return
        }
        for service in peripheralServices{
            peripheral.discoverCharacteristics([TheTransferService.characteristicUUID], for: service)
        }
        
        
       
        
    
        
        
    }
    
    //Subscribing to transfer characteristic, which lets peripheral know we want its info
           
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let error = error{
            os_log("Error discovering characteristics: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        guard let serviceCharacteristics = service.characteristics else{
            return
        }
        
        for characteristic in serviceCharacteristics where characteristic.uuid == TheTransferService.characteristicUUID{
            
            transferCharacteristic = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
            
            
            //Now just wait for data to stream in
            
            
        }
    }
    
    
    //More data has arrived via notification on characteristic
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        //Make a function to handle these error shit
        if let error = error {
            os_log("Error discovering characteristics: %s", error.localizedDescription)
            cleanup()
            return
        }
        
        guard let characteristicData = characteristic.value, let stringFromData = String(data: characteristicData, encoding: .utf8) else{
            return
        }
        
        if stringFromData == "EOM"{
            
            DispatchQueue.main.async {
                self.volumeLabel.text = String(data: self.data, encoding: .utf8)
            }
        }else{
            data.append(characteristicData)
        }
        
    }
    
    
    //Whether we subscribed or unsubscribed
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            os_log("Error changing notification state: %s", error.localizedDescription)
            return
        }
        
        guard characteristic.uuid == TheTransferService.characteristicUUID else{
            return
        }
        
        if characteristic.isNotifying{
            os_log("Notification began on %@",characteristic)
            
        }else{
            os_log("Notification stopped on %@. Disconnecting",characteristic)
            cleanup()
            
        }
    }
}
