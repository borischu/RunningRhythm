//
//  MusicPlayerViewController.swift
//  RunningRhythm
//
//  Created by Pulicken, Christopher on 10/31/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit
import HealthKit

class MusicPlayerViewController: UIViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {

    var accessToken: String?
    let clientID = "e6b39d82ce7945a493ebe0811837cd3b"
    let redirectURL = "RunningRhythm://returnAfterLogin"
    let tokenSwapURL = "http://localhost:1234/swap"
    let tokenRefreshServiceURL = "http://localhost:1234/refresh"
    
    var player: SPTAudioStreamingController?
    var uri: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginToPlayer()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginToPlayer() {
        if player == nil {
            player = SPTAudioStreamingController.sharedInstance()
            do {
                try player?.start(withClientId: clientID)
            } catch {
                print("Player could not be initialized")
            }
        }
        player?.delegate = self
        player?.playbackDelegate = self
        player?.login(withAccessToken: accessToken)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
