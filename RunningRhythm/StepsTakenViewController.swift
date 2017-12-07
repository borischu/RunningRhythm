//
//  StepsTakenViewController.swift
//  RunningRhythm
//
//  Created by Kun, Eucharist H on 11/14/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit
import Charts

class StepsTakenViewController: UIViewController {

    var totalTime: Int?
    
    @IBOutlet weak var stepsTitle: UILabel!
    @IBOutlet weak var backBtnSteps: UIButton!
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    var time = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = SettingsViewController().UIColorFromHex(rgbValue: backgroundHex, alpha: 1);
        backBtnSteps.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: UIControlState(rawValue: 0))
        stepsTitle.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        print(totalTime)
        lineChartView.noDataText = "No Steps Data."
        self.time = Array(0...totalTime!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        lineChartView.noDataText = "You need to provide data for the chart."
        
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
