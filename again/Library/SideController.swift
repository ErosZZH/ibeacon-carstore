//
//  MyViewController.swift
//  SwiftSideMenu
//
//  Created by user on 14/12/9.
//  Copyright (c) 2014年 Evgeny Nazarov. All rights reserved.
//

import UIKit

class SideController: UIViewController, UITextViewDelegate {

    var textView:UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var baseHeight:CGFloat?
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            baseHeight = 600
        } else {
            baseHeight = 400
        }
        let rect = CGRectMake(10, 75, 165, baseHeight!)
        textView = UITextView(frame: rect)
        textView!.delegate = self;
        textView!.font = UIFont.systemFontOfSize(24)
        textView!.scrollEnabled = true;
        textView!.text = "从07年法兰克福车展上的首次现身，到08年底特律车展上的量产车首发，再到北京车展的国内亮相，X6无疑是目前宝马产品序列中曝光度最高的车型。宝马将X6定义为SAC，也就是全能轿跑车（Sport Activity Coupe）。和定位于侧重公路行驶性能的X5相比，X6在公路性能上进化的更为彻底，在外形设计和动力操控上将跑车的运动能力和SUV的多功能相融合。X是宝马的SUV系列。汽车类别的一个标志性符号,3系是指紧凑级轿车,5系为中级别轿车,7系为高档商务用车,M系为公路轿跑车,X级为越野车系列,包括SUV等。宝马X6的X代表宝马高档运动型SUV的代号。6的意思就是基于6系平台制造的SUV车型，总的来说宝马X6的意思就是宝马6系平台运动型SUV(X5就是基于5系平台制造的SUV，X3就是基于3系平台，X1 是基于1系平台)，数字越高级别也就越高。BMW X6在2008年问世，其采用BMW 6系改造成SUV（运动型多功能轿车），是BMW与奥迪的Audi allroad quattro 竞争的利器！X6和Audi allroad quattro 都是轿车型越野车，X6也将和Audi allroad quattro 采用轿车的发动机，即BMW 6系的发动机，将装备V8 4.8L 360HP 发动机，对于宝马X6来说更是如虎添翼。宝马X6的前脸与所有宝马家族成员一样，大的双肾进气及两侧的腰线延伸至车身的尾部。不过X6掀背式的独特外观，让宝马的设计者在评价宝马X6的外观时说coupelike，不过宝马X6确实可以称之为运动型的轿车。"
        textView!.textColor = UIColor.blackColor()
        textView!.backgroundColor = UIColor.clearColor()
        textView!.editable = false
        self.view.addSubview(textView!)

        // Do any additional setup after loading the view.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
