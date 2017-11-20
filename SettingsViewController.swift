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
private var nightCount = false
private var isNight = false
public var color1:UInt32 = 0xf7ebdf
public var color2:UInt32 = 0xCBECFF
public var color3:UInt32 = 0xFFCFFE
public var color4:UInt32 = 0xD9FFCF
let colors = [color1, color2, color3, color4]
public var night:UInt32 = 0x222222
public var text:UInt32 = night

class SettingsViewController: UIViewController {

    
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var backgroundLabel: UILabel!
    @IBOutlet weak var nightLabel: UILabel!
    @IBOutlet weak var backBtnSettings: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColorFromHex(rgbValue: backgroundHex, alpha: 1);
        backgroundLabel.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        nightLabel.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        switchButton.isOn =  UserDefaults.standard.bool(forKey: "switchState")
        backBtnSettings.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: UIControlState(rawValue: 0))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func colorChange(_ sender: Any) {
        if isNight == false {
            if count >= colors.count - 1 {
                count = -1
            }
            count += 1
            backgroundHex = colors[count]
            self.view.backgroundColor = UIColorFromHex(rgbValue: backgroundHex, alpha: 1);
        }
    }
    
    @IBAction func saveSwitchPressed(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "switchState")
    }
    
    @IBAction func nightMode(_ sender: Any) {
        if nightCount == false {
            backgroundHex = night
            nightCount = true
            isNight = true
            text = color1
            backgroundLabel.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
            nightLabel.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
            backBtnSettings.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: UIControlState(rawValue: 0))
        }
        else if nightCount == true {
            backgroundHex = colors[count]
            nightCount = false
            isNight = false
            text = night
            backgroundLabel.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
            nightLabel.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
            backBtnSettings.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: UIControlState(rawValue: 0))
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
