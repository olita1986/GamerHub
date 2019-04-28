//
//  JWTMiddleware.swift
//  App
//
//  Created by Nisum on 4/13/19.
//

import Vapor
import JWT

class JWTMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        if let token = request.http.headers.bearerAuthorization {
            do {
                try TokenHelpers.verifyToken(token.token)
                return try next.respond(to: request)
            } catch let error as JWTError {
                throw Abort(.unauthorized, reason: error.reason)
            }
        } else {
            throw Abort(.unauthorized, reason: "No Access Token")
        }
    }
}
