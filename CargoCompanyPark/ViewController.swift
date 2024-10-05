import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let truck1 = Truck(trailerAttached: true, trailerCapacity: 5000, make: "Mercedes", model: "Actros", year: 2019, capacity: 20000, types: [.bulk(maxWetAir: 10)], currentLoad: 15000)
        let truck2 = Truck(trailerAttached: false, make: "Scania", model: "R450", year: 2020, capacity: 18000, types: [.perishable(maxTemperature: 5)], currentLoad: 12000)

        let fleet = Fleet()
        fleet.addVehicle(truck1)
        fleet.addVehicle(truck2)
        
        guard let fragileCargo = Cargo(description: "Fragile", weight: 5000, type: .fragile(maxLoad: 1000)) else { return }
        guard let bulkCargo = Cargo(description: "Bulk", weight: 8000, type: .bulk(maxWetAir: 50)) else { return }

        truck1.loadCargo(cargo: bulkCargo)
        truck1.loadCargo(cargo: fragileCargo)
        truck1.unloadCargo()

        fleet.info()
    }


}

enum CargoType: Equatable {
    case fragile(maxLoad: Int)
    case perishable(maxTemperature: Double)
    case bulk(maxWetAir: Int)
    
    static func == (first: CargoType, second: CargoType) -> Bool {
        switch (first, second) {
        case (.fragile(let val1), .fragile(let val2)):
            return val1 == val2
        case (.perishable(let val1), .perishable(let val2)):
            return val1 == val2
        case (.bulk(let val1), .bulk(let val2)):
            return val1 == val2
        default:
            return false
        }
    }
}

struct Cargo {
    let description: String
    let weight: Int
    let type: CargoType
    
    init?(description: String, weight: Int, type: CargoType) {
        if(weight < 0) {
            return nil
        }
        self.description = description
        self.weight = weight
        self.type = type
    }
}

class Vehicle {
    let make: String
    let model: String
    let year: Int
    let capacity: Int
    var types: [CargoType]?
    var currentLoad: Int = 0
    
    init(make: String, model: String, year: Int, capacity: Int, types: [CargoType]? = nil, currentLoad: Int) {
        self.make = make
        self.model = model
        self.year = year
        self.capacity = capacity
        self.types = types
        self.currentLoad = currentLoad
    }
    
    func loadCargo(cargo: Cargo) {
        if(cargo.weight + currentLoad > capacity) {
            print("can't load cargo, capacity is not enough")
            return
        }
        if let supportedTypes = types {
            if !supportedTypes.contains(where: { $0 == cargo.type }) {
                print("This type of cargo not available")
                return
            } else {
                currentLoad += cargo.weight
                print("cargo loaded succesfully +\(cargo.weight)")
                return
            }
        } else {
            currentLoad += cargo.weight
            print("cargo loaded succesfully +\(cargo.weight)")
            return
        }
    }
    
    func unloadCargo() {
        currentLoad = 0
        print("cargo unloaded succesfully")
    }
}

class Truck: Vehicle {
    var trailerAttached: Bool
    var trailerCapacity: Int?
    var trailerTypes: [CargoType]?
    
    init(trailerAttached: Bool, trailerCapacity: Int? = nil, trailerTypes: [CargoType]? = nil, make: String, model: String, year: Int, capacity: Int, types: [CargoType]? = nil, currentLoad: Int) {
        self.trailerAttached = trailerAttached
        self.trailerCapacity = trailerCapacity
        self.trailerTypes = trailerTypes
        super.init(make: make, model: model, year: year, capacity: capacity, types: types, currentLoad: currentLoad)
    }
    
    override func loadCargo(cargo: Cargo) {
        if(cargo.weight + currentLoad > capacity + (trailerCapacity ?? 0)) {
            print("can't load cargo, capacity is not enough")
            return
        } else {
            if (cargo.weight + currentLoad <= capacity) {
                if let supportedTypes = types {
                    if supportedTypes.contains(where: { $0 == cargo.type }){
                        currentLoad += cargo.weight
                        print("cargo loaded succesfully +\(cargo.weight)")
                        return
                    } else {
                        print("can't load cargo, capacity is not enough")
                        return
                    }
                } else {
                    currentLoad += cargo.weight
                    print("cargo loaded succesfully +\(cargo.weight)")
                    return
                }
            } else if (cargo.weight + currentLoad <= trailerCapacity ?? 0){
                if let supportedTypes = trailerTypes {
                    if supportedTypes.contains(where: { $0 == cargo.type }){
                        currentLoad += cargo.weight
                        print("cargo loaded succesfully +\(cargo.weight)")
                        return
                    } else {
                        print("can't load cargo, capacity is not enough")
                        return
                    }
                } else {
                    currentLoad += cargo.weight
                    print("cargo loaded succesfully +\(cargo.weight)")
                    return
                }
            } else if let supportedTypesTrailer = trailerTypes, let supportedTypes = types {
                if supportedTypesTrailer.contains(where: { $0 == cargo.type }) && supportedTypes.contains(where: { $0 == cargo.type }) {
                    currentLoad += cargo.weight
                    print("cargo loaded succesfully +\(cargo.weight)")
                    return
                }
            }
        }
    }
}
    
class Fleet {
    var fleetArray: [Vehicle] = []
    
    init(fleetArray: [Vehicle]? = nil) {
        if let fleetArray = fleetArray {
            self.fleetArray = fleetArray
        }
    }
    
    func addVehicle(_ vehicle: Vehicle) {
        fleetArray.append(vehicle)
    }
    
    func totalCapacity() -> Int {
        var total = 0
        for vehicle in fleetArray {
            total += vehicle.capacity
        }
        return total
    }
    
    func totalCurrentLoad() -> Int {
        var total = 0
        for vehicle in fleetArray {
            total += vehicle.currentLoad
        }
        return total
    }
    
    func info() {
        for (index, vehicle) in fleetArray.enumerated() {
                    print("Vehicle №\(index + 1): \(vehicle.make) \(vehicle.model), \(vehicle.year) year, vehicle capacity: \(vehicle.capacity) kg, current load: \(vehicle.currentLoad) kg")
                }
    }
}
