// ContentView.swift
// Devote
// 
// Created by Jonathan Schaffer
// Using Swift 5.0
//
// https://jonathanschaffer.com
// Copyright © 2023 Jonathan Schaffer. All rights reserved.

import SwiftUI
import CoreData

struct ContentView: View {
    // MARK: - PROPERTY
    
    @State var task: String = ""
    
    private var isButtonDisabled: Bool {
        task.isEmpty
    }
    
    // FETCHING DATA
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    // MARK: - FUNCTION
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.task = task
            newItem.completion = false
            newItem.id = UUID()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            task = ""
            hideKeyboard()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // MARK: - BODY
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    VStack(spacing: 16) {
                        TextField("New Task", text: $task)
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                        
                        Button(action: {
                            addItem()
                        }, label: {
                            Spacer()
                            Text("SAVE")
                            Spacer()
                        }) //: BUTTON
                        .disabled(isButtonDisabled) // elegant modifier used with computed property to disable the button
                        .padding()
                        .font(.headline)
                        .foregroundColor(.white)
                        .background(isButtonDisabled ? Color.gray : Color.pink)
                        .cornerRadius(10)
                    } //: VSTACK
                    .padding()
                    
                    List {
                        ForEach(items) { item in
                            VStack(alignment: .leading
                            ) {
                                Text(item.task ?? "")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            } //: VSTACK - LIST ITEM
                            .listRowBackground(Color.clear) // Used in conjuction with changing the listStyle from InsetGroupedList Style to PlainListStlye to make the background of each row of the list transparent.
                        } //: LOOP
                        .onDelete(perform: deleteItems)
                    } //: LIST
                    //.listStyle(InsetGroupedListStyle())
                    .listStyle(PlainListStyle()) // Used in conjuction with the listRowBackground and background Color.clear modifiers to achieve a transparent background. This does change the list style from a InsetGroupedListStyle to a PlainListStyle which may have other impacts but we will have to see.
                    .background(Color.clear) // Used in conjuction with changing the listStyle from InsetGroupedList Style to PlainListStlye to make the background of the entire list transparent as well as each row as seen in the listRowBackground modifier.
                    
                    
                } //: VSTACK
            } //: ZSTACK
            // Commented out the following because it does not seem to work any longer when trying to make the background of the list transparent
            // Instead the listStyle was changed to a PlainListStyle rather than a InsetGroupedListStyle with listRow and list backgrounds changed to Color.clear
            // May impact the app in other ways but seems to achieve the desired effect with minimal impact.
            //.onAppear() {
            //    //UITableView.appearance().backgroundColor = UIColor.clear
            //}
            .navigationBarTitle("Daily Tasks", displayMode: .large)
            .toolbar {
                //#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                //#endif
            } //: TOOLBAR
            .background(backgroundGradient.ignoresSafeArea())
        } //: NAVIGATION
        .navigationViewStyle(StackNavigationViewStyle())
    }

    
}

// MARK: - PREVIEW
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
