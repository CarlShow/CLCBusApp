//
//  ViewController.swift
//  CLCBusLog
//
//  Not Created by CARL SHOW on 10/31/23. >:)
//

import UIKit
import FirebaseCore
import FirebaseFirestore
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var busView: UITableView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    static var mid = 0
    static var busBuilder = [(busTendancy, String, busTendancy, String)]()
    var canUpdate = true
    override func viewDidLoad()
    {
        busView.layer.cornerRadius = 20
        updateButton.layer.cornerRadius = 20
        editButton.layer.cornerRadius = 20
        fetch()
        busView.dataSource = self
        busView.delegate = self
        super.viewDidLoad()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ViewController.busBuilder.count + 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch indexPath.row
        {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Frontmost")!
            cell.layer.cornerRadius = 20
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3019238946)
            return cell
        case ViewController.mid + 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Middlemost")!
            cell.layer.cornerRadius = 20
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3019238946)
            return cell
        case ViewController.busBuilder.count + 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Endmost")!
            cell.layer.cornerRadius = 20
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3019238946)
            return cell
        case _:
            let cell = tableView.dequeueReusableCell(withIdentifier: "busLane") as! customCell
            var cur = (busTendancy.Null, "", busTendancy.Null, "")
            cell.busSlotA.layer.cornerRadius = 20
            cell.busSlotB.layer.cornerRadius = 20
            if indexPath.row < ViewController.mid + 1
            {
                cur = ViewController.busBuilder[indexPath.row - 1]
            }
            else
            {
                cur = ViewController.busBuilder[indexPath.row - 2]
            }
            switch(cur.0)
            {
            case busTendancy.Null:
                cell.busSlotA.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2992400085)
                break
            case busTendancy.Occupied:
                cell.busSlotA.backgroundColor = #colorLiteral(red: 0.9132722616, green: 0.2695424259, blue: 0.4834814668, alpha: 0.6500318878)
                break
            case busTendancy.Present:
                cell.busSlotA.backgroundColor = #colorLiteral(red: 0, green: 0.9909093976, blue: 0, alpha: 0.795838648)
                break
            case _:
                print("Catastrophic error! DIV0 OF DUPLE FAILED IN CELL INSTANCIATION")
            }
            cell.busNameA.text = cur.1
            switch(cur.2)
            {
            case busTendancy.Null:
                cell.busSlotB.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2992400085)
                break
            case busTendancy.Occupied:
                cell.busSlotB.backgroundColor = #colorLiteral(red: 0.9132722616, green: 0.2695424259, blue: 0.4834814668, alpha: 0.6500318878)
                break
            case busTendancy.Present:
                cell.busSlotB.backgroundColor = #colorLiteral(red: 0, green: 0.9909093976, blue: 0, alpha: 0.795838648)
                break
            case _:
                print("Catastrophic error! DIV1 OF DUPLE FAILED IN CELL INSTANCIATION")
            }
            cell.busNameB.text = cur.3
            cell.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3019238946)
            cell.layer.cornerRadius = 20
            return cell
        }
    }
    @IBAction func update(_ sender: Any)
    {
        if !canUpdate
        {
            let tempNudge = updateButton.center
            print(updateButton.center)
            updateButton.center.x += CGFloat(Int.random(in: -20...20))
            updateButton.center.y += CGFloat(Int.random(in: -20...20))
            print(updateButton.center)
            UIView.animate(withDuration: 0.1, animations: {
                self.updateButton.center = tempNudge
            })
        }
        else
        {
            fetch()
            updateButton.backgroundColor = #colorLiteral(red: 0.100215964, green: 0.02514740638, blue: 0.02612011321, alpha: 0.1964783188)
            updateButton.titleLabel?.text = "..."
            canUpdate = false
            UIView.animate(withDuration: 10, animations: { [self] in
                updateButton.backgroundColor = #colorLiteral(red: 0.009437207133, green: 0.03562513739, blue: 0.1909909546, alpha: 0.4963814196)
            }, completion: { [self] _ in
                UIView.animate(withDuration: 0.2, animations: {
                    self.updateButton.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                })
                updateButton.titleLabel?.text = "Update"
                canUpdate = true
            })
        }
    }
    func updateApparatus()
    {
        
    }
    func fetch()
    {
        let prot = ViewController.busBuilder
        ViewController.busBuilder.removeAll()
        ViewController.mid = 0
        let div = Firestore.firestore().collection("busLog").document("info")
        div.getDocument { (doc, err) in
            guard err == nil
            else { print("failed to substantiate Firestore: \(String(describing: err))"); return }
            if let val = doc, ((doc?.exists) != nil)
            {
                var numA = [String]()
                var numB = [String]()
                var tenA = [busTendancy]()
                var tenB = [busTendancy]()
                let data = val.data()
                var r = 0
                for d in data!
                {
                    switch d.key
                    {
                    case "num1":
                        for v in d.value as! [String]
                        {
                            numA.append(v)
                        }
                    case "num2":
                        for v in d.value as! [String]
                        {
                            numB.append(v)
                        }
                    case "inf1":
                        for v in d.value as! [String]
                        {
                            switch v
                            {
                            case "p":
                                tenA.append(busTendancy.Present)
                            case "o":
                                tenA.append(busTendancy.Occupied)
                            case _:
                                tenA.append(busTendancy.Null)
                            }
                        }
                    case "inf2":
                        for v in d.value as! [String]
                        {
                            switch v
                            {
                            case "p":
                                tenB.append(busTendancy.Present)
                            case "o":
                                tenB.append(busTendancy.Occupied)
                            case _:
                                tenB.append(busTendancy.Null)
                            }
                        }
                    case "median":
                        ViewController.mid = d.value as! Int
                    case _:
                        print("Alerta! Firestore is reading garbage data!")
                    }
                    r += 1
                }
                for x in 0...numA.count - 1
                {
                    if tenA[x] == busTendancy.Null && numA[x] != ""
                    {
                        numA[x] = ""
                    }
                    if tenB[x] == busTendancy.Null && numB[x] != ""
                    {
                        numB[x] = ""
                    }
                }
                if numA.count == numB.count && tenA.count == tenB.count && tenA.count == numA.count
                {
                    for x in 0...numA.count - 1
                    {
                        ViewController.busBuilder.append((tenA[x], numA[x], tenB[x], numB[x]))
                    }
                }
                else
                {
                    let alert = UIAlertController(title: "Unfinished update in progress", message: "Sorry, but a new update is in progress\n\nPlease wait before trying again.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default))
                    ViewController.busBuilder = prot
                    self.present(alert, animated: true)
                }
            }
            self.busView.reloadData()
        }
    }
}
