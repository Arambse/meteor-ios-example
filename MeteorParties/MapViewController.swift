//
//  FirstViewController.swift
//  MeteorParties
//
//  Created by Aram on 6/6/15.
//  Copyright (c) 2015 Aram Ben Shushan Ehrlich. All rights reserved.
//

import UIKit
import Meteor
import Foundation

class MapViewController: UIViewController {
  
  @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var mapCenterPinImage: UIImageView!
  @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
  private var markers = Dictionary<String, AnyObject?>()
  private var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Map"
    var camera = GMSCameraPosition.cameraWithLatitude(32.096454,
      longitude: 34.772887, zoom: 17)
    mapView.camera = camera
    mapView.settings.compassButton = true
    mapView.delegate = self
    
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: "partiesDataChanged:",
      name: MTRAppDelegateDataChanged,
      object: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  //MARK Notifications
  func partiesDataChanged(notification: NSNotification) {
    
    var changeDetails = notification.object as! METDocumentChangeDetails
    var userInfo = notification.userInfo
    var changeType = changeDetails.changeType
    
    switch changeType {
    case .Add:
      if let info = notification.userInfo as? Dictionary<String,AnyObject> {
        if let party = info["party"] as? Party {
          dispatch_async(dispatch_get_main_queue(),{
            self.addMarker(party)
          })
        }
      }
    case .Remove:
      if let info = notification.object as? METDocumentChangeDetails {

        var partyId = info.documentKey.documentID as! String
        var markerIndex = -1
        
        if let partyId = info.documentKey.documentID as? String {
          if markers.indexForKey(partyId) != nil {
            var marker = markers[partyId] as! GMSMarker
            marker.map = nil
            markers.removeValueForKey(partyId)
          }
        }
      }
    case .Update:
      break
    }
  }
  
  func addMarker(party: Party) {
    if let partyLocation = party.location {
      var position = CLLocationCoordinate2DMake(Double((partyLocation.latitude as NSString).doubleValue) , Double((partyLocation.longitude as NSString).doubleValue) )
      var marker = GMSMarker(position: position)
      marker.title = party.name
      marker.appearAnimation = kGMSMarkerAnimationPop
      marker.snippet = party.party_description
      marker.icon = UIImage(named: "icon1sized")
      marker.map = mapView
      
      markers[party._id!] = marker
    }
  }
  
}

extension MapViewController: GMSMapViewDelegate {
  func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
    var alert = appDelegate.getAddNewPartyAlert(true, location: coordinate)
    presentViewController(alert, animated: true, completion: nil)
  }
}

