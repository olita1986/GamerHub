//
//  Person.swift
//  App
//
//  Created by Nisum on 4/16/19.
//

import MeowVapor

final class Person: Model, Content {
    static let collectionName = "persons"
    
    var _id =  ObjectId()
    var firstname: String
    var lastname: String

    init(firstname: String, lastname: String) {
        self.firstname = firstname
        self.lastname = lastname
    }
}

struct PersonData: Content {
    var firstname: String
    var lastname: String
}

extension Person: Parameter {}
