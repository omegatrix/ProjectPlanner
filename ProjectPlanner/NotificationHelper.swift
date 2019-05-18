//
//  NotificationHelper.swift
//  ProjectPlanner
//
//  Created by user153198 on 5/14/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

/*
 Local notifications are handled by this struct
*/

import UIKit
import UserNotifications

struct NotificationHelper
{
    let center = UNUserNotificationCenter.current()
    let helper = Helper()
    
    func checkNotificationPermission() -> Bool
    {
        print("checking notification permission\n")
        var permission: Bool = false
        center.getNotificationSettings
            {
                (settings) in
            
                switch settings.authorizationStatus
                {
                    case .authorized:
                        permission = true
                        print("notification permission granted\n")
                    break
                    
                    case .denied:
                        print("Notification permission denied!\n")
                    break
                    
                    case .notDetermined:
                        print("notification permission not determined\n")
                        permission = self.askNotificationPermission()
                    break
                    
                    case .provisional:
                        permission = true
                        print("notification permission provisional\n")
                    break
                    
                    default:
                        print("default case\n")
                }
            }
        
        return permission
    }
    
    func askNotificationPermission() -> Bool
    {
        print("asking notification\n")
        var isPermissionGranted: Bool = false
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        {
            (granted, error) in
            if(granted)
            {
                print("permission granted\n")
                isPermissionGranted = true
            }
        }
        
        return isPermissionGranted
    }
    
    /*
     The following function is adopted from the tutorial https://www.hackingwithswift.com/read/21/2/scheduling-notifications-unusernotificationcenter-and-unnotificationrequest
    */
    func prepareNotificationRequest(taskToNotify: Task, projectName: String) -> UNNotificationRequest
    {
        let notificationContent = UNMutableNotificationContent()
        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone(identifier: "GMT")
        let notificationIdentifier = UUID.init()
        let taskName = helper.unwrapString(optionalString: taskToNotify.name)
        let taskDueDate = helper.unwrapDate(optionalDate: taskToNotify.dueDate)
        let literalTaskDueDate = helper.dateToString(date: taskDueDate)
        let contentBody = "Task \(taskName) belonging to Project \(projectName) just passed its due date \(literalTaskDueDate)!"
        
        //set notification content
        notificationContent.title = "Task due date elapsed!"
        notificationContent.body = contentBody
        notificationContent.categoryIdentifier = "TASK_DUE_DATE_ELAPSED"
        notificationContent.sound = UNNotificationSound.default
        
        //notify right at the end of the task due date
        dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: taskDueDate)
        dateComponents.hour = 23
        dateComponents.minute = 59
        dateComponents.second = 59
        
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let notificationRequest = UNNotificationRequest(identifier: notificationIdentifier.uuidString, content: notificationContent, trigger: notificationTrigger)
        
        print("notification prepared \(notificationIdentifier)")
        
        return notificationRequest
    }
    
    func scheduleNotification(notificationRequest: UNNotificationRequest) -> Bool
    {
        var isSuccess: Bool = true
        
        center.add(notificationRequest, withCompletionHandler:
            {
                error in
                if let error = error
                {
                    isSuccess = false
                }
                
                print("notification scheduled\n")
            }
        )
        
        print("scheduling success? \(isSuccess)\n")
        return isSuccess
    }
    
    func cancelNotification(notificationIds: [String])
    {
        center.removePendingNotificationRequests(withIdentifiers: notificationIds)
        print("notifications cancelled \(notificationIds.first)\n")
    }

}


