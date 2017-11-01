//
//  ViewController.swift
//  RunningRhythm
//
//  Created by Boris Chu on 10/26/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var username: String?
    var alertController: UIAlertController?
    let clientID = "e6b39d82ce7945a493ebe0811837cd3b"
    let redirectURL = "RunningRhythm://returnAfterLogin"
    let tokenSwapURL = "http://localhost:1234/swap"
    let tokenRefreshServiceURL = "http://localhost:1234/refresh"
    
    @IBOutlet weak var spotifyLoginButton: UIButton!
    var session:SPTSession!
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        UIApplication.shared.open(loginURL!)
    }
    
    func saveLogin(user: String, pass: String) {
        UserDefaults.standard.set(pass, forKey: user)
        username = user
    }
    
    @IBAction func loginWithApp(_ sender: Any) {
        if userNameTextField.text != "" && passwordTextField.text != "" {
            let password = UserDefaults.standard.object(forKey: userNameTextField.text!)
            if passwordTextField.text == password as? String {
                print("Login successful")
                username = userNameTextField.text
            } else {
                print("Incorrect username and password")
                self.alertController = UIAlertController(title: "Login Error", message: "Incorrect Username and Password, Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                self.alertController!.addAction(OKAction)
                self.present(self.alertController!, animated: true, completion:nil)
            }
        } else {
            self.alertController = UIAlertController(title: "Login error", message: "You must enter a value for all fields.", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            self.alertController!.addAction(OKAction)
            self.present(self.alertController!, animated: true, completion:nil)
        }
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        if userNameTextField.text != "" && passwordTextField.text != "" {
            saveLogin(user: userNameTextField.text!, pass: passwordTextField.text!)
        } else {
            self.alertController = UIAlertController(title: "Signup error", message: "You must enter a value for all fields.", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            self.alertController!.addAction(OKAction)
            self.present(self.alertController!, animated: true, completion:nil)
        }
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
        if segue.identifier == "spotifyLogin" {
            let destination = segue.destination as? SpotifyLoginViewController
            destination?.username = username
        }
    }
    
}

