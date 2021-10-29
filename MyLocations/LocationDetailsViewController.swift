//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by user206341 on 10/26/21.
//

import UIKit
import CoreLocation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    
    // to observe dateFormatter only initiated once
    // Single Instance Mode
    print("TAG return a formatter")
    
    return formatter
}()

class LocationDetailsViewController: UITableViewController {

    @IBOutlet var descriptionText: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    
    var categoryName = "No Category"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        descriptionText.text = ""
        categoryLabel.text = ""
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        if let placemark = placemark {
            addressLabel.text = toString(from: placemark)
        }else {
            addressLabel.text = "No Address found"
        }
        dateLabel.text = dateToString(from: Date())
        
        // funcel: Hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Table view delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        //print("TAG tableView(_:willSelectRowAt:)...")
        
        // because user can only operate section 0 and section 1
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        }else {
            // will not have event to trigger tableView(_:didSelectRowAt:)
            // it means app will not respond to tap in section 2
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("TAG tableView(_:didSelectRowAt:)...")
        
        if indexPath.section == 0 && indexPath.row == 0 {
            self.descriptionText.becomeFirstResponder()
        }
    }
    
    // Acctually, it's a static cell TableViewController, don't need data source
    // MARK: - Table view data source

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }

    // MARK: - Actions
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done() {
        guard let mainView = navigationController?.parent?.view
        else {return}
        
        // we don't use the current view as parent view,
        // because we want current view's parent view (Tab Bar View) cannot interact with user when Hud view was showing
//        let hudview = HudView.hud(inView: view, animation: true)
        
        let hudview = HudView.hud(inView: mainView, animation: true)
        hudview.text = "Tagged"
        
//        navigationController?.popViewController(animated: true)
    }
    
    // action func for unwind segue
    @IBAction func categoryPickerDidPickCategory(_ segue : UIStoryboardSegue) {
        let controller = segue.source as! CategoryPickerViewController
        self.categoryName = controller.selectedCategoryName
        // update UI display
        self.categoryLabel.text = categoryName
    }
    
    // MARK: - Helper Methods
    func toString(from placemark: CLPlacemark) -> String {
        var address = "make it very long, to test UI effection"
        if let tmp = placemark.subThoroughfare {
            address += tmp + " "
        }
        
        if let tmp = placemark.thoroughfare {
            address += tmp + ","
        }
        
        if let tmp = placemark.locality {
            address += tmp + ","
        }
        
        if let tmp = placemark.administrativeArea {
            address += tmp + " "
        }
        if let tmp = placemark.postalCode {
            address += tmp + ","
        }
        if let tmp = placemark.country {
            address += tmp
        }
        
        return address
    }
    
    func dateToString(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    // hide key board
    @objc func hideKeyboard(_ gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        
        // cancel text view as the first responder
        descriptionText.resignFirstResponder()
    }
}
