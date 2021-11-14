//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by user206341 on 10/26/21.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    
    // to observe dateFormatter only initiated once
    // Single Instance Mode
    print("TAG return a formatter")
    
    return formatter
}()

class LocationDetailsViewController: UITableViewController, UINavigationControllerDelegate {

    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    
    var categoryName = "No Category"
    var date = Date()
    
    var managedObjectContext: NSManagedObjectContext!
    
    var descriptionText = ""
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                self.descriptionText = location.locationDescription
                self.categoryName = location.category
                self.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                self.placemark = location.placemark
                self.date = location.date
            }
        }
    }
    
    @IBOutlet var addphotoLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageHeight: NSLayoutConstraint!
    var image: UIImage?
    
    // object for background mode
    var observer: Any!
    
    deinit {
        print("TAG LocationDetailsViewController deinit \(self)")
        NotificationCenter.default.removeObserver(observer!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if let location = locationToEdit {
            title = "Edit Location"
            descriptionTextView.text = descriptionText
            categoryLabel.text = categoryName
            
            if location.hasPhoto {
                // here only read the .jpg file
                if let theImage = location.photoImage {
                    show(image: theImage)
                }
            }
        }
        else {
            descriptionTextView.text = ""
            categoryLabel.text = ""
        }

        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        if let placemark = placemark {
            addressLabel.text = toString(from: placemark)
        }else {
            addressLabel.text = "No Address found"
        }
        dateLabel.text = dateToString(from: date)
        
        // funcel: Hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        // handle background mode
        listenForBackgroundNotification()

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
        
        // let the gray color over the cell go away
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            self.descriptionTextView.becomeFirstResponder()
        }else if indexPath.section == 1 && indexPath.row == 0 {
            pickPhoto()
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
        
        let location: Location
        if let tmp = locationToEdit {
            hudview.text = "Updated"
            // funcel: save data to core data store
            // 1.1. when edit location, already have a Location object
            location = tmp
        }else {
            hudview.text = "Tagged"

            // 1.2. when tag location, create a managed object and put it into managedObjectContext
            location = Location(context: managedObjectContext)
            
            // because of the nextPhotoID() mechanism, must set photoID = nil,
            // otherwise, it will be 0, and every location's photoID will be 0
            location.photoID = nil
        }
        
        //hudview.show(animation: true)
        hudview.showSpringAnimation(animation: true)
        
        // 2. put data to be saved into the managed object(location)
        location.locationDescription = self.descriptionTextView.text

        location.latitude = self.coordinate.latitude
        location.longitude = self.coordinate.longitude
        location.category = self.categoryName
        location.placemark = self.placemark
        location.date = self.date
        
        // 2.2 save image, put data regard to image into the managed object(location)
            // 2.2.1 location has no photo before, give it a new photoID
            // otherwise, overwrite the old .jpg file
        if let image = image {
            print("TAG There's image")
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            
                // convert UIImage to .jpg file object
            if let data = image.jpegData(compressionQuality: 0.5) {
                do {
                    // write file
                    print("TAG write .jpg file to \(location.photoURL.path)")
                    try data.write(to: location.photoURL, options: .atomic)

                } catch {
                    print("Error writing file \(error)")
                }
            }
        }
            
        // 3. save
        do{
            try managedObjectContext.save()

            // navigate to parent screen after a delay time
            // encapsulate into Functions.swift
            afterDelay(0.6) {
                hudview.hide()
                self.navigationController?.popViewController(animated: true)
                
            }
            
            //        let delayInSeconds = 0.6    // this delay time should correspond with animation's run time
            //        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
            //            hudview.hide()
            //            self.navigationController?.popViewController(animated: true)
            //        }

        }catch {
            // 4. handle error
//            fatalError("Error: \(error)")
            // send out alert notification instead of use fatalError() directly
            fatalCoreDataError(error)
        }
        
        
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
        var address = ""
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
        descriptionTextView.resignFirstResponder()
    }
    
    // handle background mode
    func listenForBackgroundNotification() {
        // change the name of the notification, why? -- doesn't work, there's fatal error
//        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) {
        observer = NotificationCenter.default.addObserver(forName: UIScene.didEnterBackgroundNotification,
                                               object: nil, queue: OperationQueue.main) {
            // declare self as weak self, then this closure will not keep view controller alive, means the view controller can be deallocated
            // from iOS 9.0 and above, system will deal with the memory leak caused by strong reference loop
            [weak self] _ in
            // using: <#T##(Notification) -> Void#>
            if let weakSelf = self {
                // self.presentationController is the modal view controller that we use present() opened
                if weakSelf.presentationController != nil {
                    weakSelf.dismiss(animated: false, completion: nil)
                }
                
                weakSelf.descriptionTextView.resignFirstResponder()
            }
        }
    }
}

extension LocationDetailsViewController: UIImagePickerControllerDelegate {
    // MARK: - Image Helper Methods
    func pickPhoto() {
        // make the condition be true always, only for test this branch
        if true || UIImagePickerController.isSourceTypeAvailable(.camera) {
        // check if device have camera
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        }else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actCancel)
        
        let actTakePhoto = UIAlertAction(title: "Take Photo", style: .default) {_ in
            self.takePhotoWithCamera()
        }
        alert.addAction(actTakePhoto)
        
        let actChoosePhoto = UIAlertAction(title: "Choose From Library", style: .default) {_ in
            self.choosePhotoFromLibrary()
        }
        alert.addAction(actChoosePhoto)
        // in dark mode, change the tintColor, otherwise it's blue
        alert.view.tintColor = view.tintColor
        present(alert, animated: true, completion: nil)
    }
    
    // camera source type cannot run with simulator
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.isEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.isEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // show image
    func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        addphotoLabel.text = ""

        // change image height, keep image width=260 points, keep image's height width ratio
        let imageRatio = image.size.height/image.size.width
        imageHeight.constant = round(260 * imageRatio)
//        imageHeight.constant = 260
        print("TAG imageHeight = \(imageHeight.constant) imageWidth = \(image.size.width)")
        // after change the image height, reload data to update tableView
        tableView.reloadData()
    }
    
    // MARK: - UIImagePickerController Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // use the edited image
//        let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        // use the original image
        image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        if let theImage = image {
            show(image: theImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
