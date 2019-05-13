//
//  ProjectSummaryViewController.swift
//  ProjectPlanner
//
//  Created by user153198 on 4/28/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

import UIKit
import CoreData

class ProjectSummaryViewController: UIViewController
{
    let helper = Helper()
    var project: Project? = nil
    var projectTasks: [Task]? = nil
    
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
        
        if let project = self.project
        {
            setupView(currentProject: project)
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
    
    func setupView(currentProject: Project)
    {
        print("hits setup")
        project = currentProject
        
        self.txtView_notes.layer.borderColor = UIColor.lightGray.cgColor
        self.txtView_notes.layer.borderWidth = 1
        self.txtView_notes.isEditable = false
        
        let projectName = helper.unwrapString(optionalString: currentProject.name)
        let notes = helper.unwrapBoolean(optionalBool: currentProject.notes?.isEmpty) ? "No notes available!" : helper.unwrapString(optionalString: currentProject.notes)
        let priorityLiteral = helper.priorityLiteral(segmentIndex: helper.unwrapInt16(optionalInt: currentProject.priority))
        let addedToCalendar = "Added to calendar: \(helper.unwrapBoolean(optionalBool: currentProject.addToCalendar) ? "Yes" : "No")"
        let today = Date.init()
        let dueDate = helper.unwrapDate(optionalDate: currentProject.dueDate)
        let projectCreatedOn = helper.unwrapDate(optionalDate: currentProject.createdOn)
        let projectPercentage = calculateProjectProgress()
        let daysRemain = calculateDaysRemain(from: today, to: dueDate)
        let totalProjectDays = calculateDaysRemain(from: projectCreatedOn, to: dueDate)
        let daysRemainPercentage = (daysRemain * 100) / totalProjectDays
        
        print("Total days \(totalProjectDays)")
        
        label_title.text = "\(projectName) - Priority \(priorityLiteral) - Due on \(helper.dateToString(date: dueDate))"
        txtView_notes.text = notes
        label_addedToCalendar.text = addedToCalendar
        label_createdOn.text = "Created on - \(helper.dateToString(date: projectCreatedOn))"
        
        setProgress(projectPercentage: Double(projectPercentage))
        setDaysRemain(daysRemain: daysRemain, daysRemainPercentage: Double(daysRemainPercentage))
        
        
    }
    
    func setProgress(projectPercentage: Double)
    {
        progressBar_percentage.labelSize = 20
        progressBar_percentage.setProgress(to: projectPercentage, withAnimation: true)
        progressBar_percentage.lineWidth = 20
    }
    
    func setDaysRemain(daysRemain: Int, daysRemainPercentage: Double)
    {
        progressBar_daysRemaining.labelSize = 20
        progressBar_daysRemaining.daysRemain = daysRemain
        progressBar_daysRemaining.setProgress(to: daysRemainPercentage, withAnimation: true)
        progressBar_daysRemaining.lineWidth = 20
    }
    
    func refreshProjectProgress()
    {
        let progress = calculateProjectProgress()
        
        setProgress(projectPercentage: Double(progress))
    }
    
    func calculateProjectProgress() -> Int
    {
        let projectTasks = project?.tasks?.allObjects as? [Task]
        var projectCompletion = 0
        
        print("tasks count \(projectTasks?.count)")
        
        if(projectTasks!.count > 0)
        {
            for eachTask in projectTasks!
            {
                projectCompletion += Int(eachTask.progress)
            }
            
            print("projectCompletion \(projectCompletion)")
            
            let percentage = (projectCompletion > 0) ? (projectCompletion / projectTasks!.count) : projectCompletion
            
            print("Percentage \(percentage)")
            
            return percentage
        }
        
        return 0
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
                    add_edit.projectSummary = self
                }
            }
        }
    }
}
