//
//  SearchViewController.swift
//  Weather
//
//  Created by Pavitram on 20/04/22.
//

import UIKit

class SearchViewController:UIViewController {
    
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var cities_tableview: UITableView!
    
    private var cities:Cities = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configuration()
        //fetchCities(query:"London")
    }
    
    private func configuration() {
        let nib = UINib(nibName:SearchCityCell.identifier, bundle: nil)
        cities_tableview.register(nib, forCellReuseIdentifier: SearchCityCell.identifier)
        // Config SearchBar
        searchbar.delegate = self
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier:SearchCityCell.identifier, for: indexPath) as? SearchCityCell {
            cell.lbl_name.text = cities[indexPath.row].name
            cell.lbl_address.text = "\(cities[indexPath.row].state),\(cities[indexPath.row].country)"
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

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city = cities[indexPath.row]
        if !CitiesDataManager().isFound(city:city) {
            CitiesDataManager().writeData(city: city)
            CitiesDataManager().saveCurrentCity(city:city)
        }
        navigationController?.popViewController(animated: true)
    }
}

extension SearchViewController {
    private func fetchCities(query:String) {
        let final_url_str = BASE_URL + fGEO_LOC + "?" + kAccess_key + "=" + API_KEY + "&" + kQuery + "=" + query + "&" + kLimit + "=" + "5"
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
                        let cities = try JSONDecoder().decode(Cities.self, from: data)
                        self?.cities = cities
                        self?.cities_tableview.reloadData()
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

extension SearchViewController:UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count <= 0 {
            cities.removeAll()
            cities_tableview.reloadData()
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.resignFirstResponder()
        if searchbar.text?.count ?? 0 > 0 {
            fetchCities(query:searchbar.text ?? "")
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    }
}

extension UIViewController {
    func showError(_ message:String,completion:@escaping (() -> Void)) {
        let alertVC = UIAlertController(title:"Error", message: message, preferredStyle: .alert)
        let retry = UIAlertAction(title:"Retry", style: .default) { [weak self] action in
            self?.dismiss(animated: true, completion: {
                completion()
            })
        }
        alertVC.addAction(retry)
        present(alertVC, animated: true, completion: nil)
    }
}
