//
//  TableViewController.swift
//  Protein
//
//  Created by Antoine LEBLANC on 12/10/17.
//  Copyright © 2017 Antoine LEBLANC. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var ligands = [Ligand]()
    var filteredLigands = [Ligand]()
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK : Search settings
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Proteins"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering() {
            return filteredLigands.count
        }
        return ligands.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ligand", for: indexPath) as! LigandTableViewCell
        var from: Ligand
        if isFiltering() {
            from = filteredLigands[indexPath.row]
        } else {
            from = ligands[indexPath.row]
        }
        cell.name.text = from.name
        cell.downloaded.isHidden = from.isDownloaded ? false : true
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ligands[indexPath.row].isDownloaded == false {
            downloadLigand(at: indexPath.row)
        }
        tableView.reloadData()
        performSegue(withIdentifier: "showDetails", sender: indexPath)
    }
    
    // MARK: - Download
    
    func downloadLigand(at index: Int) {
        var name: String
        if isFiltering() {
            name = filteredLigands[index].name
        } else {
            name = ligands[index].name
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        guard let url = URL(string: "https://files.rcsb.org/ligands/download/\(name).cif"), let data = try? String(contentsOf: url, encoding: .utf8)
        else {
            print("Download: no data reached")
            
            let alert = UIAlertController(title: "Download failed", message: "Ligand '\(name)' hos not been downloaded", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            return
        }
            
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        let ligand = parseLigand(file: data, for: name)
        if isFiltering() {
            filteredLigands[index] = ligand
            if let indexLigand = ligands.index(where: {$0.name == ligand.name}) {
                ligands[indexLigand] = ligand
            }
        } else {
            ligands[index] = ligand
        }
    }
    
    // MARK: - Parsing
    
    func parseLigand(file: String, for name: String) -> Ligand {
        var ligand = Ligand(fromName: name)
        let lines = file.components(separatedBy: "\n")
        var hash = 0
        
        for line in lines {
            if line.contains("#") {
                hash += 1
            }
            if hash == 1 {
                if line.contains("_chem_comp.name") {
                    ligand.fullname = line.components(separatedBy: " ").filter{ !$0.isEmpty }.dropFirst().joined(separator: " ")
                } else if line.contains("_chem_comp.type") {
                    ligand.type = line.components(separatedBy: " ").filter{ !$0.isEmpty }[1]
                } else if line.contains("_chem_comp.formula ") {
                    ligand.formula = line.components(separatedBy: " ").filter{ !$0.isEmpty }.dropFirst().joined(separator: " ")
                }
            } else if hash == 2 {
                if line.contains(ligand.name) {
                    let components = line.components(separatedBy: " ").filter{ !$0.isEmpty }
                    let id = components[1]
                    let name = components[3]
                    if let x = Float(components[12]), let y = Float(components[13]), let z = Float(components[14]) {
                        let atom = Atom(id: id, name: name, x: x, y: y, z: z)
                        ligand.atoms.append(atom)
                    }
                }
            } else if hash == 3 {
                if line.contains(ligand.name) {
                    let components = line.components(separatedBy: " ").filter{ !$0.isEmpty }
                    if let atomIndex1 = ligand.atoms.index(where: {$0.id == components[1]}),
                        let atomIndex2 = ligand.atoms.index(where: {$0.id == components[2]}) {
                        ligand.atoms[atomIndex1].connect.append(ligand.atoms[atomIndex2])
                    }
                }
            }
        }
        
        ligand.isDownloaded = true

        return ligand
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDetails", let destination = segue.destination as? DetailsViewController {
            if let index = sender as? IndexPath {
                if isFiltering() {
                    destination.ligand = filteredLigands[index.row]
                } else {
                    destination.ligand = ligands[index.row]
                }
            }
        }
    }
}


extension TableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredLigands = ligands.filter({( ligand : Ligand) -> Bool in
            return ligand.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

