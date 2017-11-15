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

    let auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
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
                try player?.start(withClientId: auth.clientID)
            } catch {
                print("Player could not be initialized")
            }
        }
        player?.delegate = self
        player?.playbackDelegate = self
        player?.login(withAccessToken: session.accessToken)
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
