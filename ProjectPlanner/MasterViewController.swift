//
//  MasterViewController.swift
//  ProjectPlanner
//
//  Created by user153198 on 4/26/19.
//  Copyright © 2019 Arnold Anthonypillai. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate
{

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    let helper = Helper()
    let calendarHelper = CalendarHelper()
    let notificationHelper = NotificationHelper()


    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem

        
        if let split = splitViewController
        {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    @objc
    func insertNewObject(_ sender: Any)
    {
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
        if segue.identifier == "showDetail"
        {
            if let indexPath = tableView.indexPathForSelectedRow
            {
                let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.project = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
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
                    
                    notificationHelper.cancelNotification(notificationIds: notificationIds)
                }
                
                if(hasEvent) //delete the calendar event
                {
                    calendarHelper.deleteCalendarEvent(calendarEventId: eventIdentifier)
                }
                
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
    }

    func configureCell(_ cell: UITableViewCell, withProject project: Project)
    {
        cell.textLabel!.text = project.name
        let unWrappedDate = helper.unwrapDate(optionalDate: project.dueDate)
        cell.detailTextLabel!.text = helper.dateToString(date: unWrappedDate)
        
        print("Date in master detail view -> \(unWrappedDate)")

    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Project>
    {
        if _fetchedResultsController != nil
        {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
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
        
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Project>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    {
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

