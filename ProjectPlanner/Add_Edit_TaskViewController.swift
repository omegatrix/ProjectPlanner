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
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var txtField_name: UITextField!
    @IBOutlet weak var txtView_note: UITextView!
    @IBOutlet weak var switch_reminder: UISwitch!
    @IBOutlet weak var slider_progress: UISlider!
    @IBOutlet weak var label_taskProgress: UILabel!
    @IBOutlet weak var datePicker_startDate: UIDatePicker!
    @IBOutlet weak var datePicker_dueDate: UIDatePicker!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //delegate
        txtView_note.delegate = self
        
        //Adds border outline for the UITetView
        self.txtView_note.layer.borderColor = UIColor.lightGray.cgColor
        self.txtView_note.layer.borderWidth = 1
        
        if task != nil
        {
            txtField_name.text = task?.name
            txtView_note.text = task?.notes
            switch_reminder.isOn = helper.unwrapBoolean(optionalBool: task?.remindWhenDatePassed)
            slider_progress.value = helper.intToFloat(value: helper.unwrapInt(optionalInt: task?.progress))
            datePicker_startDate.date = helper.unwrapDate(optionalDate: task?.startDate)
            datePicker_dueDate.date = helper.unwrapDate(optionalDate: task?.dueDate)
            label_taskProgress.text = "Progress - \(helper.unwrapInt(optionalInt: task?.progress)) %"
        }
        
        else
        {
            //Assign a placeholder for the UITextView
            resetTextView()
            
            slider_progress.value = 0
            label_taskProgress.text = "Progress - 0 %"
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
    
    @IBAction func saveTask(_ sender: UIButton)
    {
        let isTaskNameEmpty = helper.unwrapBoolean(optionalBool: txtField_name.text?.isEmpty)
        
        if isTaskNameEmpty
        {
            let alertController = UIAlertController(title: "Alert", message: "Task name is mandatory!", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default)
            {
                (action:UIAlertAction) in
            }
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        else
        {
            if currentProject != nil
            {
                let task = Task(context: context)
                task.name = txtField_name.text
                task.notes = txtView_note.text
                
                
                currentProject?.addToTasks(task)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
        }
        
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
