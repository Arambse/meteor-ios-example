//
//  SecondViewController.swift
//  MeteorParties
//
//  Created by Aram on 6/6/15.
//  Copyright (c) 2015 Aram Ben Shushan Ehrlich. All rights reserved.
//

import UIKit



let partyCellIdentifier = "PartyCell"

class PartiesListViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}

// MARK: - UITableViewDataSource
extension PartiesListViewController: UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1;
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(partyCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
    //
    //        let row = indexPath.row
    //        cell.textLabel?.text = swiftBlogs[row]
    //
    return cell
    
  }
}

// MARK: - UIScrollViewDelegate
extension PartiesListViewController: UIScrollViewDelegate {
  // scroll view delegate methods
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    let row = indexPath.row
  }
}

