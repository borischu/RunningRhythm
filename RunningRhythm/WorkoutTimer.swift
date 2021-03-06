//
//  WorkoutTimer.swift
//  RunningRhythm
//
//  Created by Kun, Eucharist H on 11/18/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import Foundation

public var secondPassed = 0
public var minutePassed = 0
public var timePassed = 0
public var timeRunning = false

class TimerModel: NSObject {
    static let sharedTimer: TimerModel = {
        let timer = TimerModel()
        return timer
    }()
    
    var internalTimer: Timer?
    
    func startTimer(withInterval interval: Double) {
        timeRunning = true
        internalTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(fireTimerAction), userInfo: nil, repeats: true)
    }
    
    func pauseTimer() {
        guard internalTimer != nil else {
            print("No timer active, start the timer before you stop it.")
            return
        }
        internalTimer?.invalidate()
    }
    
    func stopTimer() {
        guard internalTimer != nil else {
            print("No timer active, start the timer before you stop it.")
            return
        }
        secondPassed = 0
        minutePassed = 0
        timePassed = 0
        internalTimer?.invalidate()
        timeRunning = false
    }
    
    func fireTimerAction(sender: AnyObject?){
        secondPassed += 1
        timePassed += 1
        if (secondPassed == 59) {
            secondPassed = 0
            minutePassed += 1
        }
    }
}
