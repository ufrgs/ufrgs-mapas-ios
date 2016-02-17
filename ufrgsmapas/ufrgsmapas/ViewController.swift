//
//  ViewController.swift
//  ufrgsmapas
//
//  Created by Theodoro L. Mota on 12/23/15.
//  Copyright © 2015 UFRGS. All rights reserved.
// 37.331965, -122.030262

import UIKit
import MapKit

class ViewController: UIViewController,MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var btnView: UIView!
    
    var shouldCenter = true
    var locationManager: CLLocationManager!
    var lastLocation : CLLocation?
    var textFieldInsideSearchBar : UITextField?
    let searchController = UISearchController(searchResultsController: nil)
    
    var pinsToShow = [PinPosition]()
    
    // ----------------------------------------------------------
    // MARK: Lifecicle
    // ----------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        textFieldInsideSearchBar = (searchBar.valueForKey("searchField") as? UITextField)!
        textFieldInsideSearchBar!.textColor = UIColor.whiteColor()
        
        btnView.layer.cornerRadius = 4.0
        
        LayoutUtils.setSearchCancelButtonColor(UIColor.whiteColor())
    
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        pinsToShow = DBManager.getBuildingsByNameOrNumber("") //getAllPins()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        mapView.addGestureRecognizer(tap)
        mapView.delegate = self
        mapView.showsUserLocation = true
        putPinsOnMap()
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "detailSegue" {
            
            let pin : PinPosition = sender as! PinPosition
            let vc = segue.destinationViewController as! DetailViewController
            vc.id = pin.id
            
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // ----------------------------------------------------------
    // MARK: Map n' Location Delegates
    // ----------------------------------------------------------
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? PinPosition {
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                
            }
            view.image = UIImage(named: "pin1.png")
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        self.performSegueWithIdentifier("detailSegue", sender: annotationView.annotation)
      
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "calloutTapped:")
        view.addGestureRecognizer(tap)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        lastLocation = locations.last! as CLLocation
        
        if (shouldCenter){
            MapAndLocationUtils.centerMapOnUser(lastLocation!, map: mapView)
            shouldCenter = false
        }
        
        
    }
    
    // ----------------------------------------------------------
    // MARK: TableView Delegates
    // ----------------------------------------------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pinsToShow.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = self.pinsToShow[indexPath.row].buildingNumber + " - " + self.pinsToShow[indexPath.row].title!
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let clickedPin = self.pinsToShow[indexPath.row]
        pinsToShow.removeAll()
        pinsToShow.append(clickedPin)
        putPinsOnMap()
        searchView.hidden = true
        
        MapAndLocationUtils.centerMapOnUser(CLLocation(latitude: clickedPin.coordinate.latitude, longitude: clickedPin.coordinate.longitude), map: mapView)
        
        textFieldInsideSearchBar!.text = clickedPin.title
            
        dismissKeyboard()
        
    }
    
    
    // ----------------------------------------------------------
    // MARK: Search Delegates
    // ----------------------------------------------------------
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchView.hidden = false
        pinsToShow = DBManager.getBuildingsByNameOrNumber("")
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchView.hidden = true
        putPinsOnMap()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        pinsToShow = DBManager.getBuildingsByNameOrNumber("")
        tableView.reloadData()
        dismissKeyboard()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        pinsToShow = DBManager.getBuildingsByNameOrNumber(searchText)
        tableView.reloadData()
    }
    
    // ----------------------------------------------------------
    // MARK: Auxiliar Functions
    // ----------------------------------------------------------
    
    @IBAction func centerUserLocation(sender: AnyObject) {
        if lastLocation != nil {
            MapAndLocationUtils.centerMapOnUser(lastLocation!, map: mapView)
        }
    }
    
    @IBAction func changeLayerButton(sender: AnyObject) {
        
        let mapType = mapView.mapType
        
        switch (mapType) {
        case .Standard:
            mapView.mapType = MKMapType.Hybrid
        case .Hybrid:
            mapView.mapType = MKMapType.Standard
        default:
            mapView.mapType = MKMapType.Standard
        }
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func calloutTapped(sender : UITapGestureRecognizer){
        let annotation = (sender.view as! MKAnnotationView).annotation
        self.performSegueWithIdentifier("detailSegue", sender: annotation)
    }
    
    func putPinsOnMap() {
        mapView.removeAnnotations(mapView.annotations)
        for pin in pinsToShow {
            mapView.addAnnotation(pin)
        }
    }
    

}

