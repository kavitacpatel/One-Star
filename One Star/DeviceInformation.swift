//
//  DeviceInformation.swift
//  One Star
//
//  Created by sid patel on 8/4/16.
//  Copyright © 2016 coretwist. All rights reserved.
//

import Foundation
import UIKit

class DeviceInfromation {
    
    
    
    init() {
        
        UIDevice.current().isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector:#selector(DeviceInfromation.batteryLevelChanged(batteryNotification:)), name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
    }
    
    
    
    @objc func batteryLevelChanged(batteryNotification: Notification){
        print(UIDevice.current().batteryLevel)
    }
    
    func checkBatteryLevel() ->  Float {
        
        return UIDevice.current().batteryLevel
    }
    
    func checkBatteryState(){
        
        switch UIDevice.current().batteryState {
        case .charging:
            print("phone chargin battery")
        case .full:
            print("phone battery is full")
        case .unplugged:
            print("phone battery is unplugged")
        case .unknown:
            print("phone battery is unknown")
        }
    }
    
}
