//
//  ManageViewController.swift
//  Weather
//
//  Created by Pavitram on 21/04/22.
//

import UIKit

class ManageViewController: UIViewController {
    private var cities:Cities = []
    @IBOutlet weak var cities_tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configuration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchSaveCities()
        
    }
    
    private func fetchSaveCities() {
        cities = CitiesDataManager().getData()
        cities_tableview.reloadData()
    }
    
    private func configuration() {
        let nib = UINib(nibName:SearchCityCell.identifier, bundle: nil)
        cities_tableview.register(nib, forCellReuseIdentifier: SearchCityCell.identifier)
    }
    
}
extension ManageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier:SearchCityCell.identifier, for: indexPath) as? SearchCityCell {
            cell.lbl_name.text = cities[indexPath.row].name
            cell.lbl_address.text = "\(cities[indexPath.row].state),\(cities[indexPath.row].country)"
            let current_city = CitiesDataManager().getCurrentCity()
            if current_city?.name == cities[indexPath.row].name && current_city?.state == cities[indexPath.row].state && current_city?.country == cities[indexPath.row].country {
                cell.accessoryType = .checkmark
            } else  {
                cell.accessoryType = .none
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
}

extension ManageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let current_city = CitiesDataManager().getCurrentCity()
        if current_city?.name == cities[indexPath.row].name && current_city?.state == cities[indexPath.row].state && current_city?.country == cities[indexPath.row].country {
            CitiesDataManager().clearCurrentCity()
        } else  {
            CitiesDataManager().saveCurrentCity(city: cities[indexPath.row])
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            CitiesDataManager().delete(city: cities[indexPath.row])
            cities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
