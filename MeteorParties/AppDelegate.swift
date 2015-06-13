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
          var party = Party(details: details)
          self.parties.insert(party, atIndex: self.parties.count)
          dataUserInfo = ["party": party]
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
  
  func getAddNewPartyAlert(hasLocation: Bool, location: CLLocationCoordinate2D) -> UIAlertController  {
    var alert = UIAlertController(title: "New Party 🙆",
      message: "Please enter data",
      preferredStyle: .Alert)
    
    let saveAction = UIAlertAction(title: "Save",
      style: .Default) { (action: UIAlertAction!) -> Void in
        
        let nameField = alert.textFields![0] as! UITextField
        let descField = alert.textFields![1] as! UITextField
        
        if hasLocation {
          self.saveNewPartyWithLocation(nameField.text,description: descField.text, location: location)
        } else {
          self.saveNewParty(nameField.text,description: descField.text)
        }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
      style: .Default) { (action: UIAlertAction!) -> Void in
    }
    
    alert.addTextFieldWithConfigurationHandler {
      (textField: UITextField!) -> Void in
      textField.placeholder = "Name"
    }
    alert.addTextFieldWithConfigurationHandler {
      (textField: UITextField!) -> Void in
      textField.placeholder = "Description"
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    return alert
  }
  //MARK Save
  
  func saveNewParty(name: String, description: String) {
    Meteor.database.performUpdates { () -> Void in
      var partiesCollection = Meteor.database.collectionWithName("parties")
      var documentID = partiesCollection.insertDocumentWithFields(["name":name, "party_description":description, "owner":Meteor.userID])
    }
  }
  
  func saveNewPartyWithLocation(name: String, description: String, location: CLLocationCoordinate2D) {
    
    var partyLocation = Dictionary<String,String>()
    partyLocation["latitude"] = String(stringInterpolationSegment: location.latitude)
    partyLocation["longitude"] = String(stringInterpolationSegment: location.longitude)
    
    var partiesCollection = Meteor.database.collectionWithName("parties")
    var documentID = partiesCollection.insertDocumentWithFields(["name":name, "party_description":description, "location": partyLocation, "owner":Meteor.userID])

  }

}

