//
//  LoginViewController.swift
//  RunningRhythm
//
//  Created by Boris Chu on 10/26/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit

class SpotifyLoginViewController: UIViewController {
    
    var username: String?
    @IBOutlet weak var userNameLabel: UILabel!
    let clientID = "e6b39d82ce7945a493ebe0811837cd3b"
    let redirectURL = "RunningRhythm://returnAfterLogin"
    let tokenSwapURL = "http://localhost:1234/swap"
    let tokenRefreshServiceURL = "http://localhost:1234/refresh"
    @IBOutlet weak var spotifyLoginButton: UIButton!
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
    @IBAction func loginWithSpotify(_ sender: AnyObject) {
        let auth = SPTAuth.defaultInstance()!
        
        auth.clientID = clientID
        auth.redirectURL = URL(string: redirectURL)
        auth.tokenRefreshURL = URL(string: tokenRefreshServiceURL)
        auth.tokenSwapURL = URL(string: tokenSwapURL)
        auth.requestedScopes = [SPTAuthStreamingScope]
        let loginURL = auth.spotifyWebAuthenticationURL()
        print("Login URL: \(loginURL)")
        UIApplication.shared.open(loginURL!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "appLogin" {
            let destination = segue.destination as? AppLoginViewController
            destination?.username = username
        }
    }
    
}

