//
//  HealthKitHelper.swift
//  RunningRhythm
//
//  Created by Kun, Eucharist H on 11/17/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class HealthKitManager {
    
    let healthStore = HKHealthStore()
    func authorizeHealthKit() -> Bool {
        var isEnabled = true
        if HKHealthStore.isHealthDataAvailable() {
            let stepsCount = NSSet(object: HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount))
            healthStore.requestAuthorization(toShare: nil, read: stepsCount as! Set<HKObjectType>) {
                    (success, error) -> Void in
                    isEnabled = success
                }
        }
        else {
            isEnabled = false
        }
            return isEnabled
        }
}
