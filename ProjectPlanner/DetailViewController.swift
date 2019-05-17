//
//  DetailViewController.swift
//  ProjectPlanner
//
//  Created by user153198 on 4/26/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate
{
    
    let helper = Helper()
    let notificationHelper = NotificationHelper()
    @IBOutlet weak var tableView: UITableView!
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchRequest: NSFetchRequest<Task>!
    var tasks: [Task]!
    var selectedProject: Project?
    var currentTask: Task? = nil
    var currentCell: TaskTableViewCell? = nil
    var projectSummary: ProjectSummaryViewController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
 
        print("hits viewDidLoad in detail\n")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        print("This is the ID -> \(selectedProject?.id)")
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        print("hits shouldPerformSegue in detail\n")
        if(identifier == "editTaskSegue")
        {
            if(currentTask == nil)
            {
                let alertController = UIAlertController(title: "Alert", message: "Please select a task to proceed!", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default)
                {
                    (action:UIAlertAction) in
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return false
            }
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("hits prepare in detail\n")
        if segue.identifier == "projectSummary"
        {
            if let projectSummary = segue.destination as? ProjectSummaryViewController
            {
                projectSummary.project = selectedProject
                self.projectSummary = projectSummary
            }
        }
        
        if segue.identifier == "addTaskSegue"
        {
            if let addTask = segue.destination as? Add_Edit_TaskViewController
            {
                addTask.currentProject = selectedProject
                addTask.projectSummary = self.projectSummary
            }
        }
        
        if segue.identifier == "editTaskSegue"
        {
            if let editTask = segue.destination as? Add_Edit_TaskViewController
            {
                editTask.currentProject = selectedProject
                editTask.task = currentTask
                editTask.projectSummary = self.projectSummary
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("hits didSelectRowAt in detail\n")
        let task = self.fetchedResultsController.object(at: indexPath)
        let cell: TaskTableViewCell = tableView.cellForRow(at: indexPath)! as! TaskTableViewCell
        
        if(task != nil)
        {
            self.currentTask = task
            print("selected taskname \(currentTask?.name)")
        }
        
        if(cell != nil)
        {
            self.currentCell = cell
            print("selected cell \(currentCell?.label_title.text)")
        }
        
        print("task name \(task.name) notification id\(task.notificationId)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        print("hits numberOfSections in detail\n")
        return self.fetchedResultsController.sections?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("hits numberOfRowsInSection in detail\n")
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        print("hits editingStyle in detail\n")
        if editingStyle == .delete
        {
            let context = self.fetchedResultsController.managedObjectContext
            let taskToDelete = self.fetchedResultsController.object(at: indexPath)
            let notificationId = helper.unwrapString(optionalString: taskToDelete.notificationId)
            context.delete(taskToDelete)

            do
            {
                if(!notificationId.isEmpty)
                {
                    let notificationIds = [notificationId]
                    notificationHelper.cancelNotification(notificationIds: notificationIds)
                }
                
                try context.save()
            }

            catch
            {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
            
            self.projectSummary?.refreshProjectProgress()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return true
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print("hits cellForRowAt in detail\n")
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        let task = self.fetchedResultsController.object(at: indexPath)
        
        self.currentCell = cell
        self.currentTask = task
        
        self.configureCell()
        
        return cell
    }
    
    func configureCell()
    {
        let currentCell = self.currentCell
        let task = self.currentTask
        currentCell?.task = task
        let note = helper.unwrapBoolean(optionalBool: task!.notes?.isEmpty) ? "No notes available" : helper.unwrapString(optionalString: task?.notes)
        currentCell?.label_title.text = "\(helper.unwrapString(optionalString: task?.name)) - Due on \(helper.dateToString(date: helper.unwrapDate(optionalDate: task?.dueDate)))"
        currentCell?.label_startDate.text = "Start date - \(helper.dateToString(date: helper.unwrapDate(optionalDate: task?.startDate)))"
        currentCell?.label_reminder.text = "Notify when due date is passed - \(task?.remindWhenDatePassed == true ? "Yes" : "No")"
        currentCell?.txtView_notes.text = note
        currentCell?.txtView_notes.layer.borderColor = UIColor.lightGray.cgColor
        currentCell?.txtView_notes.layer.borderWidth = 1
        currentCell?.txtView_notes.isEditable = false
        currentCell?.progressBar_task.labelSize = 18
        currentCell?.progressBar_task.setProgress(to: Double(helper.unwrapInt16(optionalInt: task?.progress)), withAnimation: true)
        currentCell?.progressBar_task.lineWidth = 18
        
    }
    
    //MARK: - fetch results controller
    
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    
    var fetchedResultsController: NSFetchedResultsController<Task>
    {
        print("hits fetchedResultsController in detail\n")
        
        if _fetchedResultsController != nil
        {
            return _fetchedResultsController!
        }
        
        
        let currentProject  = self.selectedProject
        let request:NSFetchRequest<Task> = Task.fetchRequest()
        //simpler version for just getting the albums
        //   let albums:NSSet = (currentArtist?.albums)!
        
        request.fetchBatchSize = 20
        //sort alphabetically
        let taskDueDateDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        
        //simpler version
        //   albums.sortedArray(using: [albumNameSortDescriptor])
        
        
        request.sortDescriptors = [taskDueDateDescriptor]
        //we want the albums for the recordArtist - via the relationship
        if(self.selectedProject != nil)
        {
            let predicate = NSPredicate(format: "project_tasks = %@", currentProject!)
            request.predicate = predicate
        }
            
//        else
//        {
//            //just do all albums for the first artist in the list
//            //replace this to get the first artist in the record
//            let predicate = NSPredicate(format: "artist = %@","Pink Floyd")
//            request.predicate = predicate
//        }
        
        let frc = NSFetchedResultsController<Task>(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: #keyPath(Task.project_tasks),
            cacheName:nil)
        frc.delegate = self
        _fetchedResultsController = frc
        
        do
        {
            //    try frc.performFetch()
            try _fetchedResultsController!.performFetch()
        }
        
        catch
        {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        
        return frc as! NSFetchedResultsController<NSFetchRequestResult> as! NSFetchedResultsController<Task>
    }//end var
    
    //MARK: - fetch results table view functions
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    {
        print("hits didChange in detail\n")
        switch type
        {
            case .insert:
                self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }
    //must have a NSFetchedResultsController to work
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        print("hits didChange in detail\n ")
        switch type
        {
            case NSFetchedResultsChangeType(rawValue: 0)!:
                // iOS 8 bug - Do nothing if we get an invalid change type.
                break
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                self.configureCell()
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            case .move:
                self.configureCell()
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
                //    default: break
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        print("hits controllerDidChangeContent in detail\n")
        self.tableView.endUpdates()
        // self.tableView.reloadData()
    }
}

