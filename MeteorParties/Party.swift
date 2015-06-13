//
//  Party.swift
//  MeteorParties
//
//  Created by Aram on 6/13/15.
//  Copyright (c) 2015 Aram Ben Shushan Ehrlich. All rights reserved.
//

import Foundation
import CoreData

class Party: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var party_description: String
    @NSManaged var is_public: NSNumber

}
