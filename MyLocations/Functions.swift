//
//  Functions.swift
//  MyLocations
//
//  Created by user206341 on 10/29/21.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping ()->Void ) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}
