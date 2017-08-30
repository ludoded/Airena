//
//  AuthInteractor.swift
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

protocol AuthBusinessLogic
{
  func doSomething(request: Auth.Something.Request)
}

protocol AuthDataStore
{
  //var name: String { get set }
}

class AuthInteractor: AuthBusinessLogic, AuthDataStore
{
  var presenter: AuthPresentationLogic?
  var worker: AuthWorker?
  //var name: String = ""
  
  // MARK: Do something
  
  func doSomething(request: Auth.Something.Request)
  {
    worker = AuthWorker()
    worker?.doSomeWork()
    
    let response = Auth.Something.Response()
    presenter?.presentSomething(response: response)
  }
}