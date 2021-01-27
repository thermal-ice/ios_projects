import UIKit


//var str = "Hello, playground"
//
//print("the value of str is \(str)")

//
//func add_together(_ x: Int,_ y:Int)-> Int{
//    return x+y;
//}
//
//var summation: (Int,Int) ->Int = add_together
//
//let a_num = summation(5,8)
//let b_num = add_together(10, 7)
//
//print("the value of the a_sum is \(a_num), b_num is \(b_num)")


let a_value = 55.59

let a_valueData = withUnsafeBytes(of: a_value){Data($0)}

print(a_valueData as NSData)

let translated_value = a_valueData.withUnsafeBytes{
    $0.load(as: Double.self)
}

print(translated_value)
