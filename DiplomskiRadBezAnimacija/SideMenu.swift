//
//  SideMenu.swift
//  DiplomskiRadBezAnimacija
//
//  Created by Orhan Pojskic on 12/28/24.
//

import SwiftUI

struct SideMenu: View {
    @Binding var isOpen: Bool
    
    var body: some View {
        SideMenuContentView()
    }
}

#Preview {
    SideMenu(isOpen: .constant(true))
}

struct SideMenuContentView: View{
    var body: some View {
        VStack(alignment: .leading) {
            InfoView()
            BrowseListView()
            HistoryListView()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color(#colorLiteral(red: 0.09143231064, green: 0.1243622825, blue: 0.2272676528, alpha: 1)))
        .foregroundColor(.white)
        .ignoresSafeArea(edges: .vertical)
    }
}

struct InfoView: View {
    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 40, height: 40)
            
            VStack {
                Text("Orhan Pojskic")
                    .font(.headline)
                Text("iOS Developer")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Image(systemName: "multiply.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .padding(.top, -30)
            
        }
        .padding(.horizontal)
        .padding(.top, 80)
        .padding(.bottom, 30)
    }
}

struct BrowseListView: View {
    var body: some View {
        List {
            Section(header: Text("BROWSE").foregroundStyle(.gray)) {
                
                VStack {
                    Divider()
                        .frame(height: 1)
                    // Visina separatora
                        .padding(.leading, 50)  // Pomak separatora u lijevo
                        .padding(.trailing, 20)
                    // Pomak separatora u desno
                        .background(Color.gray)  // Boja separatora
                    
                    HStack{
                        Image(systemName: "house").resizable().frame(width: 20, height: 20).padding(.trailing, 5)
                        Text("Home").font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }.padding(.vertical, 10)
                        .contentShape(Rectangle())  // Čini cijeli red klikabilnim
                        .onTapGesture {
                            print("Navigacija bez strelice!")
                        }
                    Divider()
                        .frame(height: 1)  // Visina separatora
                        .padding(.leading, 50)  // Pomak separatora u lijevo
                        .padding(.trailing, 20)  // Pomak separatora u desno
                        .background(Color.gray)  // Boja separatora
                }.listRowBackground(Color(#colorLiteral(red: 0.09143231064, green: 0.1243622825, blue: 0.2272676528, alpha: 1)))
                    .listRowSeparator(.hidden)
                
                
                VStack {
                    HStack{
                        Image(systemName: "magnifyingglass").resizable().frame(width: 20, height: 20).padding(.trailing, 5)
                        Text("Search").font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }.padding(.bottom, 10)
                        .contentShape(Rectangle())  // Čini cijeli red klikabilnim
                        .onTapGesture {
                            print("Navigacija bez strelice!")
                        }
                    
                    Divider()
                        .frame(height: 1)  // Visina separatora
                        .padding(.leading, 50)  // Pomak separatora u lijevo
                        .padding(.trailing, 20)  // Pomak separatora u desno
                        .background(Color.gray)  // Boja separatora
                }.listRowBackground(Color(#colorLiteral(red: 0.09143231064, green: 0.1243622825, blue: 0.2272676528, alpha: 1)))
                    .listRowSeparator(.hidden)
                VStack {
                    HStack{
                        Image(systemName: "star").resizable().frame(width: 20, height: 20).padding(.trailing, 5)
                        Text("Favorites").font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }.padding(.bottom, 10)
                        .contentShape(Rectangle())  // Čini cijeli red klikabilnim
                        .onTapGesture {
                            print("Navigacija bez strelice!")
                        }
                    Divider()
                        .frame(height: 1)  // Visina separatora
                        .padding(.leading, 50)  // Pomak separatora u lijevo
                        .padding(.trailing, 20)  // Pomak separatora u desno
                        .background(Color.gray)  // Boja separatora
                }.listRowBackground(Color(#colorLiteral(red: 0.09143231064, green: 0.1243622825, blue: 0.2272676528, alpha: 1)))
                    .listRowSeparator(.hidden)
                VStack {
                    HStack{
                        Image(systemName: "bubble.left.and.bubble.right").resizable().frame(width: 20, height: 20).padding(.trailing, 5)
                        Text("Help").font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }
                    .contentShape(Rectangle())  // Čini cijeli red klikabilnim
                    .onTapGesture {
                        print("Navigacija bez strelice!")
                    }
                    
                }.listRowBackground(Color(#colorLiteral(red: 0.09143231064, green: 0.1243622825, blue: 0.2272676528, alpha: 1)))
                    .listRowSeparator(.hidden)
                
            }
        }
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)  // Skriva zadanu pozadinu liste
        .background(Color(#colorLiteral(red: 0.09143231064, green: 0.1243622825, blue: 0.2272676528, alpha: 1)))
        .listStyle(.inset)
    }
}

struct HistoryListView: View {
    var body: some View {
        List {
            Section(header: Text("HISTORY").foregroundStyle(.gray)) {
                
                VStack {
                    Divider()
                        .frame(height: 1)
                    // Visina separatora
                        .padding(.leading, 50)  // Pomak separatora u lijevo
                        .padding(.trailing, 20)
                    // Pomak separatora u desno
                        .background(Color.gray)  // Boja separatora
                    
                    HStack{
                        Image(systemName: "clock").resizable().frame(width: 20, height: 20).scaleEffect(x: -1, y: 1)  .padding(.trailing, 5)
                        Text("History").font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }.padding(.vertical, 10)
                        .contentShape(Rectangle())  // Čini cijeli red klikabilnim
                        .onTapGesture {
                            print("Navigacija bez strelice!")
                        }
                    Divider()
                        .frame(height: 1)  // Visina separatora
                        .padding(.leading, 50)  // Pomak separatora u lijevo
                        .padding(.trailing, 20)  // Pomak separatora u desno
                        .background(Color.gray)  // Boja separatora
                }.listRowBackground(Color(#colorLiteral(red: 0.09143231064, green: 0.1243622825, blue: 0.2272676528, alpha: 1)))
                    .listRowSeparator(.hidden)
                
                
                VStack {
                    HStack{
                        Image(systemName: "bell").resizable().frame(width: 20, height: 20).padding(.trailing, 5)
                        Text("Notifications").font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }.padding(.bottom, 10)
                        .contentShape(Rectangle())  // Čini cijeli red klikabilnim
                        .onTapGesture {
                            print("Navigacija bez strelice!")
                        }
                    
                    
                }.listRowBackground(Color(#colorLiteral(red: 0.09143231064, green: 0.1243622825, blue: 0.2272676528, alpha: 1)))
                    .listRowSeparator(.hidden)
                
            }
        }
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)  // Skriva zadanu pozadinu liste
        .background(Color(#colorLiteral(red: 0.09143231064, green: 0.1243622825, blue: 0.2272676528, alpha: 1)))
        .listStyle(.inset)
    }
}
