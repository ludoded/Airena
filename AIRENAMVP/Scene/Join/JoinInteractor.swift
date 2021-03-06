//
//  JoinInteractor.swift
//  AIRENAMVP
//
//  Created by Haik Ampardjian on 8/30/17.
//  Copyright (c) 2017 challengeme llc. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol JoinBusinessLogic
{
  func doSomething(request: Join.Something.Request)
}

protocol JoinDataStore
{
  //var name: String { get set }
}

class JoinInteractor: JoinBusinessLogic, JoinDataStore
{
  var presenter: JoinPresentationLogic?
  var worker: JoinWorker?
  //var name: String = ""
  
  // MARK: Do something
  
  func doSomething(request: Join.Something.Request)
  {
    worker = JoinWorker()
    worker?.doSomeWork()
    
    let response = Join.Something.Response()
    presenter?.presentSomething(response: response)
  }
}
