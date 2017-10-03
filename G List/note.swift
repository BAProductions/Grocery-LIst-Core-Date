// Note.swift
// <Grocery-LIst is a simple list appclation for ios 9.3 an above and swift 2.2 an above>
// Copyright (C) <2016>  <DJABHipHop/BAProductions>

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
import UIKit
//Var
var allNotes: [Note] = []
var currentNoteIndex:Int = 0
var noteTable:UITableView?

let KAllNotes:String = "notes"


class Note: NSObject {
    var item:String
    var amount:NSNumber
    var checked:String
    //Init the  date
    override init() {
        item = ""
        amount = 1
        checked = "0"
    }
    //format the date
    func dictionary() -> NSDictionary {
        return ["item":item, "amount":amount, "checked":checked]
    }
    //Save the date
    class func saveNotes() {
        let aDictionaries:NSMutableArray = []
        for i:Int in 0 ..< allNotes.count {
            aDictionaries.add(allNotes[i].dictionary())
        }
        UserDefaults.standard.set(aDictionaries, forKey: KAllNotes)
    }
    //Loade the date
    class func loadNotes() {
        let defaults:UserDefaults = UserDefaults.standard
        let savedData:[NSDictionary]? = defaults.object(forKey: KAllNotes) as? [NSDictionary]
        if(savedData != nil ){
            let data:NSArray = (savedData! as NSArray)
            //let sort = NSSortDescriptor(key: "note", ascending: true)
            //data.sortedArray(using: [sort])
            for i:Int in 0 ..< data.count {
                let n:Note = Note()
                n.setValuesForKeys(data[i] as! [String : Any])
                allNotes.append(n)
            }
        }
    }
}

