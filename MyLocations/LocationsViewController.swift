//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by user206341 on 10/30/21.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    var locations = [Location]()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
    
        let fetchRequest = NSFetchRequest<Location>()
        let entity = Location.entity()
        fetchRequest.entity = entity

        // only sort with date
//        let sort = NSSortDescriptor(key: "date", ascending: true)
//        fetchRequest.sortDescriptors = [sort]
        
        // sort with category and date
        let sort1 = NSSortDescriptor(key: "category", ascending: true)
        let sort2 = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sort1, sort2]
        
        fetchRequest.fetchBatchSize = 20

        // only sort with date
//        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: "Locations")
        // sort with category and date
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "category", cacheName: "Locations")
        fetchedResultController.delegate = self
        
        return fetchedResultController
    }()
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    //
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
       
        // replaced by fetchedResultsController
        // read all data from core data store
//        let request = NSFetchRequest<Location>()
//
//        let entity = Location.entity()
//        request.entity = entity
//
//        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
//        request.sortDescriptors = [sortDescriptor]
//
//        do {
//            locations = try managedObjectContext.fetch(request)
//        }catch {
//            fatalCoreDataError(error)
//        }
        
        performFetch()
        
        // mass editing button
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    // handle low memory warning, release some cashed object
    // in this app, thumbnails used by unvisible cells dealt by UIKit
    override func didReceiveMemoryWarning() {
        print("TAG didReceiveMemoryWarning()...")
    }

    // MARK: - Helper Methods
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        }catch {
            fatalCoreDataError(error)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController.sections!.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        // replaced by fetchedResultsController
//        return locations.count
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell

        // replaced by fetchedResultsController
//        let location = locations[indexPath.row]
        let location = fetchedResultsController.object(at: indexPath)
        
        cell.config(for: location)
        // Configure the cell...
//        let descriptionLabel = cell.viewWithTag(100) as! UILabel
//        descriptionLabel.text = location.locationDescription
//
//        let addressLabel = cell.viewWithTag(101) as! UILabel
//        var address = ""
//        if let placemark = location.placemark {
//            if let tmp = placemark.subThoroughfare {
//                address += tmp + " "
//            }
//            if let tmp = placemark.thoroughfare {
//                address += tmp + ","
//            }
//            if let tmp = placemark.locality {
//                address += tmp
//            }
////            if let tmp = placemark.administrativeArea {
////                address += tmp
////            }
////            if let tmp = placemark.postalCode {
////                address += tmp
////            }
////            if let tmp = placemark.country {
////                address += tmp
////            }
//            addressLabel.text = address
//        }else {
//            addressLabel.text = ""
//        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let location = fetchedResultsController.object(at: indexPath)
            location.removePhotoFile()
            managedObjectContext.delete(location)
            
            do {
                try managedObjectContext.save()

            }catch {
                fatalCoreDataError(error)
            }
            
            // replaced by fetchedResultsController
//            tableView.deleteRows(at: [indexPath], with: .fade)
        }
//        else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EditLocation" {
            // 1. send managedObjectContext to LocationDetailsViewController
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = self.managedObjectContext
            
            // 2. send location to edit
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                // replaced by fetchedResultsController
//                let location = locations[indexPath.row]
                let location = fetchedResultsController.object(at: indexPath)
                controller.locationToEdit = location
            }
            
        }
    }

}

// MARK: - NSFetchedResultController Delegate Extension
extension LocationsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("TAG *** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("TAG *** NSFetchedResultsChangeInsert (Object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("TAG *** NSFetchedResultsChangeDelete (Object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("TAG *** NSFetchedResultsChangeUpdate (Object)")
            if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                let location = controller.object(at: indexPath!) as! Location
                cell.config(for: location)
            }

        case .move:
            print("TAG *** NSFetchedResultsChangeMove (Object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)

        default:
            print("TAG *** NSFetchedResults (Object) unknown type")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("TAG *** NSFetchedResultsChangeInsert (Section)")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)

        case .delete:
            print("TAG *** NSFetchedResultsChangeDelete (Section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)

        case .update:
            print("TAG *** NSFetchedResultsChangeUpdate (Section)")

        case .move:
            print("TAG *** NSFetchedResultsChangeMove (Section)")

        default:
            print("TAG *** NSFetchedResults (Section) unknown type")

        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("TAG *** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
