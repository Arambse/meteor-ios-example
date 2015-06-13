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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  
  var window: UIWindow?
  
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    GMSServices.provideAPIKey(googleMapsApiKey)
    Meteor.connect()
    
    Meteor.loginWithEmail("arambse@gmail.com", password: "123456") { (error) -> Void in
      if let error = error {
        println("Error is: ", error)
      } else {
        println("Logged In")
        Meteor.addSubscriptionWithName("parties")
      }
    }
    
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
  }
  
  func applicationWillEnterForeground(application: UIApplication) {

  }
  
  func applicationDidBecomeActive(application: UIApplication) {
  }
  
  func applicationWillTerminate(application: UIApplication) {
  }
  
}

