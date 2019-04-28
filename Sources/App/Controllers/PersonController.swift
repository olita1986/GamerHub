//
//  PersonController.swift
//  App
//
//  Created by Nisum on 4/16/19.
//

import Vapor
import MeowVapor

class PersonController: RouteCollection {
    func boot(router: Router) throws {
        let personGroup = router.grouped("persons")
        personGroup.post(PersonData.self, use: createHandler)
        personGroup.get(use: getAllHandler)
        personGroup.get(Person.parameter, use: getByIdHandler)

        let carsGroup = router.grouped("cars")
        carsGroup.post(CarData.self, use: creatCarHandler)
        carsGroup.get(use: getAllCarsHandler)
        carsGroup.get(Car.parameter, "owner", use: getCarOwner)
    }

    func creatCarHandler(req: Request, carData: CarData) throws -> Future<Car> {
        let context = try req.make(Meow.Context.self)
        let car = Car(model: carData.model, brand: carData.brand, owner: carData.owner)
        return car.save(to: context).map({ (_) in
            return car
        })
    }

    func getAllCarsHandler(req: Request) throws -> Future<[Car]> {
        let context = try req.make(Meow.Context.self)
        return context.find(Car.self).getAllResults()
    }

    func getCarOwner(req: Request) throws -> Future<Person> {
        let context = try req.make(Meow.Context.self)
        return try req.parameters.next(Car.self).flatMap({ (car) in
            return car.owner.resolve(in: context)
        })
    }

    func createHandler(req: Request, personData: PersonData) throws -> Future<Person> {
        let context = try req.make(Meow.Context.self)
        let person = Person(firstname: personData.firstname, lastname: personData.lastname)
        return person.save(to: context).map({ (_) in
            return person
        })
    }

    func getAllHandler(req: Request) throws -> Future<[Person]> {
        // This is how to get a json file from the project
//        let directory = DirectoryConfig.detect()
//        let configDir = "Sources/App/Config"
//        let data = try Data(contentsOf: URL(fileURLWithPath: directory.workDir)
//            .appendingPathComponent(configDir, isDirectory: true)
//            .appendingPathComponent("some.json", isDirectory: false))
//        print("this is the data: \(data)")
//        let personData = try JSONDecoder().decode(PersonData.self, from: data)
//        print(personData)

        let context = try req.make(Meow.Context.self)
        return context.find(Person.self).getAllResults()
    }

    func getByIdHandler(req: Request) throws -> Future<Person> {
        return try req.parameters.next(Person.self)
//        let personId = try req.parameters.next(Person.self)
//        let context = try req.make(Meow.Context.self)
//        return context.findOne(Person.self, where: "_id" == personId).unwrap(or: Abort(.notFound))
    }
}
