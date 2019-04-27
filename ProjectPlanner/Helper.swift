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
    
    /* Optional unwrap -> Date */
    func unwrapDate(optionalDate: Date?) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateToString(date: Date())
        var unWrappedDate: Date = dateFormatter.date(from: dateString) ?? Date()//default value to return
        
        if let optionalDate = optionalDate
        {
            unWrappedDate = optionalDate
        }
        
        print("Optional Bool unwraped -> \(unWrappedDate)")
        return unWrappedDate
    }
    
    func dateToString(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }

}
