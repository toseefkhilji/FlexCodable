import XCTest
@testable import FlexCodable

final class FlexCodableTests: XCTestCase {

    // MARK: - Test Model

    struct TestModel: Codable {
        @DecodableDate         var createdAt:  Date
        @DecodableDateOptional var deletedAt:  Date?

        @DecodableString         var userID:   String
        @DecodableStringOptional var nickname: String?

        @DecodableInt         var score:       Int
        @DecodableIntOptional var retryCount:  Int?

        @DecodableBool         var isActive:   Bool
        @DecodableBoolOptional var isVerified: Bool?
    }

    private func decode(_ jsonString: String) throws -> TestModel {
        try JSONDecoder().decode(TestModel.self, from: Data(jsonString.utf8))
    }

    // MARK: - Date Tests

    func testDateISO8601() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":"1","score":1,"isActive":true}
        """
        let model = try decode(json)
        XCTAssertNotNil(model.createdAt)
    }

    func testDateOptionalNull() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","deletedAt":null,"userID":"1","score":1,"isActive":true}
        """
        let model = try decode(json)
        XCTAssertNil(model.deletedAt)
    }

    func testDateOptionalMissingKey() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":"1","score":1,"isActive":true}
        """
        let model = try decode(json)
        XCTAssertNil(model.deletedAt)
    }

    func testDateSlashFormat() throws {
        let json = """
        {"createdAt":"2024/06/01","userID":"1","score":1,"isActive":true}
        """
        let model = try decode(json)
        XCTAssertNotNil(model.createdAt)
    }

    func testDateInvalidThrows() {
        let json = """
        {"createdAt":"not-a-date","userID":"1","score":1,"isActive":true}
        """
        XCTAssertThrowsError(try decode(json))
    }

    // MARK: - String Tests

    func testStringFromInt() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":9001,"score":1,"isActive":true}
        """
        let model = try decode(json)
        XCTAssertEqual(model.userID, "9001")
    }

    func testStringFromDouble() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":3.14,"score":1,"isActive":true}
        """
        let model = try decode(json)
        XCTAssertEqual(model.userID, "3.14")
    }

    func testStringFromBool() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":true,"score":1,"isActive":true}
        """
        let model = try decode(json)
        XCTAssertEqual(model.userID, "true")
    }

    func testStringOptionalNull() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":"abc","nickname":null,"score":1,"isActive":true}
        """
        let model = try decode(json)
        XCTAssertNil(model.nickname)
    }

    func testStringNullThrows() {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":null,"score":1,"isActive":true}
        """
        XCTAssertThrowsError(try decode(json))
    }

    // MARK: - Int Tests

    func testIntFromString() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":"u1","score":"42","isActive":true}
        """
        let model = try decode(json)
        XCTAssertEqual(model.score, 42)
    }

    func testIntFromBool() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":"u1","score":true,"isActive":true}
        """
        let model = try decode(json)
        XCTAssertEqual(model.score, 1)
    }

    func testIntFromDouble() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":"u1","score":9.9,"isActive":true}
        """
        let model = try decode(json)
        XCTAssertEqual(model.score, 9)
    }

    func testIntOptionalMissing() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":"u1","score":1,"isActive":true}
        """
        let model = try decode(json)
        XCTAssertNil(model.retryCount)
    }

    // MARK: - Bool Tests

    func testBoolFromInt1() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":"u1","score":1,"isActive":1}
        """
        let model = try decode(json)
        XCTAssertTrue(model.isActive)
    }

    func testBoolFromInt0() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":"u1","score":1,"isActive":0}
        """
        let model = try decode(json)
        XCTAssertFalse(model.isActive)
    }

    func testBoolFromStringTrue() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":"u1","score":1,"isActive":"TRUE"}
        """
        let model = try decode(json)
        XCTAssertTrue(model.isActive)
    }

    func testBoolFromStringYes() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":"u1","score":1,"isActive":"yes"}
        """
        let model = try decode(json)
        XCTAssertTrue(model.isActive)
    }

    func testBoolFromStringOff() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":"u1","score":1,"isActive":"off"}
        """
        let model = try decode(json)
        XCTAssertFalse(model.isActive)
    }

    func testBoolOptionalNull() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":"u1","score":1,"isActive":true,"isVerified":null}
        """
        let model = try decode(json)
        XCTAssertNil(model.isVerified)
    }

    func testBoolNullThrows() {
        let json = """
        {"createdAt":"2024-06-01T10:00:00Z","userID":"u1","score":1,"isActive":null}
        """
        XCTAssertThrowsError(try decode(json))
    }

    // MARK: - Round-trip encode/decode

    func testRoundTripEncodeDecode() throws {
        let json = """
        {"createdAt":"2024-06-01T10:00:00.000Z","userID":"abc","score":5,"isActive":true}
        """
        let model = try decode(json)
        let encoded = try JSONEncoder().encode(model)
        let decoded = try JSONDecoder().decode(TestModel.self, from: encoded)
        XCTAssertEqual(model.userID, decoded.userID)
        XCTAssertEqual(model.score, decoded.score)
        XCTAssertEqual(model.isActive, decoded.isActive)
    }
}
