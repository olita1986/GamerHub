//
//  RefreshToken.swift
//  App
//
//  Created by Nisum on 4/13/19.
//

import Vapor
import MongoKitten

final class RefreshToken: Content {

    fileprivate enum Constants {
        static let refreshTokenTime: TimeInterval = 60 * 24 * 60 * 60
    }

    var id: ObjectId?
    var token: String
    var expiredAt: Date
    var userID: ObjectId

    init(id: ObjectId? = nil,
         token: String,
         expiredAt: Date = Date().addingTimeInterval(Constants.refreshTokenTime),
         userID: ObjectId) {
        self.id = id
        self.token = token
        self.expiredAt = expiredAt
        self.userID = userID
    }

    func updateExpiredDate() {
        self.expiredAt = Date().addingTimeInterval(Constants.refreshTokenTime)
    }
}

struct RefreshTokenDto: Content {
    let refreshToken: String
}
