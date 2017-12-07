//
//  HeartRateViewController.swift
//  RunningRhythm
//
//  Created by Kun, Eucharist H on 11/14/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit
import Charts

class HeartRateViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backBtnHeart: UIButton!
    
    public var totalTime = timePassed
    
    @IBOutlet weak var lineChartView: LineChartView!
    var time: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = SettingsViewController().UIColorFromHex(rgbValue: backgroundHex, alpha: 1);
        backBtnHeart.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: UIControlState(rawValue: 0))
        titleLabel.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        print(totalTime)
        time = ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55", "60"]
        let steps = [0.0, 200.0, 400.0, 700.0, 800.0, 1000.0, 1200.0, 1500.0, 1800.0, 2000.0, 2250.0, 2300.0, 2400.0]
        
        setChart(dataPoints: time, values: steps)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        lineChartView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "Heart Rate BPM")
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
