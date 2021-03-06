//
//  TrackListTableViewController.swift
//  RunningRhythm
//
//  Created by Boris Chu on 11/28/17.
//  Copyright © 2017 Cinder Capital. All rights reserved.
//

import UIKit
import Alamofire

public var first: Bool?

class TrackListTableViewController: UITableViewController {
    
    var trackList = [SPTPlaylistTrack]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.title = playlist?.name
        getTracks(completion: {
            self.tableView.reloadData()
        })
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
        return self.trackList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tracks", for: indexPath)
        cell.textLabel?.text = trackList[indexPath.row].name
        cell.contentView.backgroundColor = SettingsViewController().UIColorFromHex(rgbValue: backgroundHex, alpha: 1);
        cell.textLabel?.textColor = SettingsViewController().UIColorFromHex(rgbValue: text, alpha: 1);
        return cell
    }
    
    private func getTracks(completion : @escaping ()->()) {
        let stringFromUrl =  playlist?.uri.absoluteString
        let uri = URL(string: stringFromUrl!)
        // use SPTPlaylistSnapshot to get all the playlists
        SPTPlaylistSnapshot.playlist(withURI: uri, accessToken: SPTAuth.defaultInstance().session.accessToken!) { (error, snap) in
            if let s = snap as? SPTPlaylistSnapshot {
                // get the tracks for each playlist
                for track in s.firstTrackPage.items {
                    if let thistrack = track as? SPTPlaylistTrack {
                        if thistrack.identifier != nil {
                            self.trackList.append(thistrack)
                        }
                    }
                }
            }
            completion()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showPlayer" {
            let destination = segue.destination as? MusicPlayerViewController;
            destination?.track = trackList[(tableView.indexPathForSelectedRow?.row)!]
            destination?.trackList = trackList
            destination?.first = true
            trackIds = []
        }
    }

}
