//
//  SendPaymentHandler.swift
//  makingHer
//
//  Created by Qiao Lin on 2/23/17.
//  Copyright © 2017 Qiao Lin. All rights reserved.
//

import UIKit
import Intents

class SendPaymentHandler: INSendPaymentIntent, INSendPaymentIntentHandling {
    
    func handle(sendPayment intent: INSendPaymentIntent, completion: @escaping (INSendPaymentIntentResponse) -> Void) {
        
        func report(code: INSendPaymentIntentResponseCode){
            completion(INSendPaymentIntentResponse(code: code, userActivity: nil))
    
            report(code: .ready)
            guard let amount = intent.currencyAmount?.amount?.doubleValue else {
                report(code: .failure)
                return
            }
            report(code: .success)
        }
    }
    
    func confirm(sendPayment intent: INSendPaymentIntent, completion: @escaping (INSendPaymentIntentResponse) -> Void) {
        func report(code: INSendPaymentIntentResponseCode){
            completion(INSendPaymentIntentResponse(code: code, userActivity: nil))
            
            report(code: .ready)
            guard let amount = intent.currencyAmount?.amount?.doubleValue else {
                report(code: .failure)
                return
            }
            
            let minimumPayment = 5.0
            let maximumPayment = 20.0
            if amount < minimumPayment {
                report(code: .failurePaymentsAmountBelowMinimum)
                return
            }
            if amount > maximumPayment {
                report(code: .failurePaymentsAmountAboveMaximum)
                return
            }
            // do the actual work here
            report(code: .inProgress)
            // when done, signal that you have either successfully finished 
            // for failed 
            report(code: .success) // or .failure
            
        }
        
    }
    
    
    
    private func person(givenName: String,
                        lastName: String,
                        imageName: String,
                        telephone: String) -> INPerson {
        
        let personHandle = INPersonHandle(value: telephone, type: .phoneNumber)
        var nameComponents = PersonNameComponents()
        nameComponents.givenName = givenName
        let displayName = "\(givenName) (\(lastName))"
        let image = INImage(named: imageName)
        return INPerson(personHandle: personHandle,
                        nameComponents: nameComponents,
                        displayName: displayName,
                        image: image,
                        contactIdentifier: nil,
                        customIdentifier: nil)
    }
    
    // create two person instances and designate one of them as default person to whom all payments are made:
    
    private var anthonyFoo: INPerson{
        return person(givenName: "Anthony", lastName: "Foo", imageName: "Alert", telephone: "111-222-333")
    }
    
    private var anthonyBar: INPerson{
        return person(givenName: "Anthony", lastName: "Bar", imageName: "Burning", telephone: "444-555-666")
    }
    
    var persons: [INPerson] {
        return [anthonyFoo, anthonyBar]
    }
    
    var defaultPerson: INPerson{
        return anthonyFoo
    }
    
    
    
    // optional
    func resolvePayee(forSendPayment intent: INSendPaymentIntent, with completion: @escaping (INPersonResolutionResult) -> Void) {
        
        guard let payee = intent.payee else{
            let result = INPersonResolutionResult.confirmationRequired(with: defaultPerson)
            
            completion(result)
            return
        }
        if let foundPerson = persons.filter({$0.displayName == payee.displayName}).first{
            // there's a match so we can proceed
            let result = INPersonResolutionResult.success(with: foundPerson)
            completion(result)
            return
        }
        
        var foundPersons = [INPerson]()
        for person in persons{
            if person.nameComponents?.givenName?.lowercased() == payee.nameComponents?.givenName?.lowercased(){
                foundPersons.append(person)
            }
        }
        
        let result: INPersonResolutionResult
        switch foundPersons.count{
            case 0:
                // no matches ;(
                result = .confirmationRequired(with: defaultPerson)
            case 1:
                // we did find the user
                result = INPersonResolutionResult.success(with: foundPersons[0])
            default:
                // we found more than one user
                result = INPersonResolutionResult.disambiguation(with: foundPersons)
        }
        
        completion(result)
        
    }
    
    
    
    // define list of currencies that we support
    enum SupportedCurrencies : String{
        case USD
        case SEK
        case GBP
        
        static func allValues() -> [String]{
            let allValues:[SupportedCurrencies] = [ .USD, .SEK, .GBP]
            return allValues.map{$0.rawValue}
        }
        
        static var defaultCurrency = SupportedCurrencies.USD
    }

    // optional
    func resolveCurrencyAmount(forSendPayment intent: INSendPaymentIntent, with completion: @escaping (INCurrencyAmountResolutionResult) -> Void) {
        
        let minimumPayment = 5.0
        let maximumPayment = 20.0
        let defaultCurrencyAmount = INCurrencyAmount(amount: 15, currencyCode: "USD")
        
        guard let givenCurrency = intent.currencyAmount,
            let currencyCode = givenCurrency.currencyCode,
            let currencyAmount = givenCurrency.amount else {
            let result = INCurrencyAmountResolutionResult.confirmationRequired(with: defaultCurrencyAmount)
            completion(result)
            return
        }
        
        let currencyAmountDoubleValue = currencyAmount.doubleValue
        // do we support this currency code?
        let foundCurrencies = SupportedCurrencies.allValues().filter{$0 == currencyCode}
        let foundCurrencyCount = foundCurrencies.count
        
        let result: INCurrencyAmountResolutionResult
        switch foundCurrencyCount{
            case 0:
                result = INCurrencyAmountResolutionResult.confirmationRequired(with: defaultCurrencyAmount)
        case 1 where currencyAmountDoubleValue >= minimumPayment && currencyAmountDoubleValue <= maximumPayment:
                result = .success(with: givenCurrency)
        case 1:
            // the amount is not acceptable, ask for confirmation 
            let amount: NSDecimalNumber = 20
            let newAmount = INCurrencyAmount(amount: amount, currencyCode: currencyCode)
            result = .confirmationRequired(with: newAmount)
        default:
            var amounts = [INCurrencyAmount]()
            for foundCurrency in foundCurrencies{
                let amount = INCurrencyAmount(amount: currencyAmount, currencyCode: foundCurrency)
                amounts.append(amount)
            }
            result = .disambiguation(with: amounts)
        }
        completion(result)
    }
    
    func resolveNote(forSendPayment intent: INSendPaymentIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        completion(.success(with: "This is your payment"))
    }
}
