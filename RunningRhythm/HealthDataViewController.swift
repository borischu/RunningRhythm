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
    @IBOutlet weak var stepsChartButton: UIButton!
    @IBOutlet weak var heartRateButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var startWorkout: UIButton!
    @IBOutlet weak var endWorkout: UIButton!
    @IBOutlet weak var startStop: UIButton!
    
    let healthManager = HealthKitManager()
    let healthStore = HKHealthStore()
    
    var heartRateInTime: HKStatisticsCollectionQuery?
    var stepsInTime: HKStatisticsCollectionQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if workoutState == false {
            startStop.setTitle("Start Workout", for: UIControlState(rawValue: 0))
        }
        else if workoutState == true {
            startStop.setTitle("End Workout", for: UIControlState(rawValue: 0))
        }
        second.text = String(format: "%02d", secondPassed)
        minute.text = String(format: "%02d", minutePassed) + ":"
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
        stepsChartButton.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: .normal)
        heartRateButton.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: .normal)
//        startWorkout.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: .normal)
//        pauseButton.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: .normal)
//        endWorkout.setTitleColor(SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1), for: .normal)
        if backgroundHex == night {
            stepsChartButton.setImage(#imageLiteral(resourceName: "graphiconinvert"), for: UIControlState(rawValue: 0))
            heartRateButton.setImage(#imageLiteral(resourceName: "graphiconinvert"), for: UIControlState(rawValue: 0))
        }
        
        if (healthManager.authorizeHealthKit()) {
            let stepsCount = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)
            let heartRate = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)
            
            //  Set the Predicates & Interval
            let predicate: NSPredicate?
            if timeRunning {
                predicate = HKQuery.predicateForSamples(withStart: timeStart, end: Date(), options: .strictStartDate)
            } else {
                predicate = HKQuery.predicateForSamples(withStart: timeStart, end: timeStop, options: .strictStartDate)
            }
            //   Get the start of the day
            let date = Date()
            var interval = DateComponents()
            interval.second = 1
            //  Perform the Query
            let stepsQuery = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: date as Date, intervalComponents:interval)
            
//            stepsInTime = HKStatisticsCollectionQuery(quantityType: stepsCount!, quantitySamplePredicate: predicate, options: [.separateBySource], anchorDate: date as Date, intervalComponents:interval)
            
            stepsQuery.initialResultsHandler = { query, results, error in
                if error != nil {
                    return
                }
                if let myResults = results {
                    if timeRunning {
                        myResults.enumerateStatistics(from: timeStart!, to: Date()) {
                            statistics, stop in
                            if let quantity = statistics.sumQuantity() {
                                let steps = quantity.doubleValue(for: HKUnit.count())
                                DispatchQueue.main.async {
                                    self.stepsTakenNumber.text = String(steps)
                                }
                            }
                        }
                    } else {
                        self.stepsTakenNumber.text = "0.0"
                    }
                }
            }
            
            let heartRateQuery = HKStatisticsCollectionQuery(quantityType: heartRate!, quantitySamplePredicate: predicate, options: [.discreteAverage], anchorDate: date as Date, intervalComponents:interval)
            
//            heartRateInTime = HKStatisticsCollectionQuery(quantityType: heartRate!, quantitySamplePredicate: predicate, options: [.separateBySource], anchorDate: date as Date, intervalComponents:interval)
            
            heartRateQuery.initialResultsHandler = { query, results, error in
                if error != nil {
                    return
                }
                if let myResults = results {
                    if timeRunning {
                        myResults.enumerateStatistics(from: timeStart!, to: Date()) {
                            statistics, stop in
                            if let quantity = statistics.sumQuantity() {
                                let heartRate = quantity.doubleValue(for: HKUnit.count())
                                DispatchQueue.main.async {
                                    print(heartRate)
                                    self.heartRateNumber.text = String(heartRate)
                                }
                            }
                        }
                    } else {
                        self.heartRateNumber.text = "0.0"
                    }
                }
            }
            self.healthStore.execute(stepsQuery)
            self.healthStore.execute(heartRateQuery)
        }
    }
    
    @IBAction func startStopWorkout(_ sender: Any) {
        if workoutState == false {
            workoutState = true
            startStop.setTitle("End Workout", for: UIControlState(rawValue: 0))
            TimerModel.sharedTimer.startTimer(withInterval: 1)
        }
        else {
            workoutState = false
            startStop.setTitle("Start Workout", for: UIControlState(rawValue: 0))
            TimerModel.sharedTimer.pauseTimer()
        }
    }
    
    func updateLabels() {
        second.text = String(format: "%02d", secondPassed)
        minute.text = String(format: "%02d", minutePassed) + ":"
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
//            destination?.stepsTakenPoints = stepsInTime
        }
        else if segue.identifier == "heartRate" {
            let destination = segue.destination as? HeartRateViewController
            destination?.totalTime = timePassed
//            destination?.heartRatePoints = heartRateInTime
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
