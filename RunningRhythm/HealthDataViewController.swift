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
    var duration = 0
    var minDuration = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateLabels), userInfo: nil, repeats: true)
    }
    
    @IBAction func pauseWorkout(_ sender: UIButton) {
        timer.invalidate()
    }
    
    @IBAction func EndWorkout(_ sender: UIButton) {
        timer.invalidate()
        duration = 0
        minDuration = 0
        second.text = String(duration)
        minute.text = "\(minDuration):"
    }
    
    func updateLabels() {
        duration += 1
        second.text = String(duration)
        if (duration == 59) {
            minDuration += 1
            duration = 0
        }
        minute.text = "\(minDuration):"
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
