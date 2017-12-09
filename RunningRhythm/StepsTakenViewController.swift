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
    
    @IBOutlet weak var stepsTitle: UILabel!
    @IBOutlet weak var backBtnSteps: UIButton!
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    var stepsTakenPoints: [Double]?
    
    var time = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = SettingsViewController().UIColorFromHex(rgbValue: backgroundHex, alpha: 1);
        backBtnSteps.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: UIControlState(rawValue: 0))
        stepsTitle.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        if stepsTakenPoints?.count == 0 {
            lineChartView.noDataText = "Workout not in session. No current steps data."
        } else {
            time = Array(0...(stepsTakenPoints?.count)!-1)
            setChart(dataPoints: time, values: stepsTakenPoints!)
        }
        print(stepsTakenPoints)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChart(dataPoints: [Int], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Total Steps Taken")
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChartView.data = chartData
        
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
