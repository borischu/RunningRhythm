//
//  ViewController.swift
//  RunningRhythm
//
//  Created by Boris Chu on 10/26/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {
    
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
        print("Login URL: \(loginURL)")
        UIApplication.shared.open(loginURL!)
    }
    
    var loginList : [NSDictionary] = []
    
    func saveLogin(user: String, pass: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Login", in: managedContext)
        let loginList = NSManagedObject(entity: entity!, insertInto: managedContext)
        loginList.setValue(pass, forKey: user)
        do {
            try managedContext.save()
            print(loginList)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func loginWithApp(_ sender: Any) {
        if userNameTextField.text != "" && passwordTextField.text != "" {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            if passwordTextField.text == loginList[userNameTextField.text] as! String {
                print("Correct username and password")
            } else {
                print("Incorrect username and password")
                self.alertController = UIAlertController(title: "Login Error", message: "Incorrect Username and Password", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
                    print("Cancel Button Pressed 1");
                }
                self.alertController!.addAction(cancelAction)
                let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
                    print("Ok Button Pressed 1");
                }
                self.alertController!.addAction(OKAction)
                self.present(self.alertController!, animated: true, completion:nil)
            }
        } else {
            self.alertController = UIAlertController(title: "", message: "You must enter a value for all fields.", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
                print("Cancel Button Pressed 1");
            }
            self.alertController!.addAction(cancelAction)
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
                print("Ok Button Pressed 1");
            }
            self.alertController!.addAction(OKAction)
            self.present(self.alertController!, animated: true, completion:nil)
        }
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        if userNameTextField.text != "" && passwordTextField.text != "" {
            saveLogin(user: userNameTextField.text!, pass: passwordTextField.text!)
        } else {
            self.alertController = UIAlertController(title: "", message: "You must enter a value for all fields.", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
                print("Cancel Button Pressed 1");
            }
            self.alertController!.addAction(cancelAction)
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
                print("Ok Button Pressed 1");
            }
            self.alertController!.addAction(OKAction)
            self.present(self.alertController!, animated: true, completion:nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

