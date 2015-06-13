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
  
  private var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
  
  @IBAction func addName(sender: AnyObject) {
    var alert = appDelegate.getAddNewPartyAlert(false,location: CLLocationCoordinate2D())
    presentViewController(alert, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Parties Yeah!"
    self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: "partiesDataChanged:",
      name: MTRAppDelegateDataChanged,
      object: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  //MARK Notifications
  func partiesDataChanged(notification: NSNotification) {
    
    var changeDetails = notification.object as! METDocumentChangeDetails
    var userInfo = notification.userInfo
    var changeType = changeDetails.changeType
    
    switch changeType {
      case .Add:
        dispatch_async(dispatch_get_main_queue(),{
          var nspath = NSIndexPath(forRow: self.appDelegate.parties.count - 1, inSection: 0)
          self.tableView.insertRowsAtIndexPaths([nspath], withRowAnimation: UITableViewRowAnimation.Fade)
          self.tableView.endUpdates()
        })
      case .Remove:
        if let info = notification.userInfo as? Dictionary<String,NSNumber> {
          if let partyIndex = info["IndexToRemove"] as? Int {
            dispatch_async(dispatch_get_main_queue(),{
              var nspath = NSIndexPath(forRow: partyIndex, inSection: 0)
              self.tableView.deleteRowsAtIndexPaths([nspath], withRowAnimation: UITableViewRowAnimation.Fade)
              self.tableView.endUpdates()
            })
          }
          else {
            print("no value for key\n")
          }
        }
        else {
          print("wrong userInfo type")
        }
      case .Update:
        break
    }
  }
 
}

// MARK: - UITableViewDataSource

extension PartiesListViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return appDelegate.parties.count
  }
  
  func tableView(tableView: UITableView,
    cellForRowAtIndexPath
    indexPath: NSIndexPath) -> UITableViewCell {
      
      var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell

      let party = appDelegate.parties[indexPath.row]
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
      var documentID = partiesCollection.removeDocumentWithID(appDelegate.parties[indexPath.row]._id)
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
