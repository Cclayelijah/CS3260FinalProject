//
//  EntryView.swift
//  CS3260FinalProject
//
//  Created by Elijah C. Cannon on 7/28/23.
//

import SwiftUI

struct EntryView: View {
    
    // for save button on the top right
    @Environment(\.presentationMode) var presentationMode
    @Binding var entry: EntryModel
    let dateFormatter: DateFormatter
    
    var body: some View {
        VStack {
            // last modified [today]
            Text("Last Modified \(entry.modifiedDate.compare(NSDate() as Date) == .orderedSame ? dateFormatter.string(from: entry.modifiedDate) : "Today")")
                .foregroundColor(.gray)
            TextEditor(text: $entry.text)
                .padding()
        }
        .toolbar {
            Button("Save") {
                presentationMode.wrappedValue.dismiss()
            }
        }
            
    }
    
}
