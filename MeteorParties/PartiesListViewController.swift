//
//  SecondViewController.swift
//  MeteorParties
//
//  Created by Aram on 6/6/15.
//  Copyright (c) 2015 Aram Ben Shushan Ehrlich. All rights reserved.
//

import UIKit
import Foundation
import Meteor
import CoreData

class PartiesListViewController: UIViewController {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var subtitleLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  private var subscriptionLoader: SubscriptionLoader!
  
  var parties =  [Party]()
  
  @IBAction func addName(sender: AnyObject) {
    
    var alert = UIAlertController(title: "New name",
      message: "Add a new name",
      preferredStyle: .Alert)
    
    let saveAction = UIAlertAction(title: "Save",
      style: .Default) { (action: UIAlertAction!) -> Void in
        
        let nameField = alert.textFields![0] as! UITextField
        let descField = alert.textFields![1] as! UITextField
        
        self.saveNewParty(nameField.text,description: descField.text)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
      style: .Default) { (action: UIAlertAction!) -> Void in
    }
    
    alert.addTextFieldWithConfigurationHandler {
      (textField: UITextField!) -> Void in
      textField.placeholder = "New Party Name"
    }
    alert.addTextFieldWithConfigurationHandler {
      (textField: UITextField!) -> Void in
      textField.placeholder = "New Descrtiption"
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    presentViewController(alert,
      animated: true,
      completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Parties"
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
    initalizeSubscriptionLoader()
    
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: "databaseDidChange:",
      name: METDatabaseDidChangeNotification,
      object: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
  }
  override func viewDidDisappear(animated: Bool) {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  //MARK Subscriptions
  
  func configureSubscriptionLoader(subscriptionLoader: SubscriptionLoader) {
    subscriptionLoader.addSubscriptionWithName("parties", parameters: "")
  }
  func initalizeSubscriptionLoader() {
    
    subscriptionLoader = SubscriptionLoader()
    subscriptionLoader!.delegate = self
    
    configureSubscriptionLoader(subscriptionLoader!)
    
    if !subscriptionLoader!.isReady {
      if Meteor.connectionStatus == .Offline {
        println("Offline")
      } else {
        println("Online")
        
        var allParties = Meteor.database.collectionWithName("parties").allDocuments as Array
        for (index, element) in enumerate(allParties) {
          parties.append(Party(document: element as! METDocument))
        }
        tableView.reloadData();
      }
    }
  }
  func saveNewParty(name: String, description: String) {
    Meteor.database.performUpdates { () -> Void in
      var partiesCollection = Meteor.database.collectionWithName("parties")
      var documentID = partiesCollection.insertDocumentWithFields(["name":name, "party_description":description, "owner":Meteor.userID])
    }
  }
 
  //MARK: - Notifications
  
  @objc func databaseDidChange(notification: NSNotification){
    if let info = notification.userInfo {
      
      Meteor.database.collectionWithName("parties")
      
      var changes = info[METDatabaseChangesKey] as! METDatabaseChanges
      
      changes.enumerateDocumentChangeDetailsUsingBlock({
        (details: METDocumentChangeDetails!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
      
        var changeType = details.changeType
        var documentId = details.documentKey.documentID as! String
      
        switch changeType {
          case .Add:
            self.parties.insert(Party(details: details), atIndex: self.parties.count)
            
            dispatch_async(dispatch_get_main_queue(),{
              var nspath = NSIndexPath(forRow: self.parties.count - 1, inSection: 0)
              self.tableView.insertRowsAtIndexPaths([nspath], withRowAnimation: UITableViewRowAnimation.Fade)
              self.tableView.endUpdates()
            })
          
          case .Remove:
            
            var partyIndex = -1
            var partiesNSArray = self.parties as NSArray
            
            partiesNSArray.enumerateObjectsUsingBlock({ (element, index, stop) -> Void in
              var party = element as! Party
              if party._id! == documentId {
                partyIndex = index
                stop.initialize(true)
              }
            })

            self.parties.removeAtIndex(partyIndex)
            
            dispatch_async(dispatch_get_main_queue(),{
              var nspath = NSIndexPath(forRow: partyIndex, inSection: 0)
              self.tableView.deleteRowsAtIndexPaths([nspath], withRowAnimation: UITableViewRowAnimation.Fade)
              self.tableView.endUpdates()
            })
            
          case .Update:
            break
          
        }
      })
    }
  }
}

// MARK: - UITableViewDataSource

extension PartiesListViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return parties.count
  }
  func tableView(tableView: UITableView,
    cellForRowAtIndexPath
    indexPath: NSIndexPath) -> UITableViewCell {
      
      var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell

      let party = parties[indexPath.row]
      cell.textLabel?.text = party.name
      
      return cell
  }
}

extension PartiesListViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      var partiesCollection = Meteor.database.collectionWithName("parties")
      var documentID = partiesCollection.removeDocumentWithID(parties[indexPath.row]._id)
    }
  }
}

// MARK: - UIScrollViewDelegate

extension PartiesListViewController: UIScrollViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let row = indexPath.row
  }
}

extension PartiesListViewController: SubscriptionLoaderDelegate {
  
  func subscriptionLoader(subscriptionLoader: SubscriptionLoader, subscription: METSubscription, didFailWithError error: NSError) {
  }
}


