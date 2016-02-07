//
//  ViewController.swift
//  Notes
//
//  Created by Bart Jacobs on 06/02/16.
//  Copyright © 2016 Bart Jacobs. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, AddNoteViewControllerDelegate {

    @IBOutlet var tableView: UITableView!
    
    var coreDataManager: CoreDataManager = CoreDataManager()

    private lazy var fetchedResultsController: NSFetchedResultsController = {
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Note")

        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.coreDataManager.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

        // Set Delegate
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    // MARK: -
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Save Note")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
    }

    // MARK: -
    // MARK: Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath, let cell = tableView.cellForRowAtIndexPath(indexPath) {
                configureCell(cell, atIndexPath: indexPath)
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }

            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }

    // MARK: -
    // MARK: Table View Data Source Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }

        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath)

        // Configure Cell
        configureCell(cell, atIndexPath: indexPath)

        return cell
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Fetch Note
        if let note = fetchedResultsController.objectAtIndexPath(indexPath) as? Note {
            cell.textLabel?.text = note.title
            cell.detailTextLabel?.text = note.content
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let note = fetchedResultsController.objectAtIndexPath(indexPath) as? Note {
                fetchedResultsController.managedObjectContext.deleteObject(note)
            }
        }
    }

    // MARK: -
    // MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: -
    // MARK: Segue Handling
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SegueAddNoteViewController" {
            if let navigationController = segue.destinationViewController as? UINavigationController,
               let viewController = navigationController.viewControllers.first as? AddNoteViewController {
                // Configure View Controller
                viewController.delegate = self
            }
        } else if segue.identifier == "SegueNoteViewController" {
            if let viewController = segue.destinationViewController as? NoteViewController {
                if let indexPath = tableView.indexPathForSelectedRow, let note = fetchedResultsController.objectAtIndexPath(indexPath) as? Note {
                    // Configure View Controller
                    viewController.note = note
                }
            }
        }
    }

    // MARK: -
    // MARK: Add Note View Controller Delegate Methods
    func controller(controller: AddNoteViewController, didAddNoteWithTitle title: String) {
        // Create Entity
        let entity = NSEntityDescription.entityForName("Note", inManagedObjectContext: coreDataManager.managedObjectContext)

        if let entity = entity {
            // Create Note
            let note = Note(entity: entity, insertIntoManagedObjectContext: coreDataManager.managedObjectContext)

            // Populate Note
            note.content = ""
            note.title = title
            note.updatedAt = NSDate().timeIntervalSinceReferenceDate
            note.createdAt = NSDate().timeIntervalSinceReferenceDate

            do {
                try note.managedObjectContext?.save()
            } catch {
                let saveError = error as NSError
                print("Unable to Save Note")
                print("\(saveError), \(saveError.localizedDescription)")
            }
        }
    }

}
