//
//  EntryListView.swift
//  CS3260FinalProject
//
//  Created by Elijah C. Cannon on 7/28/23.
//

import SwiftUI

struct ListView: View {
    
    // date string formatter
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }
    
    // class bindings
    @StateObject var viewModel = ListViewModel()
    @State var newEntry: EntryModel = EntryModel()
    
    var body: some View {
        
            VStack {
                // only show list if there are items in it
                if viewModel.entryList.isEmpty {
                    
                    VStack {
                        Text("You don't have any viewModel.entryList. \nCreate one to get started!")
                            .multilineTextAlignment(.center)
                        
                        // show the date as navigation title
                        NavigationLink(destination: EntryView(entry: $newEntry, dateFormatter: dateFormatter)
                            .onDisappear(perform: {
                                saveEntry()
                            })
                                .navigationTitle(dateFormatter.string(from: Date()))) {
                                    // new entry button
                                    Text("Create Entry")
                                        .padding()
                                        .bold()
                                        .background(.blue)
                                        .foregroundStyle(.white)
                                        .cornerRadius(10)
                                        .frame(width: 280, height: 50)
                                }
                                .padding(.top)
                    }
                    .padding()
                                        
                } else {
                    // all my entries are in this list
                    List {
                        ForEach($viewModel.entryList) { $entry in
                            
                        NavigationLink(destination: EntryView(entry: $entry, dateFormatter: dateFormatter)
                            .navigationTitle(dateFormatter.string(from: entry.entryDate)), isActive: $entry.isActive) {
                                VStack(alignment: .leading) {
                                    Text(dateFormatter.string(from: entry.entryDate))
                                        .bold()
                                        .font(.headline)
                                    Text(entry.text)
                                        .lineLimit(1)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            viewModel.entryList.remove(atOffsets: indexSet)
                        }
                    }
                    
                    // put new entry button at bottom
                    Spacer()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                    
                    NavigationLink(destination: EntryView(entry: $newEntry, dateFormatter: dateFormatter)
                        .onDisappear(perform: {
                            saveEntry()
                        })
                            .navigationTitle(dateFormatter.string(from: Date()))) {
                                Text("New Entry")
                                    .padding()
                                    .bold()
                                    .background(.blue)
                                    .foregroundStyle(.white)
                                    .cornerRadius(10)
                                    .frame(width: 280, height: 50)
                            }
                            .padding(.top)
                }
            }
            .navigationTitle("Journal")
            .background(.white)
            .onShake(perform: {
                let entries = viewModel.entryList
                let randomId = entries.randomElement()?.id
                if !entries.map({ $0.isActive }).contains(true), let index = entries.firstIndex(where: { entry in
                    entry.id == randomId
                }) {
                    entries[index].isActive = true
                    viewModel.entryList = entries
                }
            })
            
    }
    func saveEntry() {
        // update entry list in database
        if !newEntry.text.isEmpty {
            viewModel.entryList.append(newEntry)
            newEntry = EntryModel()
        }
    }
}

// preview
struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
