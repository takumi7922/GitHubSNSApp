//
//  RankViewController.swift
//  NPB
//
//  Created by 小松拓海 on 2023/05/10.
//

import UIKit
import Alamofire
import Kanna

class RankViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{
    
    private let cellId = "cellId"
    private var teams = [String]()

    
    @IBOutlet weak var ceTableView: UITableView!
    @IBOutlet weak var paTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.fetchBaseballInfo(url: "https://npb.jp/")
        
        ceTableView.dataSource = self
        ceTableView.delegate = self
        paTableView.delegate = self
        paTableView.dataSource = self
        ceTableView.register(UINib(nibName: "RankTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        paTableView.register(UINib(nibName: "RankTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            print(self.teams)
            self.ceTableView.reloadData()
            self.paTableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    
    
    func fetchBaseballInfo(url:String) -> Void {

            //ここに処理
            AF.request(url).responseString { response in
                        if let html = response.value {
                            if let doc = try? HTML(html: html, encoding: .utf8) {
                                // 牛丼のサイズをXpathで指定
                                self.teams = [String]()
                                for team in doc.xpath("//span[@class='hide_pc']") {
                                    self.teams.append(team.text ?? "")
                                }
                                
                                
                            }
                        }
                    }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ceTableView {
            print(self.teams.count / 2)
            return self.teams.count / 2
        } else{
            print(self.teams.count / 2)
            return self.teams.count / 2
           
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == ceTableView {
            let cell = ceTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RankTableViewCell
            
            cell.teamNameLabel.text = self.teams[indexPath.row]
            
            return cell
        }else{
            let cell = ceTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RankTableViewCell
            
            cell.teamNameLabel.text = self.teams[indexPath.row]
            
            return cell
        }
            

        
    }
    
}

