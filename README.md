# Sample made from iOS10 Programming Cookbook on Siri-Kit

##2.1 Setting Up Your Project for Siri
    - create new Single-page application
    - enable Siri capabilities under Target preferences in Xcode
    - add new target >> Intents extension
    - declare Intent in project info.plist
            NSSiriUsageDescription : Allow user to send money to contacts
    - import Intents framework to project
##2.2 Defining an Intent Handler
    - add new Cocao-touch file, Class: XIntentHandler,  Subclass: PreviouslyDeclaredIntentKeyInPList
    - intent handling has to be call XHandler class X = whatever your Intent is, ie: Class SendPaymentHandler: INSendPaymentIntent {}
    - Handler pipeline : handle, confirm, resolvePayee?, resolveCurrencyAmount?, resolveNote?
    - run Intent target on device on Siri, & authorize Siri to interact with app
##2.3 Resolving Ambiguity in an Intent
    - create switch cases to handle ambiguity
    - ask for confirmation to proceed .confirmationRequired(with: newAmount)
    - resolved with user confirmation or default value .disambiguation(with: amounts)
##2.4 Reporting Progress for Resolving an Intent
    - handle Confirm with XIntentResponseCode
    - Report Pipeline: ready, inProgress, success, failure
##2.5 Handling an Intent
    - very similar to Confirm in it's function callbacks
    - execute the Intent request 
