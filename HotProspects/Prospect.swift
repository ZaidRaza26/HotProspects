//
//  Prospect.swift
//  HotProspects
//
//  Created by Zaid Raza on 30/12/2020.
//  Copyright © 2020 Zaid Raza. All rights reserved.
//

import SwiftUI
class Prospect: Identifiable, Codable {
    
    let id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    var date = Date()
    fileprivate(set) var isContacted = false
    
}

class Prospects: ObservableObject {
    
    @Published private(set) var people: [Prospect]
    
    static let saveKey = "SavedData"
    
    init() {
        self.people = []
        getData()
    }
    
    func toggle(_ prospect: Prospect){
        objectWillChange.send()
        prospect.isContacted.toggle()
        saving()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(people){
            UserDefaults.standard.set(encoded, forKey: Self.saveKey)
        }
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        saving()
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        return paths[0]
    }
    
    func saving(){
        do{
            let filename = getDocumentsDirectory().appendingPathComponent("hotprospects")
            let data = try JSONEncoder().encode(self.people)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        }
        catch{
            print("Unable to write data \(error)")
        }
    }
    
    func getData(){
        let filename = self.getDocumentsDirectory().appendingPathComponent("hotprospects")
        
        do{
            let data = try Data(contentsOf: filename)
            self.people = try JSONDecoder().decode([Prospect].self, from: data)
        }
        catch {
            print("unable to load saved data \(error)")
            self.people = []
        }
    }
    
    func sortByName(){
        self.people = self.people.sorted(by: {$0.name < $1.name})
    }
    
    func sortByTime(){
        self.people = self.people.sorted(by: {$0.date < $1.date})
    }
}
