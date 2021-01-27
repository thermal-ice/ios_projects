//
//  ViewController.swift
//  QuitDownMom
//
//  Created by Carlos Huang on 2020-04-10.
//  Copyright © 2020 Carlos Huang. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer

class ViewController: UIViewController {

    @IBOutlet weak var progressLabel: UILabel!
   
    var audioPlayer: AVAudioPlayer!
    
    //Stealth volume control here
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = Bundle.main.url(forResource: "sample_recording", withExtension: "m4a")
        
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: url!)
            
            audioPlayer.prepareToPlay()
            audioPlayer.currentTime = 0
            audioPlayer.volume = 0.1
            
            progressLabel.text = "Play time: \(audioPlayer.currentTime)"
            
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {(timer) in
                self.progressLabel.text =  "\(round(self.audioPlayer.currentTime * 10) / 10)"
            })
        }catch let error as NSError{
            print(error.debugDescription)
        }
        
        
        
    }
    @IBAction func playAudio(_ sender: Any) {
        
        audioPlayer.play()
        
        
    }
    @IBAction func stopAudio(_ sender: Any) {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
    
        
    }
    @IBAction func pauseAudio(_ sender: Any) {
        audioPlayer.pause()
    }
   
    
    @IBAction func changeVolume(_ sender: UIButton) {
        MPVolumeView.setVolume(0.5)
        
    }
    
    @IBAction func volumeSlider(_ sender: UISlider) {
        
        MPVolumeView.setVolume(sender.value)
    }
    
    
}

extension MPVolumeView{
    static func setVolume(_ volume: Float) {
      let volumeView = MPVolumeView()
      let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider

      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.0001) {
        slider?.value = volume
      }
    }
}

