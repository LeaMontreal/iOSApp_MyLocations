//
//  Functions.swift
//  MyLocations
//
//  Created by user206341 on 10/29/21.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping ()->Void ) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

let applicationDocumentDirectory: URL = {
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return path[0]
}()

// notify user the fatal core data error
let dataSaveFailedNotification = Notification.Name(rawValue: "dataSaveFailedNotification")

func fatalCoreDataError(_ error: Error) {
    print("Error: \(error)")
    
    NotificationCenter.default.post(name: dataSaveFailedNotification, object: nil)
}
