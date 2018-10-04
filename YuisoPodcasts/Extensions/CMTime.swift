//
//  CMTime.swift
//  YuisoPodcasts
//
//  Created by Renrui Liu on 5/10/18.
//  Copyright © 2018 Renrui Liu. All rights reserved.
//

import AVKit

extension CMTime {
    
    func toDisplayString() -> String {
        let currentSecond = Int(CMTimeGetSeconds(self))
        let seconds = currentSecond % 60
        let minutes = (currentSecond / 60) % 60
        
        if (currentSecond / 60) > 59 {
            let hours = (currentSecond / 60) / 60
            let timeFormatString = String(format: "%02d:%02d:%02d", hours,minutes,seconds) // 2 digital
            return timeFormatString
        }
        
        let timeFormatString = String(format: "%02d:%02d", minutes,seconds) // 2 digital
        return timeFormatString
    }
    
}
