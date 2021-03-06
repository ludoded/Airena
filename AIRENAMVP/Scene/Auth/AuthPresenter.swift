//
//  AuthPresenter.swift
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

protocol AuthPresentationLogic
{
  func presentSomething(response: Auth.Something.Response)
}

class AuthPresenter: AuthPresentationLogic
{
  weak var viewController: AuthDisplayLogic?
  
  // MARK: Do something
  
  func presentSomething(response: Auth.Something.Response)
  {
    let viewModel = Auth.Something.ViewModel()
    viewController?.displaySomething(viewModel: viewModel)
  }
}
