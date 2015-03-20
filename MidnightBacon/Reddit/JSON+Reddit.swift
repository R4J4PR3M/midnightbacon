//
//  JSON+Reddit.swift
//  MidnightBacon
//
//  Created by Justin Kolb on 11/20/14.
//  Copyright (c) 2014 Justin Kolb. All rights reserved.
//

import Foundation
import ModestProposal
import FranticApparatus

extension JSON {
    var asVoteDirection: VoteDirection {
        if let number = asNumber {
            if number.boolValue {
                return .Upvote
            } else {
                return .Downvote
            }
        } else {
            return .None
        }
    }
    
    var thumbnail: Thumbnail? {
        if let thumbnail = self.asString {
            if thumbnail == "" {
                return nil
            } else if let builtInType = BuiltInType(rawValue: thumbnail) {
                return Thumbnail.BuiltIn(builtInType)
            } else if let thumbnailURL = NSURL(string: thumbnail) {
                return Thumbnail.URL(thumbnailURL)
            } else {
                return Thumbnail.BuiltIn(.Default)
            }
        } else {
            return nil
        }
    }
}

func redditJSONValidator(response: NSURLResponse) -> Error? {
    if let error = Validator.defaultJSONResponseValidator(response).validate() {
        return NSErrorWrapperError(cause: error)
    } else {
        return nil
    }
}

func redditJSONParser(JSONData: NSData) -> Outcome<JSON, Error> {
    switch defaultJSONTransformer(JSONData) {
    case .Success(let JSONProducer):
        let JSON = JSONProducer.unwrap
        if isRedditErrorJSON(JSON) {
            return Outcome(redditErrorMapper(JSON))
        } else {
            return Outcome(JSON)
        }
    case .Failure(let reasonProducer):
        return Outcome(NSErrorWrapperError(cause: reasonProducer.unwrap))
    }
}

func redditJSONMapper<T>(response: URLResponse, mapper: (JSON) -> Outcome<T, Error>) -> Outcome<T, Error> {
    if let error = redditJSONValidator(response.metadata) {
        return Outcome(error)
    } else {
        switch redditJSONParser(response.data) {
        case .Success(let JSONProducer):
            return mapper(JSONProducer.unwrap)
        case .Failure(let reasonProducer):
            return Outcome(reasonProducer.unwrap)
        }
    }
}

func redditImageValidator(response: NSURLResponse) -> Error? {
    if let error = Validator.defaultImageResponseValidator(response).validate() {
        return NSErrorWrapperError(cause: error)
    } else {
        return nil
    }
}

func redditImageParser(response: URLResponse) -> Outcome<UIImage, Error> {
    if let error = redditImageValidator(response.metadata) {
        return Outcome(error)
    } else {
        switch defaultImageTransformer(response.data) {
        case .Success(let imageProducer):
            return Outcome(imageProducer.unwrap)
        case .Failure(let reasonProducer):
            return Outcome(NSErrorWrapperError(cause: reasonProducer.unwrap))
        }
    }
}
