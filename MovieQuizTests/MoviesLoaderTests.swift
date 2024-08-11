//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by Kaider on 11.08.2024.
//


import XCTest
@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
    
    func testSuccessLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: false) // говорим, что не хотим эмулировать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        // When
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            // Then
            switch result {
            case .success(let movies):
               
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case .failure(_):
                XCTFail("Unexpected failure")
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    func testFailureLoading() throws {
        // Given
        let loader = MoviesLoader()
        // When
        let expectation = expectation(description: "Loader expectation")
        
        loader.loadMovies { result in
            // Then
            switch result {
            case .success(let movies):
                
                expectation.fulfill()
            case .failure(_):
                
                XCTFail("Unexpected failure")
                
            }
        }
        waitForExpectations(timeout: 1)
    }
}
