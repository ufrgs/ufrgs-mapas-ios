//
//  ViewController.swift
//  ufrgsmapas
//
//  Created by Theodoro L. Mota on 12/23/15.
//  Copyright © 2015 UFRGS. All rights reserved.
// 37.331965, -122.030262

import UIKit
import MapKit
import SwiftOverlays

class ViewController: UIViewController,MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var btnView: UIView!
    
    let loadingMessage = "Carregando informações"
    
    var dbManager = DBManager()
    var hasLoaded = false
    var shouldCenter = true
    var locationManager: CLLocationManager!
    var lastLocation : CLLocation?
    var textFieldInsideSearchBar : UITextField?
    let searchController = UISearchController(searchResultsController: nil)
    
    var noInternetView: NoInternetView?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var allPins = [Pin]()
    var pinsToShow = [Pin]()
    var allBuildings = [Building]()
    var buildingsToShow = [Building]()
    
    // ----------------------------------------------------------
    // MARK: Lifecicle
    // ----------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure some stuff
        configureSearchBar()
        configureTableView()
        configureMapView()
        configureButton()
        configureLocationManager()
        
        self.showWaitOverlay()
        
        // load buildings
        loadBuildings {
            // show pins on map
            DispatchQueue.main.async {
                self.removeAllOverlays()
                self.putPinsOnMap()
            }
        }
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showPrivacyPolicyIfNeeded()
    }
    
    private func loadBuildings(completion: (() -> ())?) {
        
        let success = {
            self.getAllBuildingsFromDB()
            self.getAllPins()
            
            if let c = completion {
                c()
            }
        }
        
        // if has buildings saved locally, use them
        if !self.dbManager.isEmpty() {
            success()
            return
        }
        
        // else, if internet is available, try to fetch the buildings
        if InternetUtils.isAvailable() {
            self.fetchBuildings { buildings in
                self.dbManager.save(buildings: buildings)
                success()
            }
            
            return
        }
        
        // else (no internet), show alert
        self.showNoInternetAlert()
        
    }
    
    private func getAllBuildingsFromDB() {
        self.allBuildings = self.dbManager.getAllBuildings()
        self.buildingsToShow = self.allBuildings
    }
    
    private func getAllPins() {
        self.allPins = self.makeAllPins(self.allBuildings)
        self.pinsToShow = self.allPins
    }
    
    private func showNoInternetAlert() {
        
        self.searchBar.isUserInteractionEnabled = false
        
        // if didn't initialise yet, do it
        if noInternetView == nil {
            noInternetView = NoInternetView.fromNib()
            noInternetView?.tryAgainButton.addTarget(self, action: #selector(tryLoadingAgain), for: .touchUpInside)
            
            noInternetView?.didMoveToSuperview()
            noInternetView?.frame = self.mapView.frame
        }
        
        // if the view wasn't visible yet
        if !noInternetView!.isDescendant(of: self.view) {
            
            noInternetView?.alpha = 0.0
            view.addSubview(noInternetView!)
            noInternetView?.didMoveToSuperview()
            
            UIView.animate(withDuration: 0.2, animations: {
                self.noInternetView?.alpha = 1.0
            })
        }
        
        noInternetView?.setLoading(false)
    }
    
    @objc func tryLoadingAgain() {
        
        noInternetView?.setLoading(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            
            self.loadBuildings {
                UIView.animate(withDuration: 0.3, animations: {
                    self.noInternetView?.alpha = 0.0
                }) { _ in
                    self.noInternetView?.removeFromSuperview()
                    self.noInternetView = nil
                    
                    DispatchQueue.main.async {
                        self.removeAllOverlays()
                        self.putPinsOnMap()
                    }
                }
                
                self.searchBar.isUserInteractionEnabled = true
            }
        }
        
    }
    

    // ----------------------------------------------------------
    // MARK: - Overrides
    // ----------------------------------------------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetailSegue" {
            
            let pin : Pin = sender as! Pin
            let vc = segue.destination as! DetailController
            
            vc.buildings = pin.buildings
            vc.completionHandler = {
                self.mapView.deselectAnnotation(pin, animated: true)
            }
            
        }
        
    }
    
    // ----------------------------------------------------------
    // MARK: - Fetch methods
    // ----------------------------------------------------------
    
    func fetchBuildings(completion: @escaping ([Building]) -> ()) {
        
        let fetcher = BuildingsFetcher()
        
        fetcher.run { (buildings) in
            completion(buildings)
        }
        
    }
    
    func makeAllPins(_ buildings: [Building]) -> [Pin] {
        
        var pins = [Pin]()
        
        for b in buildings {
            
            // tenta pegar o índice de um pin com as coordenadas de b
            let pinIndex = pins.firstIndex { p -> Bool in
                return (p.coordinate.latitude == b.latitude && p.coordinate.longitude == b.longitude)
            }
            
            // se já houver pin com aquelas coordenadas
            if let i = pinIndex {
                // adiciona o prédio atual (b) na lista do pin
                pins[i].buildings.append(b)
            } else {
                // senão, cria novo pin
                let pin = makePin(b)
                pins.append(pin)
            }
            
        }
        
        return pins
        
    }
    
    func makePin(_ building: Building) -> Pin {
        let pin = Pin(title: building.name, lat: building.latitude, long: building.longitude)
        
        pin.buildings.append(building)
        
        return pin
    }
    
    // ----------------------------------------------------------
    // MARK: Map n' Location Delegates
    // ----------------------------------------------------------
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? Pin {
            let identifier = "pin"
            var view: MKAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = false
                view.calloutOffset = CGPoint(x: 0, y: 10)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            
            view.image = getPinImage(annotation, isSelected: false)

            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.performSegue(withIdentifier: "showDetailSegue", sender: annotationView.annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.performSegue(withIdentifier: "showDetailSegue", sender: view.annotation)
        view.image = UIImage(named: "pin2-selected.png")
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let annotation = view.annotation as? Pin {
            view.image = getPinImage(annotation, isSelected: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        lastLocation = locations.last! as CLLocation
        
        if (shouldCenter) {
            checkIfIsInBrazil(lastLocation!) {
                MapAndLocationUtils.centerMapOnUser(location: self.lastLocation!, map: self.mapView)
                self.shouldCenter = false
            }
        }
        
    }
    
    func getPinImage(_ pin: Pin, isSelected: Bool) -> UIImage? {
        if isSelected {
            return UIImage(named: "pin2-selected")
        } else {
            if pin.buildings.count > 1 {
                return UIImage(named: "pin2-multiple")
            } else {
                return UIImage(named: "pin2")
            }
        }
    }
    
    // ----------------------------------------------------------
    // MARK: TableView Delegates
    // ----------------------------------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.buildingsToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        let building = self.buildingsToShow[indexPath.row]
        
        cell.textLabel?.text = "\(building.ufrgsCode) - \(building.name)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedBuilding = self.buildingsToShow[indexPath.row]
        
        self.pinsToShow.removeAll()
        
        let pin = makePin(selectedBuilding)
        pinsToShow.append(pin)
        self.putPinsOnMap()
            
        MapAndLocationUtils.centerMapOnUser(location: CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude), map: mapView)
        
        searchView.isHidden = true
        textFieldInsideSearchBar!.text = selectedBuilding.name
        dismissKeyboard()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46.0
    }
    
    // ----------------------------------------------------------
    // MARK: Search Delegates
    // ----------------------------------------------------------
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchView.isHidden = false
        pinsToShow = allPins
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        buildingsToShow = allBuildings
        searchView.isHidden = true
        putPinsOnMap()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        pinsToShow = allPins
        buildingsToShow = allBuildings
        tableView.reloadData()
        dismissKeyboard()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        buildingsToShow = dbManager.getBuildingsByNameOrNumber(query: searchText)
        tableView.reloadData()
    }
    
    // ----------------------------------------------------------
    // MARK: Configuration Functions
    // ----------------------------------------------------------
    
    func configureSearchBar() {
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.setValue("Cancelar", forKey:"_cancelButtonText")
        textFieldInsideSearchBar = (searchBar.value(forKey: "searchField") as? UITextField)!

        textFieldInsideSearchBar!.textColor = .white
        
        textFieldInsideSearchBar!.attributedPlaceholder = NSAttributedString(
            string: "Nome ou número do prédio",
            attributes: [.foregroundColor: UIColor.lightText]
        )
        
        if let clearButton = textFieldInsideSearchBar!.value(forKey: "clearButton") as? UIButton {
            
            for state in [UIControl.State.normal, UIControl.State.highlighted, UIControl.State.selected] {
                clearButton.setImage(UIImage(named: "clearIcon"), for: state)
            }
            
            clearButton.alpha = 0.7
        }
        
        let glassIconView = textFieldInsideSearchBar!.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = .white
        
        if let font = UIFont(name: "AvenirNext-Medium", size: 17.0) {
            textFieldInsideSearchBar!.font = font
        }
        
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func configureButton() {
        btnView.layer.cornerRadius = 4.0
        LayoutUtils.setSearchCancelButtonColor(color: .white)
    }
    
    func configureMapView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        mapView.addGestureRecognizer(tap)
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // set initial position for the mapView
        let rsCenter = CLLocationCoordinate2D(latitude: -29.585033, longitude: -52.442913)
        let region = MKCoordinateRegion(center: rsCenter, latitudinalMeters: 800000, longitudinalMeters: 800000)
        mapView.setRegion(region, animated: true)
    }
    
    func configureLocationManager() {
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    // ----------------------------------------------------------
    // MARK: Auxiliar Functions
    // ----------------------------------------------------------
    
    @IBAction func centerUserLocation(_ sender: Any) {
        if lastLocation != nil {
            MapAndLocationUtils.centerMapOnUser(location: lastLocation!, map: mapView)
        }
    }
    
    @IBAction func changeLayer(_ sender: Any) {
        let mapType = mapView.mapType
        
        switch (mapType) {
        case .standard:
            mapView.mapType = .hybrid
        case .hybrid:
            mapView.mapType = .standard
        default:
            mapView.mapType = .standard
        }
    }
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    @objc func calloutTapped(sender : UITapGestureRecognizer) {
        let annotation = (sender.view as! MKAnnotationView).annotation
        self.performSegue(withIdentifier: "showDetailSegue", sender: annotation)
    }
    
    func putPinsOnMap() {
        mapView.removeAnnotations(mapView.annotations)
        
        for pin in self.pinsToShow {
            mapView.addAnnotation(pin)
        }
    }
    
    func showPrivacyPolicyIfNeeded() {
        
        let key = "didShowPolicy"
        
        if UserDefaults.standard.object(forKey: key) == nil {
            
            let vc = PrivacyPolicyView()
            
            PopupController
                .create(self)
                .customize(
                    [
                        .animation(.fadeIn),
                        .scrollable(false),
                        .backgroundStyle(.blackFilter(alpha: 0.5)),
                    ]
                )
                .didShowHandler { popup in
                    self.tableView.isScrollEnabled = false
                }
                .didCloseHandler { _ in
                    self.tableView.isScrollEnabled = true
                    UserDefaults.standard.set(true, forKey: key)
                }
                .show(vc)

        }
        
    }
    
    func checkIfIsInBrazil(_ location: CLLocation, _ positiveCompletion: @escaping () -> ()) {
        let geocoder = CLGeocoder()

        // Geocode Location
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil {
                if let placemarks = placemarks, let placemark = placemarks.first {
                    if let iso = placemark.isoCountryCode {
                        if iso == "BR" {
                            positiveCompletion()
                        }
                    }
                }
            }
        }
    }
    
}

