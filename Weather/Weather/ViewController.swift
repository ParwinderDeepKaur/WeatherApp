//
//  ViewController.swift
//  Weather
//
//  Created by Pavitram on 20/04/22.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var img_weather: UIImageView!
    @IBOutlet weak var lbl_weather: UILabel!
    @IBOutlet weak var lbl_rise_time: UILabel!
    @IBOutlet weak var lbl_set_time: UILabel!
    @IBOutlet weak var lbl_pressure: UILabel!
    @IBOutlet weak var lbl_humidity: UILabel!
    @IBOutlet weak var lbl_weather_name: UILabel!
    let locationManager = CLLocationManager()
    
    private var weather:Weather? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchData()
    }
    
    private func fetchData() {
        if let city = CitiesDataManager().getCurrentCity() {
            fetchWeatherOfLocation(lon: city.lon, lat: city.lat)
        } else {
            checkLocationStatus()
        }
    }
    
    private func updateUI(weather:Weather) {
        img_weather.setImage(url:IMG_URL + "\(weather.weather?.first?.icon ?? "")@2x.png", placeholderImage: nil)
        let rise = Date(timeIntervalSince1970:TimeInterval(weather.sys?.sunrise ?? 0))
        let set = Date(timeIntervalSince1970:TimeInterval(weather.sys?.sunset ?? 0))
        lbl_rise_time.text = rise.string()
        lbl_set_time.text = set.string()
        lbl_pressure.text = "\(weather.main?.pressure ?? 0) hPa"
        lbl_humidity.text = "\(weather.main?.humidity ?? 0) %"
        let temp = (weather.main?.feelsLike ?? 0) - 273.15
        lbl_weather.text = "\(Int(temp))°C"
        lbl_weather_name.text = "\(weather.name ?? "")"
    }
}

extension ViewController:CLLocationManagerDelegate {
    func checkLocationStatus() {
        // Get the current location permissions
        let status = locationManager.authorizationStatus
        // Handle each case of location permissions
        switch status {
        case .authorizedAlways: break
        case .authorizedWhenInUse: break
        case .denied:
            locationManager.requestWhenInUseAuthorization()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            fatalError()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.requestLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        locationManager.stopUpdatingLocation()
        fetchWeatherOfLocation(lon: locValue.longitude, lat: locValue.latitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        selectLocationPop()
    }
    
    private func selectLocationPop() {
        showError("Please search and select a city.") { [weak self] in
            if let addVC = self?.storyboard?.instantiateViewController(identifier:"SearchViewController") as? SearchViewController {
                self?.navigationController?.pushViewController(addVC, animated: true)
            }
        }
    }
}

extension ViewController {
    private func fetchWeatherOfLocation(lon:Double,lat:Double) {
        let final_url_str = BASE_URL + fWEATHER_LOC + "?" + kAccess_key + "=" + API_KEY + "&" + kLongitude + "=" + "\(lon)" + "&" + kLatitude + "=" + "\(lat)"
        guard let url = URL(string:final_url_str)  else { return }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error.localizedDescription, completion: {
                        //Do Nothing
                    })
                } else if let data = data {
                    do {
                        let weather = try JSONDecoder().decode(Weather.self, from: data)
                        self?.weather = weather
                        self?.updateUI(weather: weather)
                    } catch {
                        self?.showError("Something went wrong!", completion: {
                            //Do Nothing
                        })
                    }
                } else {
                    self?.showError("Something went wrong!", completion: {
                        //Do Nothing
                    })
                }
            }
        }
        task.resume()
    }
}

extension Date {
    func string() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: self)
    }
}
