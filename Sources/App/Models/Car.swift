//
//  Car.swift
//  App
//
//  Created by Nisum on 4/17/19.
//

import Vapor
import MeowVapor

final class Car: Model, Content {
    static let collectionName = "cars"
    var _id = ObjectId()
    var model: String
    var brand: String
    var owner: Reference<Person>

    init(model: String, brand: String, owner: Reference<Person>) {
        self.model = model
        self.brand = brand
        self.owner = owner
    }
}

struct CarData: Content {
    var model: String
    var brand: String
    var owner: Reference<Person>
}

extension Car: Parameter {}
