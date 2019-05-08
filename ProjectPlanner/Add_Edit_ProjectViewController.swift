//
//  AddProjectViewController.swift
//  ProjectPlanner
//
//  Created by user153198 on 4/27/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

import UIKit
import CoreData

class Add_Edit_ProjectViewController: UIViewController, UITextViewDelegate
{
    var project: Project?
//    var projectName: String = ""
//    var projectNote: String = ""
//    var projectPriority: String = ""
//    var projectDueDate: Date = Date()
//    var addToCalendar: Bool = true
//    var isUpdateProject: Bool = false

    @IBOutlet weak var txtField_name: UITextField!
    @IBOutlet weak var txtView_note: UITextView!
    @IBOutlet weak var segment_priority: UISegmentedControl!
    @IBOutlet weak var datePicker_dueDate: UIDatePicker!
    @IBOutlet weak var switch_addToCalendar: UISwitch!
    
    let helper = Helper()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //delegate
        txtView_note.delegate = self
        
        //Adds border outline for the UITetView
        self.txtView_note.layer.borderColor = UIColor.lightGray.cgColor
        self.txtView_note.layer.borderWidth = 1
        
        //Assign a placeholder for the UITextView
        resetTetView()
        
        if(project != nil)
        {
            txtField_name.text = project?.name
            txtView_note.text = project?.notes
            segment_priority.selectedSegmentIndex = helper.stringToSegmentIndex(priority: helper.unwrapString(optionalString: project?.priority))
            datePicker_dueDate.date = helper.unwrapDate(optionalDate: project?.dueDate)
            switch_addToCalendar.isOn = helper.unwrapBoolean(optionalBool: project?.addToCalendar)
        }
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
            resetTetView()
        }
    }
    
    @IBAction func onButtonPress(_ sender: UIButton)
    {
        let isProjectNameEmpty = txtField_name.text?.isEmpty ?? true
        let isAddToCalendar = switch_addToCalendar.isOn

        if(isProjectNameEmpty)
        {
            let alertController = UIAlertController(title: "Alert", message: "Project name is mandatory!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            {
                (action:UIAlertAction) in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        else
        {
 
            let priority = helper.segmentIndexToString(segmentIndex: segment_priority.selectedSegmentIndex)

            let formattedDate = helper.unwrapDate(optionalDate: datePicker_dueDate.date)
            
            if(project != nil)
            {
                let newName = txtField_name.text
                let newNotes = txtView_note.text
                let newDueDate = helper.unwrapDate(optionalDate: datePicker_dueDate.date)
                let newPriority = helper.segmentIndexToString(segmentIndex: segment_priority.selectedSegmentIndex)
                let newAddToCalendar = helper.unwrapBoolean(optionalBool: switch_addToCalendar.isOn)
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                
                let managedContext = appDelegate.persistentContainer.viewContext
                
                let fetchedRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Project")
                
                if let objectId = project?.objectID
                {
                    fetchedRequest.predicate = NSPredicate(format: "name == %@", helper.unwrapString(optionalString: project?.name))
                    
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
            
            else
            {
                let newProject = Project(context: context)
                newProject.name = txtField_name.text
                newProject.notes = (txtView_note.textColor == UIColor.lightGray) ? "" : txtView_note.text
                newProject.priority = priority
                newProject.dueDate = formattedDate
                newProject.addToCalendar = isAddToCalendar
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
            
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelView(_ sender: UIButton)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func resetTetView()
    {
        self.txtView_note.text = "Please enter any notes here..."
        self.txtView_note.textColor = UIColor.lightGray
    }
    
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
