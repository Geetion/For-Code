//
//  IOSViewController.swift
//  Gank
//
//  Created by Geek on 15/11/28.
//  Copyright © 2015年 GeekTeen. All rights reserved.
//

import UIKit
import CoreData

class IAViewController:UIView,UITableViewDataSource,UITableViewDelegate {
    var URL = String()
    var dataSource = NSMutableArray()
    var localData = NSArray()
    var context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var navigation = UINavigationController()
    var i = 2
    var newsTableView = UITableView()
    var entityName = String()
    var myView = UIView()
    
    //    初始化View
    func initMyView(myURL:String,myTableView:UITableView,myEntityName:String,navigationController:UINavigationController,selfView:UIView) {
        myView = selfView
        navigation = navigationController
        URL = myURL
        newsTableView = myTableView
        entityName = myEntityName
        loadData()
        newsTableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { () -> Void in
            self.loadData()
        })
        newsTableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { () -> Void in
            self.loadMoreData()
        })
        newsTableView.mj_header.beginRefreshing()
        let f = NSFetchRequest(entityName: entityName)
        myTableView.delegate = self
        self.clearCache()
        myTableView.dataSource = self
        self.localData = try! self.context.executeFetchRequest(f)
        print(localData.count)
    }
    
    
    //    缓存数据
    func cacheData(title:String,time:String,author:String){
        let row = NSEntityDescription.insertNewObjectForEntityForName(self.entityName, inManagedObjectContext: self.context)
        row.setValue(title, forKey: "title")
        row.setValue(time, forKey: "time")
        row.setValue(author, forKey: "author")
        try! context.save()
        let f = NSFetchRequest(entityName: entityName)
        self.localData = try! self.context.executeFetchRequest(f)
    }
    
    func clearCache(){
        for each in localData{
            context.deleteObject(each as! NSManagedObject)
            try! context.save()
        }
    }
    //    加载数据
    func loadData(){
        let loadUrl = URL + "1"
        let afmanager = AFHTTPRequestOperationManager()
        afmanager.GET(loadUrl, parameters: nil, success: { (AFHTTPRequestOperation, resp:AnyObject) -> Void in
            let results = resp.objectForKey("results")! as! NSArray
            self.clearCache()
            let currentData = NSMutableArray()
            for each in results{
                let item = NewsItem()
                item.author = each.objectForKey("who")! as! String
                item.title = each.objectForKey("desc")! as! String
                item.url = each.objectForKey("url")! as! String
                item.time = each.objectForKey("publishedAt") as! String
                currentData.addObject(item)
                self.cacheData(item.title as String,time: item.time as String,author:
                    item.author as String)
                
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.dataSource = currentData
                self.newsTableView.reloadData()
                self.newsTableView.mj_header.endRefreshing()
                //                self.newsTableView.mj_footer.endRefreshing()
                
            })
            }) { (AFHTTPRequestOperation, error:NSError) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    for each in self.localData{
                        let item = NewsItem()
                        item.author = each.valueForKey("author")! as! String
                        item.time = each.valueForKey("time")! as! String
                        item.title = each.valueForKey("title")! as! String
                        self.dataSource.addObject(item)
                        self.newsTableView.reloadData()
                        self.newsTableView.mj_header.endRefreshing()
                    }
                })
        }
    }
    
    //    加载更多数据
    func loadMoreData(){
        let loadUrl = URL + String(i++)
        let afmanager = AFHTTPRequestOperationManager()
        afmanager.GET(loadUrl, parameters: nil, success: { (AFHTTPRequestOperation, resp:AnyObject) -> Void in
            let results = resp.objectForKey("results")! as! NSArray
            for each in results{
                let item = NewsItem()
                item.author = each.objectForKey("who")! as! String
                item.title = each.objectForKey("desc")! as! String
                item.url = each.objectForKey("url")! as! String
                item.time = each.objectForKey("publishedAt") as! String
                
                self.dataSource.addObject(item)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.newsTableView.reloadData()
                self.newsTableView.mj_header.endRefreshing()
                                self.newsTableView.mj_footer.endRefreshing()
                
            })
            }) { (AFHTTPRequestOperation, error:NSError) -> Void in
            self.newsTableView.mj_footer.endRefreshing()
            MozTopAlertView.showWithType(MozAlertTypeError, text: "请检查网络", parentView: self.myView)
                
        }
        
    }
    
    
    //    Tableview的datasource和delegate
    //    返回Cell数量
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return dataSource.count
        
    }
    
    //    加载每个cell的数据
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        let title = cell.viewWithTag(1) as! UILabel
        let author = cell.viewWithTag(2) as! UILabel
        
        let item = dataSource[indexPath.row] as! NewsItem
        
        title.text = item.title as String
        author.text = item.author as String
        return cell
    }
    
    //    每个Cell的点击事件
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let myStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
        let webView = myStoryboard.instantiateViewControllerWithIdentifier("webView") as! WebViewController
        let item = dataSource[indexPath.row] as! NewsItem
        webView.url = item.url as String
        
        navigation.pushViewController(webView, animated: true)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

