//
//  AddProjectViewController.swift
//  ProjectPlanner
//
//  Created by user153198 on 4/27/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

import UIKit
import CoreData

class AddProjectViewController: UIViewController
{

    @IBOutlet weak var txtField_name: UITextField!
    @IBOutlet weak var txtView_note: UITextView!
    @IBOutlet weak var segment_priority: UISegmentedControl!
    @IBOutlet weak var datePicker_dueDate: UIDatePicker!
    @IBOutlet weak var switch_addToCalendar: UISwitch!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.txtView_note.layer.borderColor = UIColor.lightGray.cgColor
        self.txtView_note.layer.borderWidth = 1

    }
    
    
    @IBAction func addProject(_ sender: UIButton)
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
            var priority = "High"
            
            if(segment_priority.selectedSegmentIndex == 1)
            {
                priority = "Medium"
            }
                
            else if(segment_priority.selectedSegmentIndex == 2)
            {
                priority = "Low"
            }
            
            //        let dateFormatter = DateFormatter()
            //        dateFormatter.dateFormat = "dd/MM/yyyy"
            //        let pickedDate = dateFormatter.string(from: datePicker_dueDate.date)
            
            let newProject = Project(context: context)
            newProject.name = txtField_name.text
            newProject.notes = txtView_note.text
            newProject.priority = priority
            newProject.dueDate = datePicker_dueDate.date
            newProject.addToCalendar = isAddToCalendar
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelView(_ sender: UIButton)
    {
        dismiss(animated: true, completion: nil)
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
