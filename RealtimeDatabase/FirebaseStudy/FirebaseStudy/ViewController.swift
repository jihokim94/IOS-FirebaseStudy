//
//  ViewController.swift
//  FirebaseStudy
//
//  Created by 김지호 on 2021/08/06.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    var customers : [Customer] = []
    
    @IBOutlet weak var dataLabel: UILabel!
    
    @IBOutlet weak var numberOfCustomers: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 데이터 가져와서 레이블 업데이트
        updateLabel()
        
        //베이직 타입들 저장하기 키와 밸류로!!
        //        saveBasicTypes()
        
        //오브젝트 형태로 저장하기
        //        saveCustomers()
        
        // Read Objects
                fetchCustomers()
        
        // update
        //        updateBasicTypes()
        // delete
        //        deleteBasicTypes()
    }
    
    
    // 데이터베이스에서 데이터를 읽거나 쓰려면 FIRDatabaseReference 인스턴스가 필요합니다.
    // 이걸로 crud 하면된다~~
    var db = Database.database().reference()
    
    
    
    func updateLabel() {
        // 저장 되있는 데이터 가져오기
        db.child("firstData").observeSingleEvent(of: .value) { (snapshot) in
            print("--> data : \(snapshot)")
            
            let value = snapshot.value as? String ?? "데이터없음!"
            
            // ui는 main 쓰레드에서
            DispatchQueue.main.async {
                self.dataLabel.text = value
            }
        }
    }
    
    @IBAction func createCustomer(_ sender: Any) {
        saveCustomers()
    }
    @IBAction func fetchCustomer(_ sender: Any) {
        fetchCustomers()
    }
    
    @IBAction func updateCustomer(_ sender: Any) {
        guard customers.isEmpty == false else {
            print("업데이트할 고객 없음")
            return
        }
        customers[0].name = "흥민이"
        //        let dictionnary: [[String : Any]]
        let dictionnary = customers.map { customer in
            customer.toDictionary
        }
        db.updateChildValues(["customers" : dictionnary])
        
    }
    @IBAction func deleteCustomer(_ sender: Any) {
        db.child("customers").removeValue()
    }
}

//MARK: - Read(fetch) Data
extension ViewController {
    func fetchCustomers()  {
        db.child("customers").observeSingleEvent(of: .value) { (snapshot) in
            //            print(" Customers value --> \(snapshot.value)")
            
            do {
                let data = try JSONSerialization.data(withJSONObject: snapshot.value, options: .prettyPrinted)
                
                print("pretty JsonData ---> \(data)" )
                
                let decoder = JSONDecoder()
                let customers : [Customer] = try decoder.decode( [Customer].self, from: data)
                
                self.customers = customers // 업데이트 딜리트시 사용하기위함~
                
                print(" Customers :--> \(customers.count)")
                
                DispatchQueue.main.async {
                    self.numberOfCustomers.text = String(customers.count)
                }
                
                
            } catch let error {
                print("---> error : \(error.localizedDescription)")
            }
        }
    }
    
}
//MARK: - updata Data
extension ViewController {
    func updateBasicTypes(){
        db.updateChildValues(["int": 6])
        db.updateChildValues(["double": 5.4])
        db.updateChildValues(["str": "업데이트 된 문자열"])
    }
    
    func deleteBasicTypes(){
        db.child("int").removeValue()
        db.child("double").removeValue()
        db.child("str").removeValue()
    }
}


//MARK: - dataSave
extension ViewController {
    // 아래와 같은  타입 다 저장 가능하네 키와 밸류 형태로
    func saveBasicTypes(){
        //Firebase child ("key").setValue(value)
        // - string , number , dictionary , array 오브젝트를 저장시에는 dictionary 형태로 저장해야 쓰것네..
        
        db.child("int").setValue(3)
        db.child("double").setValue(3.5)
        db.child("str").setValue("string value - 안녕 파이어베이스")
        db.child("array").setValue(["a","b", "c"])
        db.child("dict").setValue(["id" : "anyId" , "age" : 10 , "city" : "seoul" ])
        
    }
    func saveCustomers() {
        //책가게
        //사용자를 저장하겠다
        //모델 Customer + Book
        
        let books = [Book(title: "Good to Great", author: "Someone") , Book(title: "Hacking Growth", author: "Somebody")]
        
        let customer1 = Customer(id: "\(Customer.id)", name: "Son", books: books)
        Customer.id += 1
        let customer2 = Customer(id: "\(Customer.id)", name: "Dele", books: books)
        Customer.id += 1
        let customer3 = Customer(id: "\(Customer.id)", name: "Kane", books: books)
        Customer.id += 1
        
        // customers라는이름으로 고객 넘버를 키로하고 고객오브젝트를 딕셔너리 형태로 데이터베이스에 저장
        db.child("customers").child(customer1.id).setValue(customer1.toDictionary)
        db.child("customers").child(customer2.id).setValue(customer2.toDictionary)
        db.child("customers").child(customer3.id).setValue(customer3.toDictionary)
    }
}

struct Customer:Codable{
    let id : String
    var name : String
    var books: [Book]
    
    static var id : Int = 0
    //딕셔너리 형태로 변환!
    var toDictionary : [String : Any] {
        let booksArray = books.map { $0.toDictionary } // 딕셔너리 형태로 북스어레이 생성
        let dict : [String :Any] = ["id" : id , "name" : name , "books" : booksArray]
        return dict
    }
}

struct Book :Codable {
    let title : String
    let author : String
    //딕셔너리 형태로 변환!
    var toDictionary : [String : Any] {
        let dicts : [String : Any] = ["title" : title , "author" : author]
        return dicts
    }
}

