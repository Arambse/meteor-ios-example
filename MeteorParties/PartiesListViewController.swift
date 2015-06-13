//
//  SecondViewController.swift
//  MeteorParties
//
//  Created by Aram on 6/6/15.
//  Copyright (c) 2015 Aram Ben Shushan Ehrlich. All rights reserved.
//

import UIKit
import Meteor
import CoreData

class PartiesListViewController: UIViewController {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var subtitleLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  private var subscriptionLoader: SubscriptionLoader!
  
  var parties =  [NSManagedObject]()
  
  @IBAction func addName(sender: AnyObject) {
    
    var alert = UIAlertController(title: "New name",
      message: "Add a new name",
      preferredStyle: .Alert)
    
    let saveAction = UIAlertAction(title: "Save",
      style: .Default) { (action: UIAlertAction!) -> Void in
        
        let nameField = alert.textFields![0] as! UITextField
        let descField = alert.textFields![1] as! UITextField
        
        self.saveNewParty(nameField.text,description: descField.text)
        self.tableView.reloadData()
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
    tableView.registerClass(UITableViewCell.self,
      forCellReuseIdentifier: "Cell")
//    
//    var parties = Meteor.database.collectionWithName("parties")
//    var allParties = parties.allDocuments as! Array
    initalizeSubscriptionLoader()
  }
  
  override func viewDidAppear(animated: Bool) {
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
            let managedContext = Meteor.mainQueueManagedObjectContext
            let fetchRequest = NSFetchRequest(entityName:"Party")
            var error: NSError?
        
            let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [Party]

//            if let results = fetchedResults {
//              println(results[0])
//              self.tableView.reloadData()
//            } else {
//              println("Could not fetch \(error), \(error!.userInfo)")
//            }
        tableView.reloadData();
        println("Online")
      }
    }
  }
  
  
  //MARK CoreData
  
  func saveNewParty(name: String, description: String) {
  
//    let managedContext = nil
//    
//    let entity =  NSEntityDescription.entityForName("Parties", inManagedObjectContext: managedContext)
//    let party = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
//    
//    party.setValue(name, forKey: "name")
//    party.setValue(description, forKey: "party_description")
//    
//    var error: NSError?
//    if !managedContext.save(&error) {
//      println("Could not save \(error), \(error?.userInfo)")
//    }
//    
//    parties.append(party)
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
      
      let cell =
      tableView.dequeueReusableCellWithIdentifier("Cell")
        as! UITableViewCell
      
      let party = parties[indexPath.row]
      cell.textLabel!.text = party.valueForKey("name") as? String
      
      return cell
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

