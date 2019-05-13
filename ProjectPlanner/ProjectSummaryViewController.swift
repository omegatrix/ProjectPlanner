//
//  ProjectSummaryViewController.swift
//  ProjectPlanner
//
//  Created by user153198 on 4/28/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

import UIKit

class ProjectSummaryViewController: UIViewController
{
    let helper = Helper()
    var project: Project?
    
    @IBOutlet weak var progressBar_daysRemaining: CircularProgressBar!
    @IBOutlet weak var progressBar_percentage: CircularProgressBar!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var txtView_notes: UITextView!
    @IBOutlet weak var label_addedToCalendar: UILabel!
    @IBOutlet weak var btn_edit: UIButton!
    @IBOutlet weak var label_createdOn: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if(project != nil)
        {
            self.txtView_notes.layer.borderColor = UIColor.lightGray.cgColor
            self.txtView_notes.layer.borderWidth = 1
            self.txtView_notes.isEditable = false
            
            let projectName = helper.unwrapString(optionalString: project?.name)
            let notes = helper.unwrapBoolean(optionalBool: project?.notes?.isEmpty) ? "No notes available!" : helper.unwrapString(optionalString: project?.notes)
            let priorityLiteral = helper.priorityLiteral(segmentIndex: helper.unwrapInt16(optionalInt: project?.priority))
            let addedToCalendar = "Added to calendar: \(helper.unwrapBoolean(optionalBool: project?.addToCalendar) ? "Yes" : "No")"
            let today = Date.init()
            let dueDate = helper.unwrapDate(optionalDate: project?.dueDate)
            let projectCreatedOn = helper.unwrapDate(optionalDate: project?.createdOn)
            let projectPercentage = calculateProjectProgress()
            let daysRemain = calculateDaysRemain(from: today, to: dueDate)
            let totalProjectDays = calculateDaysRemain(from: projectCreatedOn, to: dueDate)
            let daysRemainPercentage = (daysRemain * 100) / totalProjectDays
            
            print("Total days \(totalProjectDays)")
            
            label_title.text = "\(projectName) - Priority \(priorityLiteral) - Due on \(helper.dateToString(date: dueDate))"
            txtView_notes.text = notes
            label_addedToCalendar.text = addedToCalendar
            label_createdOn.text = "Created on - \(helper.dateToString(date: projectCreatedOn))"
            
            progressBar_percentage.labelSize = 20
            progressBar_percentage.setProgress(to: Double(projectPercentage), withAnimation: true)
            progressBar_percentage.lineWidth = 20
            
            progressBar_daysRemaining.labelSize = 20
            progressBar_daysRemaining.daysRemain = daysRemain
            progressBar_daysRemaining.setProgress(to: Double(daysRemainPercentage), withAnimation: true)
            progressBar_daysRemaining.lineWidth = 20
            
            btn_edit.isHidden = false
            
        }
        
        else
        {
            label_title.text = "Please select a project to continue!"
            txtView_notes.text = nil
            label_addedToCalendar.text = nil
            label_createdOn.text = nil
            progressBar_percentage.hideView()
            progressBar_daysRemaining.hideView()
            btn_edit.isHidden = true
        }
        
    }
    
    func calculateProjectProgress() -> Int
    {
        var projectCompletion = 0
        let tasks = project?.tasks?.allObjects as! [Task]
        
        print("tasks count \(tasks.count)")
        
        if(tasks.count == 0)
        {
            return 0
        }
        
        for eachTask in tasks
        {
            projectCompletion += Int(eachTask.progress)
        }
        
        print("projectCompletion \(projectCompletion)")
        
        let percentage = (projectCompletion > 0) ? (projectCompletion / tasks.count) : projectCompletion
        
        print("Percentage \(percentage)")
        
        return percentage
    }
    
    func calculateDaysRemain(from: Date, to: Date) -> Int
    {
        let daysRemain = Calendar.current.dateComponents([.day], from: from, to: to).day ?? 0
        
        print("today \(from)")
        print("due date \(to)")
        print("days remaining \(daysRemain)")
        return daysRemain
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "editProject"
        {
            if(project == nil)
            {
                let alertController = UIAlertController(title: "Alert", message: "Please select a project to proceed!", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default)
                {
                    (action:UIAlertAction) in
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
            else
            {
                if let add_edit = segue.destination as? Add_Edit_ProjectViewController
                {
                    add_edit.project = project
                }
            }
        }
    }
}
