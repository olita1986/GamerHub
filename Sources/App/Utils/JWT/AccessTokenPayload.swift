//
//  AccessTokenPayload.swift
//  App
//
//  Created by Nisum on 4/13/19.
//

import JWT
import MongoKitten

struct AccessTokenPayload: JWTPayload {

    var issuer: IssuerClaim
    var issuedAt: IssuedAtClaim
    var expirationAt: ExpirationClaim
    var userID: ObjectId

    init(issuer: String = "TokensTutorial",
         issuedAt: Date = Date(),
         expirationAt: Date = Date().addingTimeInterval(JWTConfig.expirationTime),
         userID: ObjectId) {
        self.issuer = IssuerClaim(value: issuer)
        self.issuedAt = IssuedAtClaim(value: issuedAt)
        self.expirationAt = ExpirationClaim(value: expirationAt)
        self.userID = userID
    }
    func verify(using signer: JWTSigner) throws {
        try self.expirationAt.verifyNotExpired()
    }
}
