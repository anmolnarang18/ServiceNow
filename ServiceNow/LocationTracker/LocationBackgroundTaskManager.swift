//
//  LocationBackgroundTaskManager.swift
//  LocationTrackerWithCoreData28
//
//  Created by click Labs on 6/29/17.
//  Copyright © 2017 cl-mac-min-92. All rights reserved.
//

import UIKit

class LocationShareModel {
  
  let timer: Timer? = nil
  let delaySeconds: Timer? = nil
  var bgTask: LocationBackgroundTaskManager?
  let myLocationArray: [Location]? = nil
  
  static let sharedModel = LocationShareModel()
  
  private init() {
    
  }
  
}

class LocationBackgroundTaskManager: NSObject {
  
  var bgTaskIdList = [UIBackgroundTaskIdentifier]()
    var masterTaskId = UIBackgroundTaskIdentifier.invalid
  
  static let shared = LocationBackgroundTaskManager()
  
  
  @discardableResult
  func beginNewBackgroundTask() -> UIBackgroundTaskIdentifier {
    
    let application = UIApplication.shared
    var bgTaskId = UIBackgroundTaskIdentifier.invalid
    
    bgTaskId = application.beginBackgroundTask {
      
//      let index = self.bgTaskIdList.index(where: { (id: Int) -> Bool in
//        return (id == bgTaskId)
//      })
//
//      if let index = index {
//        self.bgTaskIdList.remove(at: index)
//      }
      
      application.endBackgroundTask(bgTaskId)
        bgTaskId = UIBackgroundTaskIdentifier.invalid
      
    }
    
    if self.masterTaskId == UIBackgroundTaskIdentifier.invalid {
      self.masterTaskId = bgTaskId
    } else {
      self.bgTaskIdList.append(bgTaskId)
      self.endBackgroundTasks()
    }
    
    return bgTaskId
    
  }
  
  func endBackgroundTasks() {
    self.drainBGTaskList(all: false)
  }
  
  func endAllBackgroundTasks() {
    self.drainBGTaskList(all: true)
  }
  
  func drainBGTaskList(all: Bool) {
    let application = UIApplication.shared
    
    let count: Int = self.bgTaskIdList.count
    if count <= 0 {
      return
    }
    
    let iVar = all ? 0 : 1
    for _ in iVar..<count {
      let bgTaskId = self.bgTaskIdList[0]
      application.endBackgroundTask(bgTaskId)
      bgTaskIdList.remove(at: 0)
    }
    
    if bgTaskIdList.count > 0 {
    }
    
    if all {
      application.endBackgroundTask(self.masterTaskId)
    }
    
  }
  
}
