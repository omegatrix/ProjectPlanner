//
//  Helper.swift
//  ProjectPlanner
//
//  Created by user153198 on 4/27/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

/*
 This struct is a utility helper that provides helper functions such as unwrapping optional values, date to string etc.
*/

import UIKit

struct Helper
{
    
    /* Optional unwrap -> String */
    func unwrapString(optionalString: String?) -> String
    {
        var unWrappedString: String = "" //default value to return
        
        if let optionalString = optionalString
        {
            unWrappedString = optionalString
        }
        
        return unWrappedString
    }
    
    /* Optional unwrap -> Bool */
    func unwrapBoolean(optionalBool: Bool?) -> Bool
    {
        var unWrappedBool: Bool = false //default value to return
        
        if let optionalBool = optionalBool
        {
            unWrappedBool = optionalBool
        }
        
        return unWrappedBool
    }
    
    /* Optional unwrap -> Double */
    func unwrapDouble(optionalDouble: Double?) -> Double
    {
        var unWrappedDouble: Double = 0.0 //default value to return
        
        if let optionalDouble = optionalDouble
        {
            unWrappedDouble = optionalDouble
        }
        
        return unWrappedDouble
    }
    
    /* Optional unwrap -> Int16 */
    func unwrapInt16(optionalInt: Int16?) -> Int16
    {
        var unWrappedInt: Int16 = 0 //default value to return
        
        if let optionalInt = optionalInt
        {
            unWrappedInt = optionalInt
        }
        
        return unWrappedInt
    }
    
    /* Optional unwrap -> Date */
    func unwrapDate(optionalDate: Date?) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateToString(date: Date.init())
        var unWrappedDate: Date = dateFormatter.date(from: dateString) ?? Date.init()//default value to return
        
        if let optionalDate = optionalDate
        {
            let unWrappedDateString = dateToString(date: optionalDate)
            unWrappedDate = dateFormatter.date(from: unWrappedDateString) ?? Date.init()
        }
        
        return unWrappedDate
    }
    
    func dateToString(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    func priorityLiteral(priorityValue: Int16) -> String
    {
        return
            priorityValue == 0
            ?
            "High"
            :
            (
                priorityValue == 1
                ?
                "Medium"
                :
                "Low"
            )
    }
    
    func stringToSegmentIndex(priority: String) -> Int
    {
        return priority == "High" ? 0 : (priority == "Medium" ? 1 : 2)
    }
    
    func int16_To_Int(value: Int16) -> Int
    {
        let newValue: Int = Int(value)
        
        return newValue
    }
    
    func int_To_int16(value: Int) -> Int16
    {
        let newValue: Int16 = Int16(value)
        
        return newValue
    }
    
    func intToFloat(value: Int16) -> Float
    {
        return Float(value)
    }
}
