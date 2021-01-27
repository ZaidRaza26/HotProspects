//
//  ContentView.swift
//  HotProspects
//
//  Created by Zaid Raza on 26/12/2020.
//  Copyright © 2020 Zaid Raza. All rights reserved.
//

import SwiftUI
import UserNotifications
import SamplePackage

struct ContentView: View {
    
    var prospects = Prospects()
    
    var body: some View {
        
        TabView {
            ProspectsView(filter: .none, shouldShowIcon: true)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Everyone")
            }
            ProspectsView(filter: .contacted, shouldShowIcon: false)
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Contacted")
            }
            ProspectsView(filter: .uncontacted, shouldShowIcon: false)
                .tabItem {
                    Image(systemName: "questionmark.diamond")
                    Text("Uncontacted")
            }
            MeView()
                .tabItem {
                    Image(systemName: "person.crop.square")
                    Text("Me")
            }
        }
        .environmentObject(prospects)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
