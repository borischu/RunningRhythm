//
//  AppLoginViewController.swift
//  RunningRhythm
//
//  Created by Boris Chu on 10/31/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit
import SafariServices

class AppLoginViewController: UIViewController {
  
    @IBOutlet weak var userNameLabel: UILabel!
    var username: String?
    let clientID = "aa7f9cdbd127419581e250a4525c4105"
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
        NotificationCenter.default.addObserver(self, selector: #selector(AppLoginViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessful"), object: nil)
    }
    
    @IBAction func connectWithSpotify(_ sender: Any) {
        let auth = SPTAuth.defaultInstance()!
        auth.clientID = clientID
        auth.redirectURL = URL(string: redirectURL)
        auth.tokenRefreshURL = URL(string: tokenRefreshServiceURL)
        auth.tokenSwapURL = URL(string: tokenSwapURL)
        auth.requestedScopes = [SPTAuthStreamingScope]
        let loginURL = auth.spotifyWebAuthenticationURL()
        UIApplication.shared.open(loginURL!)
    }
    
    func updateAfterFirstLogin() {
        if let sessionObj:AnyObject = UserDefaults.standard.object(forKey: "SpotifySession") as AnyObject? {
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            session = firstTimeSession
            spotifyLoginButton.setTitle("Connected with Spotify", for: .normal)
            spotifyLoginButton.backgroundColor = UIColor.clear
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "musicPlayer" {
            let destination = segue.destination as? MusicPlayerViewController
            destination?.session = session
        }
     }

    
}
