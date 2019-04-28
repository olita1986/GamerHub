//
//  Request+Token.swift
//  App
//
//  Created by Nisum on 4/13/19.
//

import Vapor
import JWT
import MongoKitten

extension Request {

    var token: String {
        if let token = self.http.headers[.authorization].first {
            return token
        } else {
            return ""
        }
    }

    func authorizedUser(req: Request) throws -> Future<User> {
        let userID = try TokenHelpers.getUserID(fromPayloadOf: self.token)
        let db = try req.make(MongoKitten.Database.self)
        let users = db["users"]

        return users.findOne("_id" == userID, as: User.self).unwrap(or: Abort(.unauthorized, reason: "not found"))
    }
}
