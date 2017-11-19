//
//  SettingsViewController.swift
//  RunningRhythm
//
//  Created by Kun, Eucharist H on 11/14/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit
import Foundation

public var backgroundHex:UInt32 = 0xf7ebdf
private var count = 0

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColorFromHex(rgbValue: backgroundHex, alpha: 1);
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func colorChange(_ sender: Any) {

        if count == 0 {
            backgroundHex = 0x222222
            count += 1
        }
        else if count == 1 {
            backgroundHex = 0x9afc33
            count += 1
        }
        else if count == 2 {
            backgroundHex = 0xf7edbf
            count = 0
        }
        self.view.backgroundColor = UIColorFromHex(rgbValue: backgroundHex, alpha: 1);

    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
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
