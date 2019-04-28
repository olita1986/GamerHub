import Vapor
import MongoKitten

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let todosController = TodoController()
    try router.register(collection: todosController)
    let usersController = UserController()
    try router.register(collection: usersController)
    let personsController = PersonController()
    try router.register(collection: personsController)

}
