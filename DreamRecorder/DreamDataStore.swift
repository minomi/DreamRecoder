
//  DreamDataStore.swift
//  DreamRecorder
//
//  Created by 오민호 on 2017. 8. 7..
//  Copyright © 2017년 BoostCamp. All rights reserved.
//

import Foundation
import SQLite

extension Notification.Name {

    /// DraemDataStore -> DreamListViewController(UI).
    static let DreamDataStoreDidAddDream = Notification.Name("DreamDataStoreDidAddDream")
    static let DreamDataStoreDidDeleteDream = Notification.Name("DreamDataStoreDidDeleteDream")
    static let DreamDataStoreDidUpdateDream = Notification.Name("DreamDataStoreDidUpdateDream")
    
}

class DreamDataStore {
    
    static let shared : DreamDataStore = DreamDataStore()
    
    private init() {}
    
    var dreams : [Dream] = []
    var filteredDreams : [Dream] = []
    
    let dbManager = DBManager.shared
    
    private let dreamTable = Table("Dreams")
    private let id = Expression<Int64>("id")
    private let title = Expression<String?>("title")
    private let content = Expression<String?>("content")
    private let createdDate = Expression<Date>("createdDate")
    
    func createTable() -> Bool {
        
        do {
            
            try dbManager.db.run(dreamTable.create(ifNotExists: true) { table in
                
                table.column(id, primaryKey: .autoincrement)
                table.column(title)
                table.column(content)
                table.column(createdDate)
                
            })
            
            return true
            
        } catch {
            NSLog("Create Table Fail")
            return false
        }
        
    }
    
    
    
    func select(period : (from: Date, to: Date)) {

        var tmpPeriod : (from: Date, to: Date) = period
        
        if period.from > period.to {
            tmpPeriod = (period.to, period.from)
        }
        
        let nextDate = period.to.addingTimeInterval(86400)
        
        let fromDate = Expression<Date>(value: tmpPeriod.from)
        let toDate = Expression<Date>(value: nextDate)
        
        let rowsResult = dbManager.selectAll(query: dreamTable.filter(createdDate >= fromDate
            && createdDate <= toDate)
            .order(createdDate.desc))
        
        dreams = []
        
        switch rowsResult {
            
        case let .success(rows) :
            
            rows.forEach({
                
                let id = $0.get(self.id)
                let title = $0.get(self.title)
                let content = $0.get(self.content)
                let createdDate = $0.get(self.createdDate)
                
                let dream = Dream(id: id,title: title, content: content, createdDate: createdDate)
                dreams.append(dream)
            })
            
        case let .failure(error) :
            print(error)
        }
    }
    
    func select(limit: Int) {
        
        self.dreams = [Dream]()
        
        let query = dreamTable
            .select(id, title, content, createdDate)
            .order(createdDate.desc)
            .limit(limit)
        
        do {
            for row in try dbManager.db.prepare(query) {
                
                let dream = Dream(id: row[id],
                                  title: row[title],
                                  content: row[content],
                                  createdDate: row[createdDate])
                
                dreams.append(dream)
                
            }
        } catch {
            NSLog("Dream select query fail")
        }

    }

    
    @discardableResult func insert(dream: Dream) -> RowResult {
        
        let insert = dreamTable.insert (

            title <- dream.title,
            content <- dream.content,
            createdDate <- dream.createdDate
            
        )

        let result = dbManager.insertRow(insert: insert)
        
        switch result {
            
        case let .success(row):
            dream.id = Int64(row)
            self.dreams.insert(dream, at: 0)
            NotificationCenter.default.post(name: .DreamDataStoreDidAddDream, object: nil)
            
        case .failure(_):
            print("default")
            
        }
        
        return result
    }
    
    @discardableResult func update(dream: Dream) -> RowResult {
        
        let updateRow = dreamTable.filter(id == dream.id)
        
        let result = self.dbManager.updateRow(update: updateRow.update(
            
            title <- dream.title,
            content <- dream.content
            
            )
        )
        
        
        switch result {
            
        case .success:
            if let idx = self.dreams.index(of: dream) {
                dreams[idx] = dream
            }
            
            NotificationCenter.default.post(name: .DreamDataStoreDidUpdateDream, object: nil)
            print("Success: update row \(dream.id)")
            
        case let .failure(error):
            print("error: \(error)")
            
        }
        
        return result
    }

    
    @discardableResult func delete(dream: Dream) -> RowResult {
        
        let deletingRow = dreamTable.filter(id == dream.id)
        let result = self.dbManager.deleteRow(delete: deletingRow.delete())
        
        switch result {
            
        case .success :
        
            var userInfo : [String : Int] = [:]
            
            if let idx = dreams.index(of: dream) {
                userInfo["row"] = idx
                self.dreams.remove(at: idx)
            }
            
            if let deletedIdx = filteredDreams.index(of: dream) {
                userInfo["rowInFiltering"] = deletedIdx
                self.filteredDreams.remove(at: deletedIdx)
            }
            
            NotificationCenter.default.post(name: .DreamDataStoreDidDeleteDream, object: nil, userInfo : userInfo)
            
        case let .failure(error) :
            print("error: \(error)")
            
        }
        
        return result
        
    }
    
    func filter(_ searchText : String) {
        
        let filterResult = dbManager.filterRow(query: dreamTable.filter(
            title.like("%\(searchText)%") ||
            content.like("%\(searchText)%")
            )
        )

        filteredDreams = []
        
        switch filterResult {
            
        case let .success(rows):
            
            rows.forEach({
                let id = $0.get(self.id)
                let title = $0.get(self.title)
                let content = $0.get(self.content)
                let createdDate = $0.get(self.createdDate)
                
                let dream = Dream(id: id, title: title, content: content, createdDate: createdDate)
                filteredDreams.append(dream)
            })
            
        case .failure(_):
            print("fail")

        }

    }

    func minimumDate() -> Date? {
        
        do {
            
            let minDate = try dbManager.db.scalar(dreamTable.select(createdDate.min))
            return minDate
            
        } catch {
            
            print(error)
            return nil
            
        }
        
    }
    
    func maximumDate() -> Date? {
        
        do {
            
            let maxDate = try dbManager.db.scalar(dreamTable.select(createdDate.max))
            return maxDate
            
        } catch {
            
            print(error)
            return nil
            
        }
        
    }
    
    func dropTable() {
        try? dbManager.db.run(dreamTable.drop())
    }

}
