//
//  UserController.swift
//  App
//
//  Created by Nisum on 4/12/19.
//

import Foundation
import Vapor
import MongoKitten
import Crypto

class UserController: MongoBaseController, RouteCollection {
    func boot(router: Router) throws {
        let userRoutes = router.grouped("api", "users")
        userRoutes.post(User.self, use: createHandler)
        userRoutes.get(use: getAllHandler)
        userRoutes.post(Credentials.self, at:"login", use: loginHandler)
        userRoutes.post(RefreshTokenDto.self, at: "refreshToken", use: refreshTokenHandler)
    }

    func createHandler(req: Request, user: User) throws -> Future<User.Public> {
        do {
            try user.validate()
        } catch let error {
            guard let error = error as? ValidationError else {
                throw Abort(.badRequest)
            }
            throw Abort(.badRequest, reason: error.reason)
        }
        let db = try req.make(MongoKitten.Database.self)
        let users = db["users"]
        return users.findOne("email" == user.email, as: User.self).flatMap({ (existingUser)  in
            guard existingUser == nil else {
                throw Abort(.badRequest, reason: "user already exist")
            }
            let id = ObjectId()
            user.password = try BCrypt.hash(user.password)
            user._id = id
            let userDocument = try self.encoder.encode(user)
            return users.insert(userDocument).map({ (_) in
                return user.convertToPublic()
            })
        })
    }

    func getAllHandler(req: Request) throws -> Future<[User.Public]>{
        let db = try req.make(MongoKitten.Database.self)
        let users = db["users"]
        return users.find().decode(User.Public.self).getAllResults()
    }

    func loginHandler(req: Request, credentials: Credentials) throws -> Future<AccessDto>{
        let db = try req.make(MongoKitten.Database.self)
        let users = db["users"]
        return users.findOne("email" == credentials.username || "username" == credentials.username, as: User.self).flatMap({ (optionalUser) in
            guard let user = optionalUser else {
                throw Abort(.badRequest, reason: "User doesn't exist")
            }
            let digest = try req.make(BCryptDigest.self)
            if try digest.verify(credentials.password, created: user.password) {
                let accessToken = try TokenHelpers.createAccessToken(from: user)
                let expiredAt = try TokenHelpers.expiredDate(of: accessToken)
                let resfreshTokenString = TokenHelpers.createRefreshToken()
                let accessDTO = AccessDto(accessToken: accessToken, expiredAt: expiredAt, refreshToken: resfreshTokenString)
                let refreshToken = RefreshToken(token: resfreshTokenString, userID: user._id!)
                let refreshTokenDocument = try self.encoder.encode(refreshToken)
                let refreshTokens = db["tokens"]
                return refreshTokens.insert(refreshTokenDocument).transform(to: accessDTO)
            } else {
                throw Abort(.badRequest, reason: "Incorrect user password")
            }
        })
    }


    func refreshTokenHandler(req: Request, refreshTokenDto: RefreshTokenDto) throws -> Future<AccessDto> {
        let db = try req.make(MongoKitten.Database.self)
        let tokens = db["tokens"]
        let users = db["users"]
        return tokens.findOne("token" == refreshTokenDto.refreshToken, as: RefreshToken.self).unwrap(or: Abort(.unauthorized)).flatMap({ (refreshToken) in
            guard refreshToken.expiredAt > Date() else {
                return tokens.deleteOne(where: "token" == refreshToken.token).thenThrowing({ _ in
                    throw Abort(.unauthorized)
                })
            }
            return users.findOne("_id" == refreshToken.userID, as: User.self).unwrap(or: Abort(.unauthorized)).flatMap({ (user)in
                let accessToken = try TokenHelpers.createAccessToken(from: user)
                let refreshTokenString = TokenHelpers.createRefreshToken()
                let expiredAt = try TokenHelpers.expiredDate(of: accessToken)
                let accessDTO = AccessDto(accessToken: accessToken, expiredAt: expiredAt, refreshToken: refreshTokenString)
                refreshToken.token = refreshTokenString
                refreshToken.updateExpiredDate()
                let rerefreshTokenDocument = try self.encoder.encode(refreshToken)
                return tokens.insert(rerefreshTokenDocument).transform(to: accessDTO)
            })
        })
    }
}
