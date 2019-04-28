//
//  TodoController.swift
//  App
//
//  Created by Nisum on 4/10/19.
//

import Foundation
import Vapor
import MongoKitten


class TodoController: MongoBaseController, RouteCollection {


    func boot(router: Router) throws {
        let todosRoutes = router.grouped("api","todos")

        todosRoutes.get(use: getAllHandler)
        todosRoutes.get(Todo.parameter, use: getById)

        let jwtGroup = todosRoutes.grouped(JWTMiddleware())
        jwtGroup.put(Todo.self, use: updateHandler)
        jwtGroup.post(TodoDTO.self, use: createHandler)
        jwtGroup.get("my-todos",use: getAllMyTodos)
        jwtGroup.delete(ObjectId.parameter, use: deleteHandler)
    }

    func createHandler(req: Request, todo: TodoDTO) throws -> Future<Todo> {
        return try req.authorizedUser(req: req).flatMap({ (user) in
            guard let userId = user._id else {
                throw Abort(.badRequest, reason: "User doesnt have id")
            }
            let createdTodo = Todo(_id: ObjectId(), name: todo.name, userId: userId)
            let db = try req.make(MongoKitten.Database.self)
            let todos = db["todos"]
            let todoDocument = try self.encoder.encode(createdTodo)
            let todoFuture = todos.insert(todoDocument)
            return todoFuture.transform(to: createdTodo)
        })
    }

    func getAllHandler(req: Request) throws -> Future<[Todo]> {
        // second method
        let db = try req.make(MongoKitten.Database.self)
        let todos = db["todos"]
        return todos.find().decode(Todo.self).getAllResults()
    }

    func getAllMyTodos(req: Request) throws -> Future<[Todo]> {
        return try req.authorizedUser(req: req).flatMap({ (user) in
            guard let userId = user._id else {
                throw Abort(.badRequest, reason: "User doesnt have id")
            }
            let db = try req.make(MongoKitten.Database.self)
            let todos = db["todos"]
            return todos.find("userId" == userId).decode(Todo.self).getAllResults()
        })
    }

    func getById(req: Request) throws -> Future<Todo> {
        return try req.parameters.next(Todo.self)
//        let objectId = try req.parameters.next(ObjectId.self)
//        let db = try req.make(MongoKitten.Database.self)
//        let todos = db["todos"]
//        return todos.findOne("_id" == objectId, as: Todo.self).unwrap(or: Abort(.notFound)).map({ (todo) in
//            return todo
//        })
    }

    func updateHandler(req: Request, todo: Todo) throws -> Future<Todo> {
        let db = try req.make(MongoKitten.Database.self)
        let todos = db["todos"]
        return todos.update(where: "_id" == todo._id, setting: ["name" : todo.name]).map({ (reply) in
            return todo
        })
    }

    func deleteHandler(req: Request) throws -> Future<HTTPStatus> {
        return try req.authorizedUser(req: req).flatMap({ (user) in
            let objectId = try req.parameters.next(ObjectId.self)
            let db = try req.make(MongoKitten.Database.self)
            let todosCollection = db["todos"]
            return todosCollection.deleteOne(where: "_id" == objectId && "userId" == user._id).flatMap({ (integer) in
                guard integer > 0 else {
                    throw Abort(.unauthorized, reason: "You don't own this todo")
                }
                return req.future(.noContent)
            })
        })
    }
}

class MongoBaseController {
    let encoder: BSONEncoder
    let decoder: BSONDecoder

    init(encoder: BSONEncoder = BSONEncoder(), decoder: BSONDecoder = BSONDecoder()) {
        self.encoder = encoder
        self.decoder = decoder
    }
}
