import Vapor
import MongoKitten
import MeowVapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
     middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
     middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)

    // db because it is connected to mongo container
    let connectionURI = "mongodb://db:27017/test"

    let meow = try MeowProvider(uri: connectionURI)
    try services.register(meow)

//    services.register { container -> MongoKitten.Database in
//        return try MongoKitten.Database.lazyConnect(connectionURI, on: container.eventLoop)
//    }
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}


extension MongoKitten.Database: Service {}
