//
//  AddProjectViewController.swift
//  ProjectPlanner
//
//  Created by user153198 on 4/27/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class Add_Edit_ProjectViewController: UIViewController, UITextViewDelegate
{
    var project: Project?
    var isCalendarPermissionGranted = false
    var projectSummary: ProjectSummaryViewController? = nil
    
    @IBOutlet weak var txtField_name: UITextField!
    @IBOutlet weak var txtView_note: UITextView!
    @IBOutlet weak var segment_priority: UISegmentedControl!
    @IBOutlet weak var datePicker_dueDate: UIDatePicker!
    @IBOutlet weak var switch_addToCalendar: UISwitch!
    @IBOutlet weak var btn_submit: UIButton!
    
    let helper = Helper()
    let calendarHelper = CalendarHelper()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        calendarHelper.checkCalendarPermission()
        
        print("permission granted in project view controller \(isCalendarPermissionGranted)")
        
        //delegate
        txtView_note.delegate = self
        
        //Adds border outline for the UITetView
        self.txtView_note.layer.borderColor = UIColor.lightGray.cgColor
        self.txtView_note.layer.borderWidth = 1
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateselected = dateFormatter.string(from: datePicker_dueDate.date)
        let newDate = dateFormatter.date(from: dateselected)
        print("add project date string\(dateselected)")
        print("add project date \(newDate)")
    
        
        if project != nil
        {
            txtField_name.text = project?.name
            txtView_note.text = project?.notes
            txtView_note.textColor = UIColor.black
            segment_priority.selectedSegmentIndex = helper.int16_To_Int(value: helper.unwrapInt16(optionalInt: project?.priority))
            datePicker_dueDate.date = helper.unwrapDate(optionalDate: project?.dueDate)
            switch_addToCalendar.isOn = helper.unwrapBoolean(optionalBool: project?.addToCalendar)
            btn_submit.setTitle("Update", for: .normal)
            
            print("edit project, event id \(project?.calendarEventId)")
        }
        
        else
        {
            //Assign a placeholder for the UITextView
            resetTextView()
            btn_submit.setTitle("Save", for: .normal)
        }
    }
    
    
    /*
        The following two methods: textViewDidBeginEditing and textViewDidEndEditing are adopted from the StackOverflow thread https://stackoverflow.com/questions/27652227/text-view-uitextview-placeholder-swift
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
    
    
    @IBAction func onButtonPress(_ sender: UIButton)
    {
        let isProjectNameEmpty = helper.unwrapBoolean(optionalBool: txtField_name.text?.isEmpty)
        let isAddToCalendar = switch_addToCalendar.isOn
        let today = helper.unwrapDate(optionalDate: Date.init())
        let formattedDate = helper.unwrapDate(optionalDate: datePicker_dueDate.date)
        let calendarPermissionGranted = calendarHelper.checkCalendarPermission()
        var calendarEventId = ""

        if(isProjectNameEmpty)
        {
            let alertController = UIAlertController(title: "Alert", message: "Project name is mandatory!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            {
                (action:UIAlertAction) in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
            
        if(formattedDate < today)
        {
            let alertController = UIAlertController(title: "Alert", message: "Due date cannot be in the past!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            {
                (action:UIAlertAction) in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        if(isAddToCalendar && !calendarPermissionGranted)
        {
//            let alertController = UIAlertController(title: "Alert", message: "Please grant calendar permission in settings", preferredStyle: .alert)
//            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
//                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
//                    return
//                }
//                if UIApplication.shared.canOpenURL(settingsUrl) {
//                    UIApplication.shared.open(settingsUrl, completionHandler: {(success) in self.isCalendarPermissionGranted = success})
//                }
//            }
//            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
//            alertController.addAction(cancelAction)
//            alertController.addAction(settingsAction)
//            self.present(alertController, animated: true, completion: nil)

            let alertController = UIAlertController(title: "Alert", message: "Please grant calendar permission in settings to proceed!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            {
                (action:UIAlertAction) in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        if(project != nil)
        {
            updateProject(project: project!)
        }
            
        else
        {
            saveProject()
        }
    }
    
    func saveProject()
    {
        let priority = helper.int_To_int16(value: segment_priority.selectedSegmentIndex)
        let dueDate = helper.unwrapDate(optionalDate: datePicker_dueDate.date)
        let addToCalendar = helper.unwrapBoolean(optionalBool: switch_addToCalendar.isOn)
        let createdOn = helper.unwrapDate(optionalDate: Date.init())
        var calendarEventId = ""
        
        let newProject = Project(context: context)
        newProject.id = UUID.init()
        newProject.createdOn = createdOn
        newProject.name = txtField_name.text
        newProject.notes = (txtView_note.textColor == UIColor.lightGray) ? "" : txtView_note.text
        newProject.priority = priority
        newProject.dueDate = dueDate
        newProject.addToCalendar = addToCalendar
        
        if(addToCalendar)
        {
            calendarEventId = calendarHelper.addCalendarEvent(currentProject: newProject)
            print("event id in project controller \(calendarEventId)" )
                
            if(calendarEventId.isEmpty)
            {
                let alertController = UIAlertController(title: "Alert", message: "An error occurred while adding project to calendar!", preferredStyle: .alert)
                    
                let okAction = UIAlertAction(title: "OK", style: .default)
                {
                        (action:UIAlertAction) in
                }
                    
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
        
        newProject.calendarEventId = calendarEventId
        (UIApplication.shared.delegate as! AppDelegate).saveContext()

        dismiss(animated: true, completion: nil)
    }
    
    func updateProject(project: Project)
    {
        let newName = txtField_name.text
        let newNotes = txtView_note.text
        let newDueDate = helper.unwrapDate(optionalDate: datePicker_dueDate.date)
        let newPriority = helper.int_To_int16(value: segment_priority.selectedSegmentIndex)
        let newAddToCalendar = helper.unwrapBoolean(optionalBool: switch_addToCalendar.isOn)
        var calendarEventId = ""
        var taskDueDateInFuture = false
        let tasks = project.tasks?.allObjects as! [Task]
        
        let oldName = project.name
        let oldNotes = project.notes
        let oldDueDate = project.dueDate
        let oldPriority = project.priority
        let oldAddToCalendar = project.addToCalendar
        let oldEventIdentifier = project.calendarEventId
        
        print("old calendar id \(oldEventIdentifier)")
        
        if(newName == oldName
            && newNotes == oldNotes
            && newDueDate == oldDueDate
            && newPriority == oldPriority
            && newAddToCalendar == oldAddToCalendar)
        {
            let alertController = UIAlertController(title: "Alert", message: "No changes made!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {action in
                self.dismiss(animated: true, completion: nil)
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        for eachTask in tasks
        {
            print("task due date \(eachTask.dueDate)")
            if(helper.unwrapDate(optionalDate: eachTask.dueDate) > newDueDate)
            {
                let alertController = UIAlertController(title: "Alert", message: "One of the tasks' due date occurs after the picked due date!", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default)
                {
                    (action:UIAlertAction) in
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchedRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Project")
        
        if let id = project.id
        {
            fetchedRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            do
            {
                let fetchedObject = try managedContext.fetch(fetchedRequest)
                
                let objectToUpdate = fetchedObject.first as! NSManagedObject
                objectToUpdate.setValue(newName, forKey: "name")
                objectToUpdate.setValue(newNotes, forKey: "notes")
                objectToUpdate.setValue(newDueDate, forKey: "dueDate")
                objectToUpdate.setValue(newPriority, forKey: "priority")
                objectToUpdate.setValue(newAddToCalendar, forKey: "addToCalendar")
                
                if(oldAddToCalendar && newAddToCalendar) //the event needs to be updated in the calendar
                {
                    calendarHelper.updateCalendarEvent(projectToUpdate: objectToUpdate as! Project)
                    calendarEventId = helper.unwrapString(optionalString: oldEventIdentifier) //keep the same eventId
                }
                
                if(!oldAddToCalendar && newAddToCalendar) //a new event needs to be added to the calendar
                {
                    
                    calendarEventId = calendarHelper.addCalendarEvent(currentProject: objectToUpdate as! Project) //new eventId
                    print("event id in project controller \(calendarEventId)" )
                    
                    if(calendarEventId.isEmpty)
                    {
                        let alertController = UIAlertController(title: "Alert", message: "An error occurred while adding project to calendar!", preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: .default)
                        {
                            (action:UIAlertAction) in
                        }
                        
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                }
                
                if(oldAddToCalendar && !newAddToCalendar) //event needs to be deleted from the calendar events
                {
                    if let oldEventIdentifier = oldEventIdentifier
                    {
                        calendarHelper.deleteCalendarEvent(calendarEventId: oldEventIdentifier)
                    }
                }
                
                objectToUpdate.setValue(calendarEventId, forKey: "calendarEventId") //set the eventId to be updated
                
                do
                {
                    try managedContext.save()
                    projectSummary?.setupView(currentProject: objectToUpdate as! Project)
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
    
    @IBAction func cancelView(_ sender: UIButton)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func resetTextView()
    {
        self.txtView_note.text = "Please enter any notes here..."
        self.txtView_note.textColor = UIColor.lightGray
    }
}
