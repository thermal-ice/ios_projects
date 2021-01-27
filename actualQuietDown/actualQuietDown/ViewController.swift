//
//  ViewController.swift
//  actualQuietDown
//
//  Created by Carlos Huang on 2020-04-17.
//  Copyright © 2020 Carlos Huang. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer


class ViewController: UIViewController {

    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBOutlet weak var connectionsLabel: UILabel!
    
    let volumeService = VolumeService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        volumeSlider.value = AVAudioSession.sharedInstance().outputVolume
        volumeService.delegate = self as volumeServiceDelegate
        
    }
    
    
    @IBAction func halfVolumeButton() {
        MPVolumeView.setVolume(0.5)
        volumeSlider.value = 0.5
        volumeService.send(volumeValue: "0.5")
    }
    
    @IBAction func fifthVolumeButton() {
        MPVolumeView.setVolume(0.2)
        volumeSlider.value = 0.2
        volumeService.send(volumeValue: "0.2")
    }
    
    @IBAction func zeroVolumeButton() {
        MPVolumeView.setVolume(0.0)
        volumeSlider.value = 0.0
        volumeService.send(volumeValue: "0.0")
    }
    
    @IBAction func changeVolume(_ sender: UISlider) {
        MPVolumeView.setVolume(sender.value)
        volumeService.send(volumeValue: String(sender.value))
    }
    
}

extension MPVolumeView{
    static func setVolume(_ volume: Float) {
      let volumeView = MPVolumeView()
      let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.001) {
        slider?.value = volume
      }
    }
}

extension ViewController: volumeServiceDelegate{
    func volumeChanged(manager: VolumeService, volumeString: String) {
        OperationQueue.main.addOperation {
            guard let volumeFloat = Float(volumeString) else{
                NSLog("%@", "unknown volumeString value recieve: \(volumeString)")
                fatalError("Unknown volumeString value")
            }
            
            MPVolumeView.setVolume(volumeFloat)
            self.volumeSlider.value = volumeFloat
        }
    }
    
    
    func connectedDevicesChanged(manager: VolumeService, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionsLabel.text = "Connected to: \(connectedDevices)"
        }
    }
    
    
}
