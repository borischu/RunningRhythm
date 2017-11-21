//
//  HealthDataViewController.swift
//  RunningRhythm
//
//  Created by Kun, Eucharist H on 11/14/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit
import HealthKit
import HealthKitUI
import CoreMotion

class HealthDataViewController: UIViewController {

    @IBOutlet weak var minute: UILabel!
    @IBOutlet weak var second: UILabel!
    public var timer: Timer!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stepsTakenLabel: UILabel!
    @IBOutlet weak var stepsTakenNumber: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var heartRateNumber: UILabel!
    @IBOutlet weak var workoutLengthLabel: UILabel!
    @IBOutlet weak var backBtnHealth: UIButton!
    
    let healthManager = HealthKitManager()
    let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        second.text = String(secondPassed)
        minute.text = "\(minutePassed):"
        self.view.backgroundColor = SettingsViewController().UIColorFromHex(rgbValue: backgroundHex, alpha: 1);
        backBtnHealth.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: UIControlState(rawValue: 0))
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateLabels), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
        minute.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        second.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        titleLabel.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        stepsTakenLabel.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        stepsTakenNumber.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        heartRateLabel.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        heartRateNumber.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        workoutLengthLabel.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1)
        
        if (healthManager.authorizeHealthKit()) {
            let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
            let heartRate = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
            //   Get the start of the day
            let date = Date()
            let cal = Calendar(identifier: Calendar.Identifier.gregorian)
            let yest = date.yesterday
            
            //  Set the Predicates & Interval
            let predicate = HKQuery.predicateForSamples(withStart: yest, end: date, options: .strictStartDate)
            var interval = DateComponents()
            interval.day = 1
            //  Perform the Query
            let stepsQuery = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: date as Date, intervalComponents:interval)
            
            stepsQuery.initialResultsHandler = { query, results, error in
                if error != nil {
                    return
                }
                if let myResults = results {
                    myResults.enumerateStatistics(from: yest, to: date) {
                        statistics, stop in
                        if let quantity = statistics.sumQuantity() {
                            let steps = quantity.doubleValue(for: HKUnit.count())
                            self.stepsTakenNumber.text = String(steps)
                        }
                    }
                }
            }
            
            let heartRateQuery = HKStatisticsCollectionQuery(quantityType: heartRate!, quantitySamplePredicate: predicate, options: [.discreteAverage], anchorDate: date as Date, intervalComponents:interval)
            
            heartRateQuery.initialResultsHandler = { query, results, error in
                if error != nil {
                    return
                }
                if let myResults = results {
                    myResults.enumerateStatistics(from: yest, to: date) {
                        statistics, stop in
                        if let quantity = statistics.sumQuantity() {
                            let heartRate = quantity.doubleValue(for: HKUnit.count())
                            self.heartRateNumber.text = String(heartRate)
                        }
                    }
                }
            }
            self.healthStore.execute(stepsQuery)
            self.healthStore.execute(heartRateQuery)
        }
    }
    
    @IBAction func startWorkout(_ sender: UIButton) {
        TimerModel.sharedTimer.startTimer(withInterval: 1)
    }
    
    @IBAction func pauseWorkout(_ sender: UIButton) {
        TimerModel.sharedTimer.pauseTimer()
    }
    
    @IBAction func EndWorkout(_ sender: UIButton) {
        TimerModel.sharedTimer.stopTimer()
        second.text = String(secondPassed)
        minute.text = "\(minutePassed):"
    }
    
    func updateLabels() {
        second.text = String(secondPassed)
        minute.text = "\(minutePassed):"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "stepsTaken" {
            let destination = segue.destination as? StepsTakenViewController
            destination?.totalTime = timePassed
        }
        else if segue.identifier == "heartRate" {
            let destination = segue.destination as? HeartRateViewController
            destination?.totalTime = timePassed
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
}
