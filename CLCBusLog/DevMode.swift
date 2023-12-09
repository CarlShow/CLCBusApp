//
//  DevMode.swift
//  CLCBusLog
//
//  Created by CARL SHOW on 11/16/23.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
class DevMode: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet var drag: UIPanGestureRecognizer!
    @IBOutlet var tempView: UIView!
    @IBOutlet weak var stepir: UIStepper!
    @IBOutlet weak var busView: UITableView!
    @IBOutlet weak var inserterView: UITableView!
    @IBOutlet weak var commitButton: UIButton!
    var tenacity = (busTendancy.Null, "")
    var busOptions = [String]()
    var target = -1
    
    override func viewDidLoad()
    {
        busView.dataSource = self
        busView.delegate = self
        busView.layer.cornerRadius = 20
        inserterView.dataSource = self
        inserterView.delegate = self
        inserterView.layer.cornerRadius = 20
        commitButton.layer.cornerRadius = 20
        tempView.layer.cornerRadius = 20
        stepir.layer.cornerRadius = 20
        stepir.maximumValue = Double(ViewController.busBuilder.count)
        stepir.value = Double(ViewController.mid)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == busView
        {
            return ViewController.busBuilder.count + 3
        }
        else
        {
            return busOptions.count + 2
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == busView
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
                cell.layer.cornerRadius = 20
                cell.busSlotA.layer.cornerRadius = 20
                cell.busSlotB.layer.cornerRadius = 20
                cell.pointer = indexPath.row
                var cur = (busTendancy.Null, "", busTendancy.Null, "")
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
                cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
                cell.layer.cornerRadius = 20
                return cell
            }
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bus") as! customBus
            cell.layer.cornerRadius = 20
            cell.pointer = indexPath.row
            switch indexPath.row
            {
            case 0:
                cell.impliedBus.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2992400085)
                cell.impliedName.text = ""
            case 1:
                cell.impliedBus.backgroundColor = #colorLiteral(red: 0.9132722616, green: 0.2695424259, blue: 0.4834814668, alpha: 0.6500318878)
                cell.impliedName.text = ""
            default:
                cell.impliedBus.backgroundColor = #colorLiteral(red: 0, green: 0.9909093976, blue: 0, alpha: 0.795838648)
                cell.impliedName.text = busOptions[indexPath.row - 2]
            }
            cell.impliedBus.layer.cornerRadius = 20
            cell.backgroundColor = #colorLiteral(red: 0, green: 0.9909093976, blue: 0, alpha: 0)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row >= 2 && tableView == inserterView
        {
            target = indexPath.row - 2
        }
    }
    @IBAction func didDrag(_ sender: UIPanGestureRecognizer)
    {
        let translation = sender.location(in: view)
        if sender.state.rawValue == 1
        {
            if inserterView.frame.contains(translation)
            {
                var tries = 0
                for x in inserterView.visibleCells
                {
                    let y = x as! customBus
                    let xCheck = translation.x - inserterView.frame.minX
                    let yCheck = translation.y - inserterView.frame.minY + inserterView.bounds.minY
                    if(x.frame.contains(CGPoint(x: xCheck, y: yCheck)))
                    {
                        tempView.isHidden = false
                        tempView.center = translation
                        UIView.animate(withDuration: 0.20, animations: { [self] in
                            tempView.frame.size.width = 75
                            tempView.frame.size.height = 75
                            tempView.center = translation
                        })
                        tempView.backgroundColor = y.impliedBus.backgroundColor
                        if y.pointer == 0
                        {
                            tenacity.0 = busTendancy.Null
                            tenacity.1 = ""
                        }
                        else if y.pointer == 1
                        {
                            tenacity.0 = busTendancy.Occupied
                            tenacity.1 = ""
                        }
                        else
                        {
                            tenacity.0 = busTendancy.Present
                            tenacity.1 = busOptions[y.pointer-2]
                        }
                        break
                    }
                    tries += 1
                }
            }
        }
        else if sender.state.rawValue == 2
        {
            tempView.center = translation
        }
        else
        {
            if busView.frame.contains(translation)
            {
                for x in busView.visibleCells
                {
                    let xCheck = translation.x - busView.frame.minX
                    let yCheck = translation.y - busView.frame.minY + busView.bounds.minY
                    if(x.frame.contains(CGPoint(x: xCheck, y: yCheck)) && !tempView.isHidden)
                    {
                        tempView.center = translation
                        var target = (0, false)
                        if let y = x as? customCell
                        {
                            if(translation.x < busView.frame.midX)
                            {
                                target.0 = y.pointer
                                target.1 = false
                            }
                            else
                            {
                                target.0 = y.pointer
                                target.1 = true
                            }
                            if target.0 <= ViewController.mid
                            {
                                target.0 -= 1
                            }
                            else
                            {
                                target.0 -= 2
                            }
                            if target.1
                            {
                                ViewController.busBuilder[target.0].2 = tenacity.0
                                ViewController.busBuilder[target.0].3 = tenacity.1
                            }
                            else
                            {
                                ViewController.busBuilder[target.0].0 = tenacity.0
                                ViewController.busBuilder[target.0].1 = tenacity.1
                            }
                            var ySmidge = 0.0
                            if y.pointer > ViewController.mid
                            {
                                ySmidge = busView.frame.minY - busView.bounds.minY + y.stacker.frame.minY + 12
                            }
                            else
                            {
                                ySmidge = busView.frame.minY - busView.bounds.minY + y.stacker.frame.minY + y.busSlotA.frame.height
                            }
                            let yMod = ySmidge + CGFloat(y.pointer - 1) * y.frame.height
                            UIView.animate(withDuration: 0.30, animations: { [self] in
                                tempView.frame.size.width = y.busSlotA.frame.width
                                tempView.frame.size.height = y.busSlotB.frame.height
                                tempView.backgroundColor = tempView.backgroundColor?.withAlphaComponent(1.0)
                                if translation.x < busView.frame.midX
                                {
                                    tempView.center = CGPoint(x: y.busSlotA.center.x + busView.frame.minX + y.stacker.frame.minX, y: yMod)
                                }
                                else
                                {
                                    tempView.center = CGPoint(x: y.busSlotB.center.x + busView.frame.minX + y.stacker.frame.minX, y: yMod)
                                }
                            }, completion: { [self]_ in
                                busView.reloadData()
                                UIView.animate(withDuration: 0.3, animations: { [self] in
                                    tempView.backgroundColor = tempView.backgroundColor?.withAlphaComponent(0.0)
                                }, completion: { [self]_ in
                                    tempView.isHidden = true
                                    tempView.frame.origin = CGPoint(x: -75, y: -75)
                                    tempView.frame.size = CGSize()
                                })
                            })
                        }
                        else
                        {
                            UIView.animate(withDuration: 0.20, animations: { [self] in
                                tempView.frame.size = CGSize()
                                tempView.center = translation
                            }, completion: { [self]_ in
                                tempView.isHidden = true
                                tempView.frame.origin = CGPoint(x: -75, y: -75)
                            })
                        }
                    }
                }
            }
            else
            {
                UIView.animate(withDuration: 0.20, animations: { [self] in
                    tempView.frame.size.width = 0
                    tempView.frame.size.height = 0
                    tempView.center = translation
                }, completion: { [self]_ in
                    tempView.isHidden = true
                    tempView.frame.origin = CGPoint(x: -75, y: -75)
                })
            }
        }
    }
    @IBAction func addBus(_ sender: Any) 
    {
        let alert = UIAlertController(title: "Add a bus:", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField{
            (textField) in
            textField.placeholder = "Bus Number"
        }
        alert.addAction(UIAlertAction(title: "Add", style: UIAlertAction.Style.default, handler: { UIAlertAction in
            self.busOptions.append(alert.textFields![0].text!)
            self.inserterView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel))
        self.present(alert, animated: true)
    }
    @IBAction func deleteBus(_ sender: Any) 
    {
        if target >= 0
        {
            let alert = UIAlertController(title: "Are you sure you want to delete bus \(busOptions[target])?", message: "", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Remove", style: UIAlertAction.Style.default, handler: { UIAlertAction in
                self.busOptions.remove(at: self.target)
                self.target = -1
                self.inserterView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel))
            self.present(alert, animated: true)
        }
        else
        {
            let alert = UIAlertController(title: "No bus selected to delete", message: "Make sure to click on a bus.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default))
            self.present(alert, animated: true)
        }
    }
    @IBAction func addRow(_ sender: Any) 
    {
        ViewController.busBuilder.append((busTendancy.Null, "", busTendancy.Null, ""))
        busView.reloadData()
        stepir.maximumValue = Double(ViewController.busBuilder.count)
    }
    @IBAction func removeRow(_ sender: Any) 
    {
        if ViewController.busBuilder.count > 0
        {
            if ViewController.busBuilder.count == ViewController.mid
            {
                ViewController.mid -= 1
            }
            ViewController.busBuilder.removeLast()
            busView.reloadData()
        }
        else
        {
            let alert = UIAlertController(title: "Cannot remove row", message: "There are currently no rows to delete", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default))
            self.present(alert, animated: true)
        }
        stepir.maximumValue = Double(ViewController.busBuilder.count)
    }
    @IBAction func stepMid(_ sender: UIStepper)
    {
        ViewController.mid = Int(sender.value)
        busView.reloadData()
    }
    @IBAction func commit(_ sender: Any) 
    {
        let div = Firestore.firestore().collection("busLog").document("info")
        var listOne = [String]()
        var listTwo = [String]()
        var nameOne = [String]()
        var nameTwo = [String]()
        for x in ViewController.busBuilder
        {
            nameOne.append(x.1)
            nameTwo.append(x.3)
            switch x.0
            {
            case busTendancy.Present:
                listOne.append("p")
            case busTendancy.Occupied:
                listOne.append("o")
            default:
                listOne.append("")
            }
            switch x.2
            {
            case busTendancy.Present:
                listTwo.append("p")
            case busTendancy.Occupied:
                listTwo.append("o")
            default:
                listTwo.append("")
            }
        }
        div.setData(["inf1" : listOne, "inf2" : listTwo, "num1" : nameOne, "num2" : nameTwo, "median" : ViewController.mid])
        performSegue(withIdentifier: "coolio", sender: Any?.self)
    }
    @IBAction func returnToSender(_ sender: Any) 
    {
        performSegue(withIdentifier: "coolio", sender: Any?.self)
    }
}
