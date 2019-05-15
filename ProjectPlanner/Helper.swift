//
//  Helper.swift
//  ProjectPlanner
//
//  Created by user153198 on 4/27/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//


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
        
        print("Optional String unwraped -> \(unWrappedString)")
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
        
        print("Optional Bool unwraped -> \(unWrappedBool)")
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
        
        print("Optional Bool unwraped -> \(unWrappedDouble)")
        return unWrappedDouble
    }
    
    /* Optional unwrap -> Int */
    func unwrapInt16(optionalInt: Int16?) -> Int16
    {
        var unWrappedInt: Int16 = 0 //default value to return
        
        if let optionalInt = optionalInt
        {
            unWrappedInt = optionalInt
        }
        
        print("Optional Bool unwraped -> \(optionalInt)")
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
        
        print("Optional Date unwraped -> \(unWrappedDate)")
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
    
    func priorityLiteral(segmentIndex: Int16) -> String
    {
        return
            segmentIndex == 0
            ?
            "High"
            :
            (
                segmentIndex == 1
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
