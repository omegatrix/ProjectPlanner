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
    @IBOutlet weak var tableView: UITableView!
    var managedObjectContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchRequest: NSFetchRequest<Task>!
    var tasks: [Task]!
    var project: Project?
    var currentTask: Task? = nil
    var projectSummary: ProjectSummaryViewController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
 
        self.tableView.delegate = self
        self.tableView.dataSource = self
        print("This is the ID -> \(project?.id)")
        
        if(project != nil)
        {
            tasks = project?.tasks?.allObjects as! [Task]
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
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
        
        if segue.identifier == "projectSummary"
        {
            if let projectSummary = segue.destination as? ProjectSummaryViewController
            {
                projectSummary.project = project
                self.projectSummary = projectSummary
            }
        }
        
        if segue.identifier == "addTaskSegue"
        {
            if let addTask = segue.destination as? Add_Edit_TaskViewController
            {
                addTask.currentProject = project
                addTask.projectSummary = self.projectSummary
            }
        }
        
        if segue.identifier == "editTaskSegue"
        {
            if let editTask = segue.destination as? Add_Edit_TaskViewController
            {
                editTask.currentProject = project
                editTask.task = currentTask
                editTask.projectSummary = self.projectSummary
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let task = tasks![indexPath.row]
        if(task != nil)
        {
            currentTask = task
        }
        
        print("task name \(task.name) notification id\(task.notificationId)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return tasks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
//            let context = self.fetchedResultsController.managedObjectContext
//            context.delete(self.fetchedResultsController.object(at: indexPath))
//
//            do
//            {
//                try context.save()
//            }
//
//            catch
//            {
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return true
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        let task = tasks![indexPath.row]
        
        cell.task = task
        let note = helper.unwrapBoolean(optionalBool: task.notes?.isEmpty) ? "No notes available" : helper.unwrapString(optionalString: task.notes)
        cell.label_title.text = "\(helper.unwrapString(optionalString: task.name)) - Due on \(helper.dateToString(date: helper.unwrapDate(optionalDate: task.dueDate)))"
        cell.label_startDate.text = "Start date - \(helper.dateToString(date: helper.unwrapDate(optionalDate: task.startDate)))"
        cell.label_reminder.text = "Notify when due date is passed - \(task.remindWhenDatePassed == true ? "Yes" : "No")"
        cell.txtView_notes.text = note
        cell.txtView_notes.layer.borderColor = UIColor.lightGray.cgColor
        cell.txtView_notes.layer.borderWidth = 1
        cell.txtView_notes.isEditable = false
        cell.progressBar_task.labelSize = 18
        cell.progressBar_task.setProgress(to: Double(task.progress), withAnimation: true)
        cell.progressBar_task.lineWidth = 18
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath)
    {
        //   cell.detailTextLabel?.text = "test label"
        
    }
    
    //MARK: - fetch results controller
    
//    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
//
//    var fetchedResultsController: NSFetchedResultsController<Task> {
//
//        if _fetchedResultsController != nil
//        {
//            return _fetchedResultsController!
//        }
//
//
//        let currentProject  = self.project
//        let request:NSFetchRequest<Task> = Task.fetchRequest()
//        //simpler version for just getting the albums
//        //   let albums:NSSet = (currentArtist?.albums)!
//
//        request.fetchBatchSize = 20
//        //sort alphabetically
//        let taskSortDescriptors = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
//
//        //simpler version
//        //   albums.sortedArray(using: [albumNameSortDescriptor])
//
//
//        request.sortDescriptors = [taskSortDescriptors]
//        //we want the albums for the recordArtist - via the relationship
//        if(self.project != nil)
//        {
//            let predicate = NSPredicate(format: "project_tasks = %@", currentProject!)
//            request.predicate = predicate
//        }
//
////        else
////        {
////            //just do all albums for the first artist in the list
////            //replace this to get the first artist in the record
////            let predicate = NSPredicate(format: "project = %@","Pink Floyd")
////            request.predicate = predicate
////        }
//
//        let frc = NSFetchedResultsController<Task>(
//            fetchRequest: request,
//            managedObjectContext: managedObjectContext,
//            sectionNameKeyPath: #keyPath(Task.project_tasks),
//            cacheName:nil)
//        frc.delegate = self
//        _fetchedResultsController = frc
//
//        do
//        {
//            //    try frc.performFetch()
//            try _fetchedResultsController!.performFetch()
//        }
//
//        catch
//        {
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
//
//
//        return frc as! NSFetchedResultsController<NSFetchRequestResult> as! NSFetchedResultsController<Task>
//    }//end var
    
    //MARK: - fetch results table view functions
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    {
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
                self.configureCell(tableView.cellForRow(at: indexPath!)!, indexPath: newIndexPath!)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
                //    default: break
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        self.tableView.endUpdates()
        // self.tableView.reloadData()
    }
}

