//
//  FileName.swift
//  DreamRecorder
//
//  Created by 오민호 on 2017. 8. 29..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation

struct DispatchQueueLabel{
    
    static let audioSerialQueue = "audioSerialQueue"
    static let filterSerialQueue = "filterSerialQueue"
    
}

struct SoundFileName {
    
    static let defaultSound = "Default.wav"
    static let alarmTone = "Alarm-tone.wav"
    static let oldAlarm = "Old-alarm-clock-ringing.wav"
    static let carefreeMelody = "Carefree_Melody.mp3"
    
}

struct DefaultLableText {
    
    static let defaultAlarmName = "Alarm".localized
    
}

struct TabbarTitle {
    
    static let dreamTab = "Dream".localized
    static let alarmTab = "Alarm".localized
    static let settingTab = "Setting".localized
    
}

struct BarButtonText {
    
    static let cancel = "Cancel".localized
    static let save = "Save".localized
    static let edit = "Edit".localized
    static let date = "Date".localized
    
}

struct AlartText {
    
    static let cancel = "Cancel".localized
    static let done = "Done".localized
    static let alarmName = "Label".localized
    static let dreamTitle = "Dream Title".localized
    static let enterInputTitle = "Enter a dream title".localized
    static let save = "Save".localized
    static let noTitle = "New Dream".localized
    static let occurError = "Error!!!".localized
    static let alarm = "Alarm".localized
    static let alarmNotActive = "This alarm is not active.".localized
    static let questionToActiveAlarm = "Do you want to activate this alarm?".localized
    static let ok = "OK".localized
}

struct GuideText {
    
    static func endRecording(leftTime argument : Int) -> String {
        return String(format: NSLocalizedString("The microphone will turn off after %d sconds", comment: ""), argument)
    }
    
    static let pickSong = "Pick a song".localized
    
    static let swipeUpOrDown = "Swipe up or down to select custom action.".localized
    
}

struct NavigationTitle {
    
    static let addAlarm = "Add Alarm".localized
    static let editAlarm = "Edit Alarm".localized
    static let sound = "Sound".localized
    static let alarm = "Alarm".localized
    
}

struct PreviewText {
    
    static let delete = "Delete".localized
    static let activate = "Activate".localized
    
}

struct TableCellText {
    
    static let delete = "Delete".localized
    static let share = "Share".localized
    
}

struct DreamSearch {
    
    static let placeHolder = "꿈 제목, 꿈 내용 검색".localized
    
}

