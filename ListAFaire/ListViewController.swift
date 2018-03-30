//
//  ViewController.swift
//  ListAFaire
//
//  Created by Alexandre KESSLER on 30/03/2018.
//  Copyright © 2018 Alexandre KESSLER. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {

    
    //MARK: Outlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    //MARK: Properties
    let items = ["Pain", "Lait", "Jambon"]
    var items2 = [Item]()
    var filteredItems = [Item]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createItems()
        loadCheckLists()
    }
    
    func createItems() {
        for item in items{
            let newElement = Item(name: item)
            items2.append(newElement)
        }
    }
    
    var documentsDirectory: URL
    {
        get{
            return FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
        }
    }
    
    var dataFileUrl: URL
    {
        get{
            var url: URL = documentsDirectory.absoluteURL
            url.appendPathComponent("ToDoList")
            url.appendPathExtension("json")
            return url       }
        set{
            self.dataFileUrl = newValue
        }
    }
    
    func saveChecklists(){
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(items2)
        
        try? data?.write(to: dataFileUrl)
    }
    
    func loadCheckLists()
    {
        let decoder = JSONDecoder()
        let data = try? Data.init(contentsOf: self.dataFileUrl, options: .alwaysMapped)
        if data != nil{
            items2 = try! decoder.decode(Array<Item>.self, from: data!)
        }
    }
    
    //MARK: Actions
    
    @IBAction func addAction(_ sender: Any) {
        
        
        let alertController = UIAlertController(title: "DoIt", message: "New Item", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default){ (action) in
            
            if let textField = alertController.textFields?[0],
            textField.text != "" {
            let item = Item(name: textField.text!)
            self.items2.append(item)
            self.saveChecklists()
            self.tableView.reloadData()
            }
           
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func editAction(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        saveChecklists()
    }
}


extension ListViewController: UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredItems.count
        }
        return items2.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListViewCellIdentifier")
        let item: Item
        if isFiltering() {
            item = filteredItems[indexPath.row]
        } else {
            item = items2[indexPath.row]
        }
        
        //let item = items2[indexPath.row % items2.count]
        cell?.textLabel?.text = item.name //+ "(\(indexPath.row + 1))" permet d'ajouter un compteur
        cell?.accessoryType = item.checked ? .checkmark : .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        let sourceItem = items2.remove(at: sourceIndexPath.row)
        items2.insert(sourceItem, at: destinationIndexPath.row)
        saveChecklists()
    }
    
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = items2[indexPath.row % items2.count]
        item.checked = !item.checked
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        saveChecklists()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let itemIndex = items2.index(where: { $0 === filteredItems[indexPath.item]})!
        filteredItems.remove(at: indexPath.row)
        items2.remove(at: itemIndex)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        saveChecklists()
    }
    
    //MARK: UISearchBarDelegate
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchBar.text?.isEmpty ?? true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredItems = items2.filter({( item : Item) -> Bool in
            return item.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return !searchBarIsEmpty()
    }
    
}
