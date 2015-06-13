//
//  AppDelegate.swift
//  MeteorParties
//
//  Created by Aram on 6/6/15.
//  Copyright (c) 2015 Aram Ben Shushan Ehrlich. All rights reserved.
//

import UIKit
import Meteor
import GoogleMaps
import CoreData

let Meteor = METDDPClient(serverURL: NSURL(string: "ws://localhost:3000/websocket")!)
let googleMapsApiKey = "AIzaSyCD7G1fR0KxQqhMKBvb-GLt3TGR6_06A8E"

let MTRAppDelegateDataChanged = "MTRPartiesDataChanged"

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
  
  
  var window: UIWindow?
  var parties: [Party] = []
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    GMSServices.provideAPIKey(googleMapsApiKey)
    Meteor.connect()
    
    Meteor.loginWithEmail("arambse@gmail.com", password: "123456") { (error) -> Void in
      if let error = error {
        println("Error is: ", error)
      } else {
        println("Logged In")
        
        NSNotificationCenter.defaultCenter().addObserver(
          self,
          selector: "databaseDidChange:",
          name: METDatabaseDidChangeNotification,
          object: nil)
        
        self.initializeSubscriptionLoader()

      }
    }
    
    return true
  }
  
  func initializeSubscriptionLoader() {
    var subscription = Meteor.addSubscriptionWithName("parties") { (error) -> Void in
      
      if error != nil {
        println("error while subscribing \(error)")
      }
        if Meteor.connectionStatus == .Offline {
          println("Offline")
        } else {
          println("Online")
        }
      }
    }
  
  //MARK Notifications
  func databaseDidChange(notification: NSNotification){
    if let info = notification.userInfo {
      
      Meteor.database.collectionWithName("parties")
      
      var changes = info[METDatabaseChangesKey] as! METDatabaseChanges
      
      changes.enumerateDocumentChangeDetailsUsingBlock({
        (details: METDocumentChangeDetails!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
        
        var changeType = details.changeType
        var documentId = details.documentKey.documentID as! String
        var dataUserInfo: [NSObject: AnyObject]? = nil
        
        switch changeType {
        case .Add:
          self.parties.insert(Party(details: details), atIndex: self.parties.count)
        case .Remove:
          
          var partyIndex: Int = -1
          var partiesNSArray = self.parties as NSArray
          
          partiesNSArray.enumerateObjectsUsingBlock({ (element, index, stop) -> Void in
            var party = element as! Party
            if party._id! == documentId {
              partyIndex = index
              stop.initialize(true)
            }
          })
          
          self.parties.removeAtIndex(partyIndex)
          dataUserInfo = ["IndexToRemove": partyIndex]
          
        case .Update:
          break
          
        }
        
        var changeNotification = NSNotification(name: MTRAppDelegateDataChanged, object: details, userInfo: dataUserInfo)
        
        NSNotificationCenter.defaultCenter().postNotification(changeNotification)

      })
    }
  }

}

