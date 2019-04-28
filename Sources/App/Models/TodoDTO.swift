//
//  File.swift
//  App
//
//  Created by Nisum on 4/13/19.
//

import Vapor
import MongoKitten

final class TodoDTO: Content {
    var _id:  ObjectId?
    var name: String

    init(_id: ObjectId?, name: String) {
        self._id = _id
        self.name = name
    }
}
