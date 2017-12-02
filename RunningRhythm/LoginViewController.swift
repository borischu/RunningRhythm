//
//  ViewController.swift
//  RunningRhythm
//
//  Created by Boris Chu on 10/26/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit
public var username: String?

class LoginViewController: UIViewController, UITextFieldDelegate {
    

    var alertController: UIAlertController?
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = SettingsViewController().UIColorFromHex(rgbValue: backgroundHex, alpha: 1);
        userNameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @IBAction func loginWithApp(_ sender: Any) {
        if userNameTextField.text != "" && passwordTextField.text != "" {
            let password = UserDefaults.standard.object(forKey: userNameTextField.text!)
            if passwordTextField.text == password as? String {
                username = userNameTextField.text
                UserDefaults.standard.set(username, forKey: "userName")
                UserDefaults.standard.synchronize()
            } else {
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
            if UserDefaults.standard.object(forKey: userNameTextField.text!) == nil {
                UserDefaults.standard.set(passwordTextField.text!, forKey: userNameTextField.text!)
                username = userNameTextField.text!
                self.alertController = UIAlertController(title: "Signed up successful", message: "Enter username and password to login", preferredStyle: UIAlertControllerStyle.alert)
                let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                self.alertController!.addAction(OKAction)
                self.present(self.alertController!, animated: true, completion:nil)
            } else {
                self.alertController = UIAlertController(title: "Signup error", message: "That username has been taken. Please choose another one.", preferredStyle: UIAlertControllerStyle.alert)
                let OKAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default)
                self.alertController!.addAction(OKAction)
                self.present(self.alertController!, animated: true, completion:nil)
            }
        } else {
            print("in signup error")
            self.alertController = UIAlertController(title: "Signup error", message: "You must enter a value for all fields.", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default)
            self.alertController!.addAction(OKAction)
            self.present(self.alertController!, animated: true, completion:nil)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}

