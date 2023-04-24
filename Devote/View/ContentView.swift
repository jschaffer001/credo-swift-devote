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
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State var task: String = ""
    @State private var showNewTaskItem: Bool = false
    
    
    // FETCHING DATA
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    // MARK: - FUNCTION
   

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
               // MARK: - MAIN VIEW
                VStack {
                    // MARK: - HEADER
                    
                    HStack(spacing: 10) {
                        // TITLE
                        Text("Devote")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.heavy)
                            .padding(.leading, 4)
                            
                        Spacer()
                        // EDIT BUTTON
                        EditButton()
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 10)
                            .frame(minWidth: 70, minHeight: 24)
                            .background(
                                Capsule().stroke(Color.white, lineWidth: 2)
                            )
                        
                        // APPEARANCE BUTTON
                        Button(action: {
                            // TOGGLE APPEARANCE
                            isDarkMode.toggle()
                        }, label: {
                            Image(systemName: isDarkMode ? "moon.circle.fill" : "moon.circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .font(.system(.title, design: .rounded))
                        }) //: BUTTON
                        
                        
                    } //: HSTACK
                    .padding()
                    .foregroundColor(.white)
                    
                    
                    Spacer(minLength: 80)
                    
                    // MARK: - NEW TASK BUTTON
                    
                    Button(action: {
                        showNewTaskItem = true
                    }, label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                        Text("New Task")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                    })
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.pink, Color.blue]), startPoint: .leading, endPoint: .trailing)
                            .clipShape(Capsule())
                    )
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 8, x: 0.0, y: 0.0)
                    
                    // MARK: - TASKS
                    List {
                        ForEach(items) { item in
                            ListRowItemView(item: item)
                            //.listRowBackground(Color.clear) // Used in conjuction with changing the listStyle from InsetGroupedList Style to PlainListStlye to make the background of each row of the list transparent.
                        } //: LOOP
                        .onDelete(perform: deleteItems)
                    } //: LIST
                    //.listStyle(InsetGroupedListStyle())
                    .listStyle(PlainListStyle()) // Used in conjuction with the listRowBackground and background Color.clear modifiers to achieve a transparent background. This does change the list style from a InsetGroupedListStyle to a PlainListStyle which may have other impacts but we will have to see.
                    //.background(Color.clear) // Used in conjuction with changing the listStyle from InsetGroupedList Style to PlainListStlye to make the background of the entire list transparent as well as each row as seen in the listRowBackground modifier.
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.3),radius: 12)
                    .padding(.vertical, 40)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: 640)
                    .cornerRadius(16)
                } //: VSTACK
                .blur(radius: showNewTaskItem ? 8.0 : 0.0, opaque: false)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut(duration: 0.5))
                
                // MARK: - NEW TASK ITEM
                
                if showNewTaskItem {
                    BlankView(
                        backgroundColor: isDarkMode ? Color.black : Color.gray,
                        backgroundOpacity: isDarkMode ? 0.3 : 0.5)
                        .onTapGesture {
                            withAnimation() {
                                showNewTaskItem = false
                            }
                        }
                    
                    NewTaskItemView(isShowing: $showNewTaskItem)
                }
                
            } //: ZSTACK
            // Commented out the following because it does not seem to work any longer when trying to make the background of the list transparent
            // Instead the listStyle was changed to a PlainListStyle rather than a InsetGroupedListStyle with listRow and list backgrounds changed to Color.clear
            // May impact the app in other ways but seems to achieve the desired effect with minimal impact.
            //.onAppear() {
            //    //UITableView.appearance().backgroundColor = UIColor.clear
            //}
            .navigationBarTitle("Daily Tasks", displayMode: .large)
            .navigationBarHidden(true)
            .background(
                BackgroundImageView()
                    .blur(radius: showNewTaskItem ? 8.0 : 0.0, opaque: false)
            )
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
