import UIKit
import AssetsLibrary

protocol YYImagePickerDelegate{
    func imagePickerDidSelectImages(array:NSArray!)
}


let mochaColorGreen = UIColor(red: 0x96/255.0, green: 0xc8/255.0, blue: 0x60/255.0, alpha: 1)
let dataSourceViewHeight:CGFloat = 50

class YYImagePickerController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    var delegate:YYImagePickerDelegate!
    
    var dataSourceView:YYImageDataSourceView!
    
    var limitMaxSelectNum:Int!
    
    var collectionView:UICollectionView!
    var imageDataArray:NSMutableArray!
    
    var selectDataArray:NSMutableArray!
    
    var _numberOfRow:Int!
    var numberOfRow:Int!{
        set{
            self._numberOfRow = newValue
            if (self.collectionView != nil){
                self.collectionView.reloadData()
            }
        }
        get{
            return self._numberOfRow
        
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageDataArray.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var identify = "cell"
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(identify,forIndexPath:indexPath) as YYImageCell
        cell.sizeToFit()
        
        var asset:YYImage = self.imageDataArray.objectAtIndex(indexPath.row) as YYImage
        cell.update(asset)
        
        return cell
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    override init(){
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageDataArray = NSMutableArray()
        
        self.initCollectionView()
        
        self.numberOfRow = 3
        
        self.dataSourceView = YYImageDataSourceView(frame:CGRectMake(0,self.view.frame.size.height-CGFloat(dataSourceViewHeight),self.view.frame.size.width,CGFloat(dataSourceViewHeight)))
        self.view.addSubview(self.dataSourceView)
        
        self.dataSourceView.dismissBlock = {()->() in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        self.dataSourceView.completeBlock = {()->() in
            if (self.delegate != nil){
                self.delegate.imagePickerDidSelectImages(self.selectDataArray)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        self.dataSourceView.selectGroupBlock = {(group:ALAssetsGroup)->Void in
            YYAssetHelper.sharedAssetHelper().getPhotoListOfGroup(group, result: {(array:NSArray) -> Void in
                for asset : AnyObject in array{
                    var image = YYImage()
                    image.asset = asset as ALAsset
                    self.imageDataArray.addObject(image)
                }
                
                self.collectionView.reloadData()
                })
        }
    }

    func initCollectionView(){
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection =  UICollectionViewScrollDirection.Vertical
        self.collectionView = UICollectionView(frame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-dataSourceViewHeight-20),collectionViewLayout:flowLayout)
        self.collectionView.backgroundColor = UIColor.clearColor()
        //注册
        
        self.collectionView.registerClass(YYImageCell.self,forCellWithReuseIdentifier:"cell")
        //设置代理
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.view.addSubview(self.collectionView)
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets{
        var top = UIEdgeInsets(top: 5,left: 10,bottom: 5,right: 10)
        return top
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize{
        var temp:Float = Float(self.collectionView.frame.size.width)
        var width = CGFloat((temp - 10.0 * Float(self.numberOfRow + 1)) / Float(self.numberOfRow))
        return CGSizeMake(width, width)
    }
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!){
        var image = self.imageDataArray.objectAtIndex(indexPath.row) as YYImage
        image.isSelect = !image.isSelect
        self.collectionView.reloadData()
        if !(self.selectDataArray != nil){
            self.selectDataArray = NSMutableArray()
        }
        if image.isSelect{
            if (self.limitMaxSelectNum != nil) {
                if self.selectDataArray.count >= self.limitMaxSelectNum{
                    var alert = YYAlertView(title:"提示",content:"选择数目超过限制，你可以取消一些选项然后重新选择", leftTitle:nil,rightTitle:"确定")
                    alert.show()
                    image.isSelect = false
                    return
                }
            }
            self.selectDataArray.addObject(image.asset)
        }else{
            self.selectDataArray.removeObject(image.asset)
        }
        self.dataSourceView.updateSelectNum(self.selectDataArray.count)
    }
    
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return UIStatusBarStyle.LightContent
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
