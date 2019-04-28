import Foundation
import Vapor
import MongoKitten

final class Todo: Content {
    var _id:  ObjectId?
    var name: String
    var userId: ObjectId

    init(_id: ObjectId?, name: String, userId: ObjectId) {
        self._id = _id
        self.name = name
        self.userId = userId
    }
}

extension Todo: Parameter {
    public static func resolveParameter(_ parameter: String, on container: Container) throws -> Future<Todo> {
        let objectId = try ObjectId(parameter)
        let db = try container.make(MongoKitten.Database.self)
        let todosCollection = db["todos"]
        return todosCollection.findOne("_id" == objectId, as: Todo.self).unwrap(or: Abort(.notFound))
    }
}

//extension ObjectId: Parameter {
//    public static func resolveParameter(_ parameter: String, on container: Container) throws -> ObjectId {
//        guard let objectId = try? ObjectId(parameter) else { throw Abort(.badRequest)}
//        return objectId
//    }
//}
