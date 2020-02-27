//
//  DishViewController.swift
//  imenu_ios
//
//  Created by Eduardo Antonio Terrero Cabrera on 22/01/2020.
//  Copyright © 2020 Miguel Jaimes. All rights reserved.
//

import UIKit

class DishViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    var menuSection:Int = 0
    let fetchData:FetchData = FetchData ()
    var globaldata:Array <Dish>!
    var cellClicked = 0
    
                            // Outlets
    @IBAction func backBtn(_ sender: Any) {
        performSegue(withIdentifier: "fromDishToMenu", sender: nil)
    }
    @IBOutlet weak var DishescollectionView: UICollectionView!
    @IBOutlet weak var resetCollectionViewButton: RoundButton!
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var totalDishesLabel: UILabel!
    @IBOutlet weak var currentDishShownLabel: UILabel!
    
                            //Actions
    @IBAction func resetCollectionViewButtonAction(_ sender: Any) {
             resetCollectionView()
       }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        globaldata = fetchData.fetchDishes(sectionIndex: menuSection)
        DishescollectionView.delegate = self
        DishescollectionView.dataSource = self
        resetButtonConfig()
        viewElementsConfig()
    }
  
    
  
    override func viewDidAppear(_ animated: Bool) {
        print(menuSection)
        //fetchData.setSection(section: menuSection)

       
    }
    // Número de celdas mostradas
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchData.fetchDishes(sectionIndex: menuSection  ).count
       }
       
       
       //Configuración de las diferentes celdas del collectionView
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
           collectionView.backgroundColor = .clear
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DishCollectionViewCell
            let data = fetchData.fetchDishes(sectionIndex: menuSection)
            cell.DishImageView.image = data [indexPath.row].image
            cell.dishNameLabel.text = data [indexPath.row].name
            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DoWhenACellIsClicked(_:))))
        
          
               return cell
       }
    
    @objc func DoWhenACellIsClicked(_ sender: UITapGestureRecognizer) {
       let location = sender.location(in: self.DishescollectionView)
       let indexPath = self.DishescollectionView.indexPathForItem(at: location)
        print(indexPath?.row)
        
       cellClicked = indexPath!.row
   print(cellClicked)
        
        
        performSegue(withIdentifier: "segueDetailDish", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                         
              if segue.identifier == "segueDetailDish"
              {
                  
                  
                  let destinationVC = segue.destination as! DetailDishViewController
                let data = globaldata
                destinationVC.dishNameProperty = (data?[cellClicked].name)!
                destinationVC.dishPriceProperty = ((data?[cellClicked].price)!)
                destinationVC.dishDescriptionProperty = (data?[cellClicked].description)!
                
    }}
   
    
    
    //Situación inicial de la vista
    private func viewElementsConfig () {
        totalDishesLabel.text = "\("/") \((String)(fetchData.fetchDishes(sectionIndex: menuSection).count) )"
        resetCollectionViewButton.isEnabled = false
    
    }
       
    private func resetCollectionView () {
        
        self.DishescollectionView?.scrollToItem(at: NSIndexPath(item: 0, section: 0) as IndexPath, at: .left, animated: true)
        }
    
    //Configuración del botón que reinicia el collectionView
    private func resetButtonConfig (){
      
        resetCollectionViewButton.setTitle(Literals.backBtn, for: .normal)
        resetCollectionViewButton.tintColor = MyColor.whiteColor
        resetCollectionViewButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
    }
    
    
    //Actualiza el texto del label que muestra la celda que está mostrando
    func updateCellShownAtTheMoment () {
        
        let visibleRect = CGRect(origin: DishescollectionView.contentOffset, size: DishescollectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath:IndexPath?
        visibleIndexPath = DishescollectionView.indexPathForItem(at: visiblePoint)
        
        if (visibleIndexPath == nil){
            
            }
            
        else    {
                    currentDishShownLabel.text = (String)(visibleIndexPath!.row + 1)
                }
    }
}




extension DishViewController: UIScrollViewDelegate {
   
    //Animación de las celdas del CollectionView
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        cell.alpha = 0
        UIView.animate(withDuration: 0.75) {
            cell.alpha = 1.0
        }
    }
    
    //Actualiza el texto del label que indica el número de la celda que se está mostrando, lo hace cada ve que se hace scroll en el collectionView. Además habilita y deshabilita el botón para volver al inicio del collectionView.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       updateCellShownAtTheMoment()
       
        if (Int)(currentDishShownLabel.text!)! >= 2 {
            resetCollectionViewButton.isEnabled = true
        }
        else {
             resetCollectionViewButton.isEnabled = false
        }
    }

    
    //Centra las celdas del collectionView
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let layout = DishescollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint (x: roundedIndex * (cellWidthIncludingSpacing) - ((scrollView.contentInset.left) - (-43)), y: -scrollView.contentInset.top
        )
        targetContentOffset.pointee = offset
    }
    
}
