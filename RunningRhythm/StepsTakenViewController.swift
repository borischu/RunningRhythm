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
            lineChartView.noDataTextColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        } else {
            time = Array(0...(stepsTakenPoints?.count)!-1)
            setChart(dataPoints: time, values: stepsTakenPoints!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChart(dataPoints: [Int], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        var count = 2
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i/60), y: values[i])
            dataEntries.append(dataEntry)
            if i % 30 == 0 {
                count += 1
            }
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Total Steps Taken")
        chartDataSet.drawCirclesEnabled = false
        let chartData = LineChartData(dataSet: chartDataSet)
        lineChartView.data = chartData
        lineChartView.chartDescription?.text = "Time elapsed (min)"
        lineChartView.chartDescription?.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        lineChartView.xAxis.setLabelCount(count, force: true)
        lineChartView.xAxis.labelTextColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        lineChartView.leftAxis.labelTextColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        lineChartView.rightAxis.labelTextColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
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
