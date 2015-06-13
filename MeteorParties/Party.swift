//
//  Party.swift
//  MeteorParties
//
//  Created by Aram on 6/13/15.
//  Copyright (c) 2015 Aram Ben Shushan Ehrlich. All rights reserved.
//

import Foundation
import Meteor

class Party: NSObject {

    var _id: String?
    var name: String?
    var party_description: String?
    var is_public: NSNumber?
    var owner: String?
    var originalDoc: METDocument?

  override init() {
    super.init()
  }
  
  convenience init(document: METDocument) {
    self.init()
    name = document.fields["name"] as? String
    party_description = document.fields["party_description"] as? String
    is_public = document.fields["is_public"] as? NSNumber
    owner = document.fields["owner"] as? String
    _id = document.key.documentID as? String
    
    originalDoc = document
  }
  
  convenience init(details: METDocumentChangeDetails) {
    self.init()
    name = details.changedFields["name"] as? String
    party_description = details.changedFields["party_description"] as? String
    is_public = details.changedFields["is_public"] as? NSNumber
    owner = details.changedFields["owner"] as? String
    _id = details.documentKey.documentID as? String

  }
  

}

extension Party: Equatable {}

func ==(lhs: Party, rhs: Party) -> Bool {
  return lhs._id == rhs._id
}
