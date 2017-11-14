//
//  AppLoginViewController.swift
//  RunningRhythm
//
//  Created by Boris Chu on 10/31/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit

class AppLoginViewController: UIViewController {
  
    @IBOutlet weak var userNameLabel: UILabel!
    var username: String?
    let clientID = "e6b39d82ce7945a493ebe0811837cd3b"
    let redirectURL = "RunningRhythm://returnAfterLogin"
    let tokenSwapURL = "http://localhost:1234/swap"
    let tokenRefreshServiceURL = "http://localhost:1234/refresh"
    var session:SPTSession!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameLabel.text = username
        let auth = SPTAuth.defaultInstance()!
        if auth.session == nil {
            print("No token/session exists")
            return
        }
        if auth.session.isValid() {
            print("Valid session exists")
            return
        }
    }
    
    
    @IBAction func connectWithSpotify(_ sender: Any) {
        let auth = SPTAuth.defaultInstance()!
        if auth == nil {
            auth.clientID = clientID
            auth.redirectURL = URL(string: redirectURL)
            auth.tokenRefreshURL = URL(string: tokenRefreshServiceURL)
            auth.tokenSwapURL = URL(string: tokenSwapURL)
            auth.requestedScopes = [SPTAuthStreamingScope]
            let loginURL = auth.spotifyWebAuthenticationURL()
            UIApplication.shared.open(loginURL!)
        } else {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
