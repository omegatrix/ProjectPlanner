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
    
    @IBOutlet weak var txtField_name: UITextField!
    @IBOutlet weak var txtView_note: UITextView!
    @IBOutlet weak var segment_priority: UISegmentedControl!
    @IBOutlet weak var datePicker_dueDate: UIDatePicker!
    @IBOutlet weak var switch_addToCalendar: UISwitch!
    @IBOutlet weak var btn_submit: UIButton!
    
    let helper = Helper()
    let eventStore = EKEventStore()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        isCalendarPermissionGranted = checkCalendarPermission()
        
        //delegate
        txtView_note.delegate = self
        
        //Adds border outline for the UITetView
        self.txtView_note.layer.borderColor = UIColor.lightGray.cgColor
        self.txtView_note.layer.borderWidth = 1
        
        if project != nil
        {
            txtField_name.text = project?.name
            txtView_note.text = project?.notes
            txtView_note.textColor = UIColor.black
            segment_priority.selectedSegmentIndex = helper.stringToSegmentIndex(priority: helper.unwrapString(optionalString: project?.priority))
            datePicker_dueDate.date = helper.unwrapDate(optionalDate: project?.dueDate)
            switch_addToCalendar.isOn = helper.unwrapBoolean(optionalBool: project?.addToCalendar)
            btn_submit.setTitle("Update", for: .normal)
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
        let isProjectNameEmpty = txtField_name.text?.isEmpty ?? true
        let isAddToCalendar = switch_addToCalendar.isOn
        let today = helper.unwrapDate(optionalDate: Date())
        let formattedDate = helper.unwrapDate(optionalDate: datePicker_dueDate.date)
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
        let priority = helper.segmentIndexToString(segmentIndex: segment_priority.selectedSegmentIndex)
        let dueDate = helper.unwrapDate(optionalDate: datePicker_dueDate.date)
        let addToCalendar = helper.unwrapBoolean(optionalBool: switch_addToCalendar.isOn)
        
        let newProject = Project(context: context)
        newProject.id = UUID.init()
        newProject.name = txtField_name.text
        newProject.notes = (txtView_note.textColor == UIColor.lightGray) ? "" : txtView_note.text
        newProject.priority = priority
        newProject.dueDate = dueDate
        newProject.addToCalendar = addToCalendar
        
        let calendarEventId = addToCalendar ? addCalendarEvent(currentProject: newProject) : ""
        newProject.calendarEventId = calendarEventId
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        dismiss(animated: true, completion: nil)
    }
    
    func updateProject(project: Project)
    {
        let newName = txtField_name.text
        let newNotes = txtView_note.text
        let newDueDate = helper.unwrapDate(optionalDate: datePicker_dueDate.date)
        let newPriority = helper.segmentIndexToString(segmentIndex: segment_priority.selectedSegmentIndex)
        let newAddToCalendar = helper.unwrapBoolean(optionalBool: switch_addToCalendar.isOn)
        
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
                
                do
                {
                    try managedContext.save()
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
    
    func checkCalendarPermission() -> Bool
    {
        print("checking permission \n")
        
        var status = false
        
        switch EKEventStore.authorizationStatus(for: .event)
        {
            case .authorized:
                status = true
            break
            
            case .notDetermined:
                status = askCalendarPermission()
            break
            
            default:
                print("Default case!")
        }
        
        return status
    }
    
    func askCalendarPermission() -> Bool
    {
        var isPermissionGranted = false
        eventStore.requestAccess(to: .event, completion:
            {
                (granted: Bool, error: Error?) -> Void in
                if granted
                {
                    isPermissionGranted = true
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
            try eventStore.save(event, span: .thisEvent)
        }
        
        catch
        {
            let alertController = UIAlertController(title: "Alert", message: "An error occurred while adding the project to the calendar!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            {
                (action:UIAlertAction) in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        print("eventIdentifier \(event.eventIdentifier)")
        return event.eventIdentifier
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
        }
        
        catch
        {
            let alertController = UIAlertController(title: "Alert", message: "An error occurred while creating the calendar!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            {
                (action:UIAlertAction) in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return newCalendar
    }
    
    func updateCalendarEvent()
    {
        //to do
    }
    
    func deleteCalendarEvent()
    {
        //to do
    }
}
