//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Zaid Raza on 29/12/2020.
//  Copyright © 2020 Zaid Raza. All rights reserved.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {
    
    
    
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    let filter: FilterType
    
    @EnvironmentObject var prospects: Prospects
    
    @State private var isShowingScanner = false
    @State private var actionSheet = false
    var shouldShowIcon: Bool
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted People"
        case .uncontacted:
            return "Uncontacted People"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted}
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted}
        }
    }
    
    var body: some View {
        
        NavigationView{
            List{
                ForEach(filteredProspects){ prospect in
                    HStack(){
                        VStack(alignment: .leading){
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack{
                            if self.shouldShowIcon {
                                Image(systemName: prospect.isContacted ? "checkmark.circle" : "questionmark.diamond")
                            }
                        }
                    }
                    .contextMenu{
                        if !prospect.isContacted{
                            Button("Remind Me"){
                                self.addNotification(for: prospect)
                            }
                        }
                        
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted"){
                            self.prospects.toggle(prospect)
                        }
                    }
                }
            }
            .actionSheet(isPresented: $actionSheet){
                ActionSheet(title: Text("Select Sorting"), buttons: [
                    .default(Text("Alphabetically")) { self.prospects.sortByName() },
                    .default(Text("Time Added")) { self.prospects.sortByTime() },
                    .cancel()
                ])
            }
            .navigationBarTitle(title)
            .navigationBarItems(leading: Button("Sort"){
                self.actionSheet = true
                },
                                trailing: Button(action: {
                                    self.isShowingScanner = true
                                }){
                                    Image(systemName: "qrcode.viewfinder")
                                    Text("Scan")
            })
                .sheet(isPresented: $isShowingScanner){
                    CodeScannerView(codeTypes: [.qr], simulatedData: "Zaid Raza\nzaid@gmail.com", completion: self.handleScan)
            }
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        // more code to come
        switch result {
        case .success(let code):
            
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            self.prospects.add(person)
            
        case .failure(let error):
            print("Scanning failed")
        }
    }
    
    func addNotification(for prospect: Prospect){
        
        let center = UNUserNotificationCenter.current()
        let addRequest = {
            let content = UNMutableNotificationContent()
            
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            center.add(request)
        }
        
        center.getNotificationSettings{ settings in
            if settings.authorizationStatus == .authorized{
                addRequest()
            }
            else{
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success{
                        addRequest()
                    }
                    else {
                        print("not allowed")
                    }
                }
            }
        }
    }
}
