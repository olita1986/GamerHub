//
//  User.swift
//  App
//
//  Created by Nisum on 4/11/19.
//

import Foundation
import Vapor
import MongoKitten

final class User: Content {
    var _id: ObjectId?
    var name: String
    var username: String
    var password: String
    var email: String

    init(_id: ObjectId?,
        name: String,
        username: String,
        password: String,
        email: String) {
        self._id = _id
        self.name = name
        self.username = username
        self.password = password
        self.email = email
    }

    final class Public: Content {
        var _id: ObjectId?
        var name: String
        var username: String

        init(
            _id: ObjectId?,
            name: String,
            username: String) {
            self._id = _id
            self.name = name
            self.username = username
        }
    }
}

extension User {
    func convertToPublic() -> User.Public {
        return User.Public(_id: _id, name: name, username: username)
    }
}

extension User: Validatable, Reflectable {
    static func validations() throws -> Validations<User> {
        var validations = Validations(User.self)
        try validations.add(\.name, .ascii)
        try validations.add(\.username, .alphanumeric && .count(4...))
        try validations.add(\.password, .alphanumeric && .count(4...))
        try validations.add(\.email, .email)
        return validations
    }
}

//// 1
//extension Future where T: User {
//    // 2
//    func convertToPublic() -> Future<User.Public> {
//        // 3
//        return self.map(to: User.Public.self) { user in
//            // 4
//            return user.convertToPublic()
//        }
//    }
//}

//extension User: BasicAuthenticatable {
//    static var usernameKey: WritableKeyPath<User, String> {
//        return \.username
//    }
//
//    static var passwordKey: WritableKeyPath<User, String> {
//        return \.password
//    }
//
//    static func authenticate(using basic: BasicAuthorization, verifier: PasswordVerifier, on connection: DatabaseConnectable) -> EventLoopFuture<User?> {
//
//    }
//}

