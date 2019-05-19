//
//  MasterViewController.swift
//  ProjectPlanner
//
//  Created by user153198 on 4/26/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

/********************************************************************************************************************
 Most of the code snippets have been adopted from the lecture notes and the the Master detail video by Philip Trwoga
*********************************************************************************************************************/

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate
{

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    var isInitialSetup: Bool = true
    let helper = Helper()
    let calendarHelper = CalendarHelper()
    let notificationHelper = NotificationHelper()


    override func viewDidLoad()
    {
        print("hits viewDidLoad in master\n")
        super.viewDidLoad()
        
        //navigationItem.leftBarButtonItem = editButtonItem
        //navigationItem.leftBarButtonItem?.title = "Delete Multiple"
        
        if let split = splitViewController
        {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        print("hits viewWillAppear in master\n")
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any)
    {
        print("hits insertNewObject in master\n")
        let context = self.fetchedResultsController.managedObjectContext
        let newProject = Project(context: context)
             
        // If appropriate, configure the new managed object.
        newProject.dueDate = Date.init()

        // Save the context.
        do
        {
            try context.save()
        }
        
        catch
        {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("hits prepare in master\n")
        if segue.identifier == "showDetail"
        {
            if let indexPath = tableView.indexPathForSelectedRow
            {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                self.detailViewController = controller
                controller.selectedProject = object
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    
    /***********************************************************************************
     TableView Functionalities
    ************************************************************************************/
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("hits didSelectRowAt in master\n")
        
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        let currentProject = fetchedResultsController.object(at: indexPath) as Project
        self.detailViewController?.selectedProject = currentProject

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        print("hits numberOfSections in master\n")
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("hits numberOfRowsInSection in master\n")
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        print("hits cellForRowAt in master\n")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let project = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withProject: project)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        print("hits editingStyle in master\n")
        if editingStyle == .delete
        {
            let context = fetchedResultsController.managedObjectContext
            let objectToDelete = fetchedResultsController.object(at: indexPath) as Project
            let eventIdentifier = helper.unwrapString(optionalString: objectToDelete.calendarEventId)
            let hasEvent = !helper.unwrapBoolean(optionalBool: eventIdentifier.isEmpty)
            let objectTasks = objectToDelete.tasks?.allObjects as! [Task]
            context.delete(objectToDelete)
                
            do
            {
                if(objectTasks.count > 0)
                {
                    var notificationIds: [String] = []
                    print("task count in delete \(objectTasks.count)")
                    
                    for eachTask in objectTasks
                    {

                        notificationIds.append(helper.unwrapString(optionalString: eachTask.notificationId))
                    }
                    
                    notificationHelper.cancelNotification(notificationIds: notificationIds) //remove all the pending notifications
                }
                
                if(hasEvent) //delete the calendar event
                {
                    calendarHelper.deleteCalendarEvent(calendarEventId: eventIdentifier)
                }
                
                try context.save()
                self.detailViewController?.clearProjectSummary()
                self.detailViewController?.selectedProject = nil
            }
            
            catch
            {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withProject project: Project)
    {
        print("hits configureCell in master\n")
        let priority = helper.priorityLiteral(priorityValue: project.priority)
        cell.textLabel!.text = "\(helper.unwrapString(optionalString: project.name)) - \(priority) Prority"
        let unWrappedDate = helper.unwrapDate(optionalDate: project.dueDate)
        cell.detailTextLabel!.text = helper.dateToString(date: unWrappedDate)
        
        print("Date in master detail view -> \(unWrappedDate)")

    }

    
    /****************************************************************
     Fetched Result Controller Functionalities
     ****************************************************************/
    var _fetchedResultsController: NSFetchedResultsController<Project>? = nil
    var fetchedResultsController: NSFetchedResultsController<Project>
    {
        print("hits fetchedResultsController in master\n")
        if _fetchedResultsController != nil
        {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let dueDateDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        let priorityDescriptor = NSSortDescriptor(key: "priority", ascending: true)
        
        fetchRequest.sortDescriptors = [dueDateDescriptor, priorityDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do
        {
            try _fetchedResultsController!.performFetch()
        }
        
        catch
        {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        let numberOfProjects: Int = _fetchedResultsController?.fetchedObjects?.count ?? 0
        
        if(numberOfProjects > 0 && self.isInitialSetup) //select the very first project when initially setup
        {
            self.tableView(self.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
            self.isInitialSetup = false
        }
        
        return _fetchedResultsController!
    }
    
    
    /****************************************************************
     Controller Functionalities
     ****************************************************************/
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        print("hits controllerWillChangeContent in master\n")
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    {
        print("hits didChange sectionInfo in master\n")
        switch type
        {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        print("hits didChange in master\n")
        switch type
        {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withProject: anObject as! Project)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withProject: anObject as! Project)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        print("hits controllerDidChangeContent in master\n")
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}

