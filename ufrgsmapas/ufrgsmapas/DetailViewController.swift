//
//  DetailViewController.swift
//  ufrgsmapas
//
//  Created by Theodoro L. Mota on 1/20/16.
//  Copyright © 2016 UFRGS. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var imgBuilding: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAdress: UILabel!
    @IBOutlet weak var lblCep: UILabel!
    @IBOutlet weak var photoHeight: NSLayoutConstraint!
    
    var id : Int32?
    var building : Building?
    
    // ----------------------------------------------------------
    // MARK: Lifecicle
    // ----------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        building = DBManager.getBuildingById(id!)
        
        cardView.layer.cornerRadius = 7.0
        cardView.clipsToBounds = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissView")
        
        blurView.addGestureRecognizer(tap)
        imgBuilding.clipsToBounds = true

        lblName.text = building?.title
        
        if (building?.addressName)! != nil && (building?.addressNumber)! != nil {
            lblAdress.text = (building?.addressName)! + " " + (building?.addressNumber)!
        } else {
            lblAdress.text = "Sem endereço cadastrado"
        }
        
        if (building?.zipCode)! != nil {
            lblCep.text = "CEP: " + (building?.zipCode)!
        } else {
            lblCep.text = "Sem CEP cadastrado"
        }
        
        if let img = UIImage(named: (building?.ufrgsBuildingCode)! + ".jpg") {
            imgBuilding.image = img
        } else {
            imgBuilding.hidden = true
            UIView.animateWithDuration(Double(1), animations: {
                self.photoHeight.constant = 0
                self.view.layoutIfNeeded()
            })
        }
        
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // ----------------------------------------------------------
    // MARK: Actions
    // ----------------------------------------------------------

    @IBAction func btnDrive(sender: AnyObject) {
        openMaps()
    }
    
    // ----------------------------------------------------------
    // MARK: Auxiliar Functions
    // ----------------------------------------------------------
    
    func dismissView(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func openMaps() {
        let latitude : CLLocationDegrees = (building?.latitude)!
        let longitude : CLLocationDegrees = (building?.longitude)!
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = building?.title
        mapItem.openInMapsWithLaunchOptions(options)
    }
}
