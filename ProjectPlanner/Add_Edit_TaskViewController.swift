//
//  Add_Edit_TaskViewController.swift
//  ProjectPlanner
//
//  Created by user153198 on 5/8/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

import UIKit
import CoreData

class Add_Edit_TaskViewController: UIViewController, UITextViewDelegate
{
    var task: Task?
    var currentProject: Project?
    let helper = Helper()
    let notificationHelper = NotificationHelper()
    var projectSummary: ProjectSummaryViewController? = nil
    var isPermissionGranted = false
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var txtField_name: UITextField!
    @IBOutlet weak var txtView_note: UITextView!
    @IBOutlet weak var switch_reminder: UISwitch!
    @IBOutlet weak var slider_progress: UISlider!
    @IBOutlet weak var label_taskProgress: UILabel!
    @IBOutlet weak var datePicker_startDate: UIDatePicker!
    @IBOutlet weak var datePicker_dueDate: UIDatePicker!
    @IBOutlet weak var btn_submit: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        isPermissionGranted = notificationHelper.checkNotificationPermission()
        print("isPermissionGranted ? \(isPermissionGranted)")

        //delegate
        txtView_note.delegate = self
        
        //Adds border outline for the UITetView
        self.txtView_note.layer.borderColor = UIColor.lightGray.cgColor
        self.txtView_note.layer.borderWidth = 1
        
        if task != nil
        {
            txtField_name.text = task?.name
            txtView_note.text = task?.notes
            txtView_note.textColor = UIColor.black
            switch_reminder.isOn = helper.unwrapBoolean(optionalBool: task?.remindWhenDatePassed)
            slider_progress.value = helper.intToFloat(value: helper.unwrapInt16(optionalInt: task?.progress))
            datePicker_startDate.date = helper.unwrapDate(optionalDate: task?.startDate)
            datePicker_dueDate.date = helper.unwrapDate(optionalDate: task?.dueDate)
            label_taskProgress.text = "Progress - \(helper.unwrapInt16(optionalInt: task?.progress)) %"
            btn_submit.setTitle("Update", for: .normal)
        }
        
        else
        {
            //Assign a placeholder for the UITextView
            resetTextView()
            
            slider_progress.value = 0
            label_taskProgress.text = "Progress - 0 %"
            btn_submit.setTitle("Save", for: .normal)
        }

    }
    
    func resetTextView()
    {
        self.txtView_note.text = "Please enter any notes here..."
        self.txtView_note.textColor = UIColor.lightGray
    }
    
    /*
     The following two methods: textViewDidBeginEditing and textViewDidEndEditing are adapted from the StackOverflow thread https://stackoverflow.com/questions/27652227/text-view-uitextview-placeholder-swift
     */
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if(textView.textColor == UIColor.lightGray)
        {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        let isTextViewEmpty = textView.text.isEmpty
        
        if(isTextViewEmpty)
        {
            resetTextView()
        }
    }
    
    @IBAction func onProgressChange(_ sender: UISlider)
    {
        label_taskProgress.text = "Progress - \(Int(sender.value)) %"
    }
    
    
    @IBAction func closeView(_ sender: UIButton)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onButtonPress(_ sender: UIButton)
    {
        let isTaskNameEmpty = helper.unwrapBoolean(optionalBool: txtField_name.text?.isEmpty)
        let today = helper.unwrapDate(optionalDate: Date.init())
        let dueDate = helper.unwrapDate(optionalDate: datePicker_dueDate.date)
        let startDate = helper.unwrapDate(optionalDate: datePicker_startDate.date)
        let projectDueDate = helper.unwrapDate(optionalDate: currentProject?.dueDate)
        let projectCreatedOn = helper.unwrapDate(optionalDate: currentProject?.createdOn)
        let isNotify = helper.unwrapBoolean(optionalBool: switch_reminder.isOn)
        //let isPermissionGranted = notificationHelper.checkNotificationPermission()
        print("permission to send notification granted ? \(isPermissionGranted)")
        
        if isTaskNameEmpty
        {
            let alertController = UIAlertController(title: "Alert", message: "Task name is mandatory!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            {
                (action:UIAlertAction) in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
            
        if(dueDate < today || startDate > dueDate)
        {
            let errorMessage = dueDate < today ? "Due date cannot be in the past!" : "Start date cannot occur after due date!"
            let alertController = UIAlertController(title: "Alert", message: errorMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            {
                (action:UIAlertAction) in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
            
        if(dueDate > projectDueDate || startDate < projectCreatedOn)
        {
            let errorMessage = dueDate > projectDueDate ? "Task due date cannot occur after Project due date!" : "Task start date cannot be prior to project created date!"
            let alertController = UIAlertController(title: "Alert", message: errorMessage, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            {
                (action:UIAlertAction) in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
//        if(isNotify && !isPermissionGranted)
//        {
//            let errorMessage = "Please grant permission to send notifications in settings!"
//            let alertController = UIAlertController(title: "Alert", message: errorMessage, preferredStyle: .alert)
//            
//            let okAction = UIAlertAction(title: "OK", style: .default)
//            {
//                (action:UIAlertAction) in
//            }
//
//            alertController.addAction(okAction)
//            self.present(alertController, animated: true, completion: nil)
//            return
//        }
        
        if(task != nil)
        {
            updateTask()
        }
        
        else
        {
            saveTask(currentProject: self.currentProject!)
        }
        
        
    }
    
    func saveTask(currentProject: Project)
    {
        if currentProject != nil
        {
            let dueDate = helper.unwrapDate(optionalDate: datePicker_dueDate.date)
            let startDate = helper.unwrapDate(optionalDate: datePicker_startDate.date)
            let isNotify = switch_reminder.isOn
            let projectName = helper.unwrapString(optionalString: currentProject.name)
            var notificationId = ""
            
            let newTask = Task(context: context)
            newTask.id = UUID.init()
            newTask.name = txtField_name.text
            newTask.notes = (txtView_note.textColor == UIColor.lightGray) ? "" : txtView_note.text
            newTask.dueDate = dueDate
            newTask.startDate = startDate
            newTask.progress = Int16(slider_progress.value)
            newTask.remindWhenDatePassed = isNotify
            
            if(isNotify)
            {
                let request = notificationHelper.prepareNotificationRequest(taskToNotify: newTask, projectName: projectName)
                let isScheduleSuccess = notificationHelper.scheduleNotification(notificationRequest: request)
                
                if(isScheduleSuccess)
                {
                    notificationId = request.identifier
                }
            }
            
            newTask.notificationId = notificationId
            currentProject.addToTasks(newTask)
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    func updateTask()
    {
        let newName = txtField_name.text
        let newNotes = (txtView_note.textColor == UIColor.lightGray) ? "" : txtView_note.text
        let newDueDate = helper.unwrapDate(optionalDate: datePicker_dueDate.date)
        let newStartDate = helper.unwrapDate(optionalDate: datePicker_startDate.date)
        let newProgress = Int16(slider_progress.value)
        let newNotify = switch_reminder.isOn
        let projectName = helper.unwrapString(optionalString: currentProject?.name)
        var newNotificationId = ""
        
        let oldName = helper.unwrapString(optionalString: task?.name)
        let oldNotes = helper.unwrapString(optionalString: task?.notes)
        let oldDueDate = helper.unwrapDate(optionalDate: task?.dueDate)
        let oldStartDate = helper.unwrapDate(optionalDate: task?.startDate)
        let oldProgress = helper.unwrapInt16(optionalInt: task?.progress)
        let oldNotify = helper.unwrapBoolean(optionalBool: task?.remindWhenDatePassed)
        let oldNotificationId = helper.unwrapString(optionalString: task?.notificationId)
        
        if(newName == oldName
            && newNotes == oldNotes
            && newDueDate == oldDueDate
            && newStartDate == oldStartDate
            && newProgress == oldProgress
            && newNotify == oldNotify)
        {
            let alertController = UIAlertController(title: "Alert", message: "No changes made!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {action in
                self.dismiss(animated: true, completion: nil)
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchedRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Task")
        
        if let id = task?.id
        {
            fetchedRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do
            {
                let fetchedObject = try managedContext.fetch(fetchedRequest)
                
                let objectToUpdate = fetchedObject.first as! NSManagedObject
                objectToUpdate.setValue(newName, forKey: "name")
                objectToUpdate.setValue(newNotes, forKey: "notes")
                objectToUpdate.setValue(newStartDate, forKey: "startDate")
                objectToUpdate.setValue(newDueDate, forKey: "dueDate")
                objectToUpdate.setValue(newProgress, forKey: "progress")
                objectToUpdate.setValue(newNotify, forKey: "remindWhenDatePassed")
                
                if(oldNotify && newNotify) //notification needs to be updated (cancelled and new one sceduled)
                {
                    let notificationIds = [oldNotificationId]
                    notificationHelper.cancelNotification(notificationIds: notificationIds) // cancel the existing notification
                    
                    let request = notificationHelper.prepareNotificationRequest(taskToNotify: objectToUpdate as! Task, projectName: projectName)
                    let isScheduleSuccess = notificationHelper.scheduleNotification(notificationRequest: request) //schedule a new one
                    
                    if(isScheduleSuccess)
                    {
                        newNotificationId = request.identifier
                    }
                }
                
                if(!oldNotify && newNotify) //A new notification needs to be scheduled
                {
                    let request = notificationHelper.prepareNotificationRequest(taskToNotify: objectToUpdate as! Task, projectName: projectName)
                    let isScheduleSuccess = notificationHelper.scheduleNotification(notificationRequest: request) //add a new one
                    
                    if(isScheduleSuccess)
                    {
                        newNotificationId = request.identifier
                    }
                }
                
                if(oldNotify && !newNotify) //notification needs to be cancelled
                {
                    let notificationIds = [oldNotificationId]
                    notificationHelper.cancelNotification(notificationIds: notificationIds)
                }
                
                objectToUpdate.setValue(newNotificationId, forKey: "notificationId")
                
                do
                {
                    try managedContext.save()
                    projectSummary?.refreshProjectProgress()
                }
                    
                catch
                {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
                
            catch
            {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}
