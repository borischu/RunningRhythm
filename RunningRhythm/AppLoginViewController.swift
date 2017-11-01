//
//  AppLoginViewController.swift
//  RunningRhythm
//
//  Created by Boris Chu on 10/31/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit

class AppLoginViewController: UIViewController {
  
    var username: String?
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userNameLabel.text = username
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
