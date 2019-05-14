//
//  IntentHandler.swift
//  RecordCreateIntentExtension
//
//  Created by 松島勇貴 on 2018/09/22.
//  Copyright © 2018年 松島勇貴. All rights reserved.
//

import Intents

import Shared

// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

class IntentHandler: INExtension, INSendMessageIntentHandling, INSearchForMessagesIntentHandling, INSetMessageAttributeIntentHandling {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
    // MARK: - INSendMessageIntentHandling
    
    // Implement resolution methods to provide additional information about your intent (optional).
    func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INSendMessageRecipientResolutionResult]) -> Void) {
        if let recipients = intent.recipients {
            
            // If no recipients were provided we'll need to prompt for a value.
            if recipients.count == 0 {
                completion([INSendMessageRecipientResolutionResult.needsValue()])
                return
            }
            
            var resolutionResults = [INSendMessageRecipientResolutionResult]()
            for recipient in recipients {
                let matchingContacts = [recipient] // Implement your contact matching logic here to create an array of matching contacts
                switch matchingContacts.count {
                case 2  ... Int.max:
                    // We need Siri's help to ask user to pick one from the matches.
                    resolutionResults += [INSendMessageRecipientResolutionResult.disambiguation(with: matchingContacts)]
                    
                case 1:
                    // We have exactly one matching contact
                    resolutionResults += [INSendMessageRecipientResolutionResult.success(with: recipient)]
                    
                case 0:
                    // We have no contacts matching the description provided
                    resolutionResults += [INSendMessageRecipientResolutionResult.unsupported()]
                    
                default:
                    break
                    
                }
            }
            completion(resolutionResults)
        }
    }
    
    func resolveContent(for intent: INSendMessageIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let text = intent.content, !text.isEmpty {
            completion(INStringResolutionResult.success(with: text))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }
    
    // Once resolution is completed, perform validation on the intent and provide confirmation (optional).
    
    func confirm(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Verify user is authenticated and your app is ready to send a message.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .ready, userActivity: userActivity)
        completion(response)
    }
    
    // Handle the completed intent (required).
    
    func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Implement your application logic to send a message here.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .success, userActivity: userActivity)
        completion(response)
    }
    
    // Implement handlers for each intent you wish to handle.  As an example for messages, you may wish to also handle searchForMessages and setMessageAttributes.
    
    // MARK: - INSearchForMessagesIntentHandling
    
    func handle(intent: INSearchForMessagesIntent, completion: @escaping (INSearchForMessagesIntentResponse) -> Void) {
        // Implement your application logic to find a message that matches the information in the intent.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSearchForMessagesIntent.self))
        let response = INSearchForMessagesIntentResponse(code: .success, userActivity: userActivity)
        // Initialize with found message's attributes
        response.messages = [INMessage(
            identifier: "identifier",
            content: "I am so excited about SiriKit!",
            dateSent: Date(),
            sender: INPerson(personHandle: INPersonHandle(value: "sarah@example.com", type: .emailAddress), nameComponents: nil, displayName: "Sarah", image: nil,  contactIdentifier: nil, customIdentifier: nil),
            recipients: [INPerson(personHandle: INPersonHandle(value: "+1-415-555-5555", type: .phoneNumber), nameComponents: nil, displayName: "John", image: nil,  contactIdentifier: nil, customIdentifier: nil)]
            )]
        completion(response)
    }
    
    // MARK: - INSetMessageAttributeIntentHandling
    
    func handle(intent: INSetMessageAttributeIntent, completion: @escaping (INSetMessageAttributeIntentResponse) -> Void) {
        // Implement your application logic to set the message attribute here.
        
        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSetMessageAttributeIntent.self))
        let response = INSetMessageAttributeIntentResponse(code: .success, userActivity: userActivity)
        completion(response)
    }
}

@available(iOS 12.0, *)
extension IntentHandler: RecordCreateIntentHandling {
    func handle(intent: RecordCreateIntent, completion: @escaping
        (RecordCreateIntentResponse) -> Void) {
        let response = RecordCreateIntentResponse(code: .success, userActivity: nil)
        
        let record = RecordModel(from: intent)

        RecordDataManager().createRecord(record!)

        completion(response)
    }
}


// TODO: 別のファイルに抽出したい
extension RecordModel {

    public convenience init?(from intent: RecordCreateIntent) {
        guard let babyName = intent.baby,
            let babyId = BabyDaoRealm.shared.find(name: babyName)?.id
            else { return nil }
        if let behavior = intent.behavior {
            switch Commands.Verb(rawValue: behavior) ?? .none {
            case .drink:
                guard let target = intent.target else { return nil }
                switch Commands.Target(rawValue: target) ?? .none {
                case .milk:
                    if let amount = intent.amount {
                        self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: Commands.Identifier.milk.rawValue, dateTime: Date(), note: nil, number1: Int(truncating: amount), number2: 0, decimal1: 0.0, decimal2: 0.0, text1: nil, text2: nil)
                        return
                    } else {
                        self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: Commands.Identifier.milk.rawValue, dateTime: Date(), note: nil, number1: 0, number2: 0, decimal1: 0.0, decimal2: 0.0, text1: nil, text2: nil)
                        return
                    }
                case .breast:
                    if let amount = intent.amount {
                        self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: Commands.Identifier.breast.rawValue, dateTime: Date(), note: nil, number1: Int(truncating: amount), number2: 0, decimal1: 0.0, decimal2: 0.0, text1: nil, text2: nil)
                        return
                    } else {
                        self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: Commands.Identifier.breast.rawValue, dateTime: Date(), note: nil, number1: 0, number2: 0, decimal1: 0.0, decimal2: 0.0, text1: nil, text2: nil)
                        return
                    }
                case .medicine:
                    self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: Commands.Identifier.medicine.rawValue, dateTime: Date(), note: nil, number1: 0, number2: 0, decimal1: 0.0, decimal2: 0.0, text1: nil, text2: nil)
                    return
                default:
                    return nil
                }
            case .eat:
                guard let target = intent.target else { return nil }
                switch Commands.Target(rawValue: target) ?? .none {
                case .babyfood:
                    self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: Commands.Identifier.babyfood.rawValue, dateTime: Date(), note: nil, number1: 0, number2: 0, decimal1: 0.0, decimal2: 0.0, text1: nil, text2: nil)
                    return
                case .snack:
                    self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: Commands.Identifier.snack.rawValue, dateTime: Date(), note: nil, number1: 0, number2: 0, decimal1: 0.0, decimal2: 0.0, text1: nil, text2: nil)
                    return
                default:
                    return nil
                }
            case .do:
                guard let target = intent.target else { return nil }
                switch Commands.Target(rawValue: target) ?? .none {
                case .poo:
                    self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: Commands.Identifier.poo.rawValue, dateTime: Date(), note: nil, number1: 0, number2: 0, decimal1: 0.0, decimal2: 0.0, text1: nil, text2: nil)
                    return
                default:
                    return nil
                }
            case .sleep:
                self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: Commands.Identifier.sleep.rawValue, dateTime: Date(), note: nil, number1: 0, number2: 0, decimal1: 0.0, decimal2: 0.0, text1: nil, text2: nil)
                return
            case .awake:
                self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: Commands.Identifier.awake.rawValue, dateTime: Date(), note: nil, number1: 0, number2: 0, decimal1: 0.0, decimal2: 0.0, text1: nil, text2: nil)
                return
            case .none:
                return nil
            }
        } else if let property = intent.property {
            switch Commands.Property(rawValue: property) ?? .none {
            case .temperature:
                if let amount = intent.amountDecimal {
                    self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: Commands.Identifier.temperature.rawValue, dateTime: Date(), note: nil, number1: 0, number2: 0, decimal1: Float(truncating: amount), decimal2: 0.0, text1: nil, text2: nil)
                    return
                } else {
                    self.init(id: UUID().uuidString, babyId: babyId, userId: nil, commandId: Commands.Identifier.temperature.rawValue, dateTime: Date(), note: nil, number1: 0, number2: 0, decimal1: 0.0, decimal2: 0.0, text1: nil, text2: nil)
                    return
                }
            default:
                return nil
            }
        } else {
            return nil
        }
    }

}
