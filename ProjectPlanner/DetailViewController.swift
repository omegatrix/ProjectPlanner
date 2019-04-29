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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        print("This is the object ID -> \(project?.objectID) \n Type of \(type(of: project?.objectID))")
    }

    var project: Project?
    {
        didSet
        {
            // Update the view.
            configureView()
        }
    }

    func configureView()
    {
        // Update the user interface for the detail item.
//        if let detail = detailItem
//        {
////            if let label = detailDescriptionLabel
////            {
////                label.text = detail.name
////            }
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //
        if segue.identifier == "projectSummary"
        {
            if let projectSummary = segue.destination as? ProjectSummaryViewController
            {
                projectSummary.project = project
            }
        }
        
//        if segue.identifier == "addAlbum"
//        {
//            if let addAlbumViewController = segue.destination as? AddAlbumViewController{
//                addAlbumViewController.currentArtist = artist
//            }
//        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return self.fetchedResultsController.sections?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            
            do
            {
                try context.save()
            }
            
            catch
            {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return true
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        self.configureCell(cell,indexPath: indexPath)
        return cell
    }
    
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath)
    {
        //   cell.detailTextLabel?.text = "test label"
        
        let title = self.fetchedResultsController.fetchedObjects?[indexPath.row].name
        cell.textLabel!.text = title
        
        if let taskName = self.fetchedResultsController.fetchedObjects?[indexPath.row].name
        {
            cell.detailTextLabel?.text = taskName
        }
            
        else
        {
            cell.detailTextLabel!.text = ""
        }
        
    }
    
    //MARK: - fetch results controller
    
    var _fetchedResultsController: NSFetchedResultsController<Task>? = nil
    
    var fetchedResultsController: NSFetchedResultsController<Task> {
        
        if _fetchedResultsController != nil
        {
            return _fetchedResultsController!
        }
        
        
        let currentProject  = self.project
        let request:NSFetchRequest<Task> = Task.fetchRequest()
        //simpler version for just getting the albums
        //   let albums:NSSet = (currentArtist?.albums)!
        
        request.fetchBatchSize = 20
        //sort alphabetically
        let taskSortDescriptors = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        
        //simpler version
        //   albums.sortedArray(using: [albumNameSortDescriptor])
        
        
        request.sortDescriptors = [taskSortDescriptors]
        //we want the albums for the recordArtist - via the relationship
        if(self.project != nil)
        {
            let predicate = NSPredicate(format: "project_tasks = %@", currentProject!)
            request.predicate = predicate
        }
            
//        else
//        {
//            //just do all albums for the first artist in the list
//            //replace this to get the first artist in the record
//            let predicate = NSPredicate(format: "project = %@","Pink Floyd")
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

