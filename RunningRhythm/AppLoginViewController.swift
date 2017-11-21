//
//  AppLoginViewController.swift
//  RunningRhythm
//
//  Created by Boris Chu on 10/31/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit
import WebKit

class AppLoginViewController: UIViewController, WebViewControllerDelegate {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var loggedIn: UILabel!
    @IBOutlet weak var spotifyLoginButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var healthVCButton: UIButton!
    @IBOutlet weak var musicVCButton: UIButton!
    @IBOutlet weak var settingsVCButton: UIButton!
    
    var authViewController: UIViewController?
    var firstLoad: Bool!
    var logged = false
    var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = SettingsViewController().UIColorFromHex(rgbValue: backgroundHex, alpha: 1);
        userNameLabel.text = username
        NotificationCenter.default.addObserver(self, selector: #selector(self.sessionUpdatedNotification), name: NSNotification.Name(rawValue: "sessionUpdated"), object: nil)
        self.firstLoad = true
        self.statusLabel.text = ""
        userNameLabel.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        loggedIn.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        statusLabel.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        spotifyLoginButton.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: UIControlState(rawValue: 0))
        healthVCButton.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: .normal)
        musicVCButton.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: .normal)
        settingsVCButton.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: .normal)
    }
    
    @IBAction func connectWithSpotify(_ sender: Any) {
        self.openLoginPage()
    }
    
    func backToApp() {
        self.firstLoad = false
        self.statusLabel.text = "Logged in."
        spotifyLoginButton.setTitle("Connected with Spotify", for: .normal)
        spotifyLoginButton.backgroundColor = UIColor.clear
    }
    
    func sessionUpdatedNotification(_ notification: Notification) {
        self.statusLabel.text = ""
        let auth = SPTAuth.defaultInstance()
        self.presentedViewController?.dismiss(animated: true, completion: { _ in })
        if auth!.session != nil && auth!.session.isValid() {
            self.statusLabel.text = ""
            logged = true
            self.backToApp()
        }
        else {
            self.statusLabel.text = "Login failed."
            print("*** Failed to log in")
        }
    }
    
    func openLoginPage() {
        self.statusLabel.text = "Logging in..."
        let auth = SPTAuth.defaultInstance()
        if SPTAuth.supportsApplicationAuthentication() {
            UIApplication.shared.open(auth!.spotifyAppAuthenticationURL(), options: [:], completionHandler: nil)
        } else {
            self.authViewController = self.getAuthViewController(withURL: SPTAuth.defaultInstance().spotifyWebAuthenticationURL())
            self.definesPresentationContext = true
            self.present(self.authViewController!, animated: true, completion: { _ in })
        }
    }
    
    func getAuthViewController(withURL url: URL) -> UIViewController {
        let webView = WebViewController(url: url)
        webView.delegate = self
        return UINavigationController(rootViewController: webView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let auth = SPTAuth.defaultInstance()
        // Uncomment to turn off native/SSO/flip-flop login flow
        //auth.allowNativeLogin = NO;
        // Check if we have a token at all
        if auth!.session == nil {
            self.statusLabel.text = ""
            return
        }
        // Check if it's still valid
        if auth!.session.isValid() && self.firstLoad {
            logged = true
            self.backToApp()
            return
        }
        // Token expired, attempt to renew
//        self.statusLabel.text = "Token expired."
        if auth!.hasTokenRefreshService {
            self.renewToken()
            return
        }
        // Else, just show login dialog
    }
    
    func renewToken() {
        self.statusLabel.text = "Refreshing token..."
        SPTAuth.defaultInstance().renewSession(SPTAuth.defaultInstance().session) { error, session in
            SPTAuth.defaultInstance().session = session
            if error != nil {
                self.statusLabel.text = "Refreshing token failed."
                print("*** Error renewing session: \(error)")
                return
            }
        }
    }
    
    func webViewControllerDidFinish(_ controller: WebViewController) {
        // User tapped the close button. Treat as auth error
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
     // MARK: - Navigation
    @IBAction func CheckForLogged(_ sender: Any) {
        if logged == false {
            self.alertController = UIAlertController(title: "Log In Error", message: "You must be logged into Spotify to advance.", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default)
            self.alertController!.addAction(OKAction)
            self.present(self.alertController!, animated: true, completion:nil)
        }
    }
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if segue.identifier == "musicPlayer" {
            let destination = segue.destination as? MusicPlayerViewController
            destination?.username = username
        }
     }

    
}
