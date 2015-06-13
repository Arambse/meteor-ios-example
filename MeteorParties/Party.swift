//
//  Party.swift
//  MeteorParties
//
//  Created by Aram on 6/13/15.
//  Copyright (c) 2015 Aram Ben Shushan Ehrlich. All rights reserved.
//

import Foundation
import Meteor

struct Location {
  var latitude: String
  var longitude: String
}

class Party: NSObject {

    var _id: String?
    var name: String?
    var party_description: String?
    var is_public: NSNumber?
    var location: Location?
    var owner: String?
    var originalDoc: METDocument?

  override init() {
    super.init()
  }
  
  
  convenience init(details: METDocumentChangeDetails) {
    self.init()
    name = details.changedFields["name"] as? String
    party_description = details.changedFields["party_description"] as? String
    is_public = details.changedFields["is_public"] as? NSNumber
    owner = details.changedFields["owner"] as? String
    var location = details.changedFields["location"] as? Dictionary<String,String>
    if let locationObj = location {
      self.location = Location(latitude: locationObj["latitude"]!, longitude: locationObj["longitude"]!)
    }
    _id = details.documentKey.documentID as? String

  }
  

}

extension Party: Equatable {}

func ==(lhs: Party, rhs: Party) -> Bool {
  return lhs._id == rhs._id
}
