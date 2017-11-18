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

class HealthDataViewController: UIViewController {

    @IBOutlet weak var minute: UILabel!
    @IBOutlet weak var second: UILabel!
    public var timer: Timer!
    var fullTime = Int()
    var duration = Int()
    var minDuration = Int()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateLabels), userInfo: nil, repeats: true)
        let healthStore = HKHealthStore()
        func authorizeHealthKit() -> Bool {
            var isEnabled = true
            print(String(isEnabled))
            if HKHealthStore.isHealthDataAvailable() {
                let stepsCount = NSSet(object: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!)
                healthStore.requestAuthorization(toShare: nil, read: (stepsCount as! Set<HKObjectType>)) {
                    (success, error) -> Void in
                    isEnabled = success
                }
            }
            else {
                isEnabled = false
            }
            return isEnabled
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startWorkout(_ sender: UIButton) {
        TimerModel.sharedTimer.startTimer(withInterval: 1)
    }
    
    @IBAction func pauseWorkout(_ sender: UIButton) {
        TimerModel.sharedTimer.pauseTimer()
    }
    
    @IBAction func EndWorkout(_ sender: UIButton) {
        TimerModel.sharedTimer.stopTimer()
        duration = 0
        minDuration = 0
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
