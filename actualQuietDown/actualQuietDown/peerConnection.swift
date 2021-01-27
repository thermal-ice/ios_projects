//
//  peerConnection.swift
//  actualQuietDown
//
//  Created by Carlos Huang on 2020-04-17.
//  Copyright © 2020 Carlos Huang. All rights reserved.
//

import Foundation
import MultipeerConnectivity


protocol volumeServiceDelegate {
    func connectedDevicesChanged(manager: VolumeService, connectedDevices: [String])
    func volumeChanged(manager: VolumeService,volumeString: String)
}


class VolumeService: NSObject{
    
    private let volumeServiceType = "sample-volume"
    
    private let myPeerId = MCPeerID(displayName: UIDevice.current.name)
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser
    
    var delegate: volumeServiceDelegate?
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self as MCSessionDelegate
        return session
        
    }()
    
    
    override init(){
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: volumeServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: volumeServiceType)
        super.init()
        
        self.serviceAdvertiser.delegate = self as MCNearbyServiceAdvertiserDelegate
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self as MCNearbyServiceBrowserDelegate
        self.serviceBrowser.startBrowsingForPeers()
    

    }
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    
    func send(volumeValue: String){
        NSLog("%@", "sendVolume \(volumeValue) to \(session.connectedPeers.count) peers!")
        
        if session.connectedPeers.count > 0{
            do{
                try self.session.send(volumeValue.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            }catch let error{
                NSLog("%@", "Error for sending \(error)")
            }
        }
        
        
    }
    
    
}


extension VolumeService: MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true,self.session)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
}

extension VolumeService: MCNearbyServiceBrowserDelegate{
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        //Automatically finds and invites the peers, should probably change in future
        NSLog("%@", "FoundPeer: \(peerID)")
        NSLog("%@", "Invite Peer: \(peerID)")
        
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "LostPeer \(peerID)")
    }
    
}


extension VolumeService: MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.rawValue)")
        self.delegate?.connectedDevicesChanged(manager: self, connectedDevices: session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didRecieveData: \(data)")
        let the_data_str = String(data: data,encoding: .utf8)!
        
        self.delegate?.volumeChanged(manager: self, volumeString: the_data_str)
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didRecieveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    
    
}
