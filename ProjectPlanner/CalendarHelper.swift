//
//  CalendarHelper.swift
//  ProjectPlanner
//
//  Created by user153198 on 5/11/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

import UIKit
import EventKit

struct CalendarHelper
{
    let eventStore = EKEventStore()
    let helper = Helper()

    func checkCalendarPermission() -> Bool
    {
        print("checking permission \n")
        
        var status = false
        
        switch EKEventStore.authorizationStatus(for: .event)
        {
            case .authorized:
                status = true
                print(" permission granted!")
            break
            
            case .notDetermined:
                print(" permission not determined!")
                status = self.askCalendarPermission()
                print(" permission not determined ? \(status)")
            break
            
            case .denied:
                print(" permission denied!")
            break
            
            case .restricted:
                print(" permission restricted!")
            break
            
            default:
                print("Default case!")
        }
        
        return status
    }
    
    func askCalendarPermission() -> Bool
    {
        print("asking permission for the first time!")
        var isPermissionGranted = false
        eventStore.requestAccess(to: .event, completion:
            {
                (granted: Bool, error: Error?) -> Void in
                if granted
                {
                    isPermissionGranted = true
                    print("permission granted? \(isPermissionGranted)")
                }
        }
        )
        
        return isPermissionGranted
    }
    
    /*
     The following function is adopted from https://www.ioscreator.com/tutorials/add-event-calendar-ios-tutorial
     */
    func addCalendarEvent(currentProject: Project) -> String
    {
        print("add project to calendar \n")
        let event = EKEvent(eventStore: eventStore)
        
        let calendars = eventStore.calendars(for: .event)
        var isCalendarExist = false
        var projectCalendar: EKCalendar? = nil
        var calendarEventId = ""
        
        for cal in calendars
        {
            if(cal.title == "Project Planner")
            {
                isCalendarExist = true
                projectCalendar = cal
                print("calendar found \(cal.title)\n")
            }
        }
        
        if(!isCalendarExist)
        {
            projectCalendar = createProjectCalendar()
            print("calendar created \(projectCalendar?.title) \n")
        }
        
        event.calendar = projectCalendar
        event.title = currentProject.name
        event.startDate = currentProject.dueDate
        event.endDate = currentProject.dueDate
        event.isAllDay = true
        event.notes = currentProject.notes
        
        print("start date \(currentProject.dueDate) \n")
        
        do
        {
            try eventStore.save(event, span: .thisEvent, commit: true)
        }
            
        catch
        {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        calendarEventId = helper.unwrapString(optionalString: event.eventIdentifier)
        
        print("eventIdentifier \(calendarEventId)")
        return calendarEventId
    }
    
    /*
     The following function is adopted from https://www.andrewcbancroft.com/2015/06/17/creating-calendars-with-event-kit-and-swift/
     */
    func createProjectCalendar() -> EKCalendar
    {
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        
        newCalendar.title = "Project Planner"
        
        let sourcesInEventStore = eventStore.sources
        
        newCalendar.source = sourcesInEventStore.filter
            {
                (source: EKSource) -> Bool in source.sourceType.rawValue == EKSourceType.local.rawValue
            }.first!
        
        do
        {
            try eventStore.saveCalendar(newCalendar, commit: true)
            print("Project Planner calendar created!")
        }
            
        catch
        {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return newCalendar
    }
    
    func updateCalendarEvent(projectToUpdate: Project)
    {
        let calendarEventId = helper.unwrapString(optionalString: projectToUpdate.calendarEventId)
        
        print("\(calendarEventId) in updatecalendar")
        if(calendarEventId.isEmpty)
        {
            return
        }
        
        if let updateCalendarEvent = eventStore.event(withIdentifier: calendarEventId)
        {
            print("name to be updated\(projectToUpdate.name) \nnotes to be updated \(projectToUpdate.notes)")
            updateCalendarEvent.title = projectToUpdate.name
            updateCalendarEvent.startDate = projectToUpdate.dueDate
            updateCalendarEvent.endDate = projectToUpdate.dueDate
            updateCalendarEvent.notes = projectToUpdate.notes
            
            do
            {
                
                try eventStore.save(updateCalendarEvent, span: .thisEvent, commit: true)
                print("event updated!")
            }
                
            catch
            {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func deleteCalendarEvent(calendarEventId: String)
    {
        print("\(calendarEventId) in deletecalendar")
        if(calendarEventId.isEmpty)
        {
            return
        }
        
        if let calendarEventToDelete = eventStore.event(withIdentifier: calendarEventId)
        {
            do
            {
                try eventStore.remove(calendarEventToDelete, span: EKSpan.thisEvent, commit: true)
                print("event deleted!")
            }
            
            catch
            {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
