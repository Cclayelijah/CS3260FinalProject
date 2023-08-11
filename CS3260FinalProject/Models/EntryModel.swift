//
//  JournalEntry.swift
//  CS3260FinalProject
//
//  Created by Elijah C. Cannon on 7/24/23.
//

import Foundation

class EntryModel: Identifiable, ObservableObject {
    // entry model variables
    @Published var id: Int = Int.random(in: 1...32000)
    @Published var entryDate: Date = Date()
    @Published var modifiedDate: Date = Date()
    @Published var text: String = ""
    @Published var isActive: Bool = false
    
    init() {}
    
    init(text: String) {
        self.text = text
    }
    
    init(id: Int, entryDate: Date, modifiedDate: Date, text: String) {
        self.id = id
        self.entryDate = entryDate
        self.modifiedDate = modifiedDate
        self.text = text
    }
}
