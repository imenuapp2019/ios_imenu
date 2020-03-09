//
//  MapViewController.swift
//  imenu_ios
//
//  Created by Eduardo Antonio Terrero Cabrera on 03/03/2020.
//  Copyright © 2020 Miguel Jaimes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
class MapViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var labelDT: UILabel!
    let locationManager = CLLocationManager ()
    let latitudinalMeters:Double = 1000
    let longitudinalMeters:Double = 1000
    var previousLocation:CLLocation?
    var collectionViewFlowLayout:UICollectionViewFlowLayout!
    
    @IBOutlet weak var restaurantsCollectionView: UICollectionView!
    @IBOutlet weak var roundedImageview: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func centerBtn(_ sender: Any) {
          centerViewOnUserLocation()
     }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        configureCollectionView()
        roundedImageview.layer.cornerRadius = roundedImageview.frame.height/2
        datafromServer()

         self.restaurantsCollectionView.reloadData()
    }
    
    
    var listRestaurants : [RestaurantElement] = [] {
           didSet {
               self.restaurantsCollectionView.reloadData()
           }
       }
    
                    //Network
    
    
    func datafromServer(){
           let apirest = APIManager()
           apirest.getAllRestaurants(completion: { result
               in
               let resultsRestaurants = result.first
               self.createListRestaurant(List: resultsRestaurants)
           })
       }
       
       func createListRestaurant(List list:Restaurant?){
           guard let listRestaurants = list else { return }
           let newRestaurant = listRestaurants.filter( {
               result in
               if result.imageURL == nil {
                   return false
               }else{
                   return true
               }
           })
           self.listRestaurants = newRestaurant
       }
    
    
    
    
    
    
                        //CollectionView
    
  func configureCollectionView () {
        restaurantsCollectionView.delegate = self
        restaurantsCollectionView.dataSource = self
        collectionViewFlowLayout = UICollectionViewFlowLayout ()
        collectionViewFlowLayout.itemSize = CGSize(width: 157, height: 146)
        collectionViewFlowLayout.scrollDirection = .horizontal
        restaurantsCollectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        listRestaurants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let imageDownloader = ImageDownloader()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RestaurantsInMapViewCell", for: indexPath) as! MapCollectionViewCell
        
    
        let restaurant = listRestaurants[indexPath.row]
        imageDownloader.downloader(URLString: restaurant.imageURL!, completion: { (image:UIImage?) in
                   cell.restaurantImage.image = image
               })
        cell.restaurantName.setTitle(restaurant.name, for: .normal)
        cell.latitud = restaurant.latitude
        cell.longitud = restaurant.longitude
        
        cell.contentView.layer.cornerRadius = 30
        cell.clipsToBounds = true
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DoWhenACellIsClicked(_:))))
        
        return cell
    }
    
    @objc func DoWhenACellIsClicked(_ sender: UITapGestureRecognizer) {
        
        let point:CGPoint = sender.location(in: restaurantsCollectionView)
        let index = restaurantsCollectionView.indexPathForItem(at:point)
        
        let cell = restaurantsCollectionView.cellForItem(at: index!) as! MapCollectionViewCell
        
        centerViewToRestaurantClicked(latitude: cell.latitud!, longitude: cell.longitud!)
    
       
       }
    
    
    
                    //Map / Location
    
    func centerViewToRestaurantClicked (latitude:Double, longitude:Double) {
    
         let point = CLLocationCoordinate2D( latitude: latitude,  longitude: longitude)
                   
                   let region = MKCoordinateRegion.init(center: point, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
                   mapView.setRegion(region, animated: true)
    }
    
    
    func centerViewOnUserLocation () {
          
        if let location = locationManager.location?.coordinate {
            
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
            mapView.setRegion(region, animated: true)
        }
      }
    
    func checkLocationServices () {
    //Check if location is enable on the device
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
            
        } else {
             //Alerta que el usuario debe activar la localización del dispositivo
        }
    }
    
    
    func setupLocationManager () {
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func checkLocationAuthorization () {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
           startTrackingUserLocation()
        case .denied:
             break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
             break
        case .restricted:
             break
        case .authorizedAlways:
             break
    
        @unknown default:
            print ("")
        }
        
    }
    func startTrackingUserLocation () {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
        
    }
    
    
//    func addMarkers (data: [ResponseRecyclePoint]) {
//
//           for items in data {
//               let point = CLLocationCoordinate2D( latitude: items.latitud!,  longitude: items.longitud!
//               )
//               let anotation = MKPointAnnotation()
//               anotation.coordinate = point
//               anotation.title = items.name
//               mapView.addAnnotation(anotation)
//           }
//
//       }
    
    func getCenterLocation (for mapView:MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
        
    }
}
extension MapViewController: CLLocationManagerDelegate {
    
    
    //mientras se mueve el usuario
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else {return}
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region =  MKCoordinateRegion.init(center: center , latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
//        mapView.setRegion(region, animated: true)
//
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

extension MapViewController:MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder ()
        
        guard let previousLocation = self.previousLocation else {return}
       
        guard center.distance(from: previousLocation) > 50 else {return}
        self.previousLocation = center
       
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else {return}
            
                if let _ = error {
                    
                    return
                }
            
            guard let placemark = placemarks?.first else {
                
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
           
            DispatchQueue.main.async {
                print ("Hola")
                self.labelDT.text = "\(streetNumber) \(streetName)"
                print(streetNumber)
            }
        }
    }
}
