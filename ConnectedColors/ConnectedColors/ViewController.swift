//
//  ViewController.swift
//  ConnectedColors
//
//  Created by Carlos Huang on 2020-04-16.
//  Copyright © 2020 Carlos Huang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private func change(color: UIColor){
        self.view.backgroundColor = color
        
    }
    
    let colorService = ColorService()
    
    @IBOutlet weak var connectionsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.green
        // Do any additional setup after loading the view.
        colorService.delegate = self as? ColorServiceDelegate
    }


    @IBAction func redTapped() {
        self.change(color: .red)
        colorService.send(colorName: "red")
    }
    
    
    @IBAction func yellowTapped() {
        self.change(color: .yellow)
        colorService.send(colorName: "yellow")
    }
    
}


extension ViewController: ColorServiceDelegate{
    
    func connectedDevicesChanged(manager: ColorService, connectedDevices: [String]){
        OperationQueue.main.addOperation {
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func colorChanged(manager: ColorService, colorString: String){
        OperationQueue.main.addOperation {
            switch colorString{
            case "red":
                self.change(color: .red)
                
            case "yellow":
                self.change(color: .yellow)
                
            default:
                NSLog("%@", "Unknown color value recieved: \(colorString)")
            }
            
            
            
        }
        
    }
    
    
}

