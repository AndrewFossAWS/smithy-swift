/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 * SPDX-License-Identifier: Apache-2.0.
 */

import AwsCommonRuntimeKit

enum HashResult {
    case data(Data)
    case integer(UInt32)
}

enum HashError: Error {
    case invalidInput
    case hashingFailed(reason: String)
}

enum HashFunction {
    case crc32, crc32c, sha1, sha256, md5

    static func from(string: String) -> HashFunction? {
        switch string.lowercased() {
        case "crc32": return .crc32
        case "crc32c": return .crc32c
        case "sha1": return .sha1
        case "sha256": return .sha256
        case "md5": return .md5 // md5 is not a valid flexible checksum algorithm
        default: return nil
        }
    }

    var isSupported: Bool {
        switch self {
        case .crc32, .crc32c, .sha256, .sha1:
            return true
        default:
            return false
        }
    }

    func computeHash(of data: Data) throws -> HashResult {
        switch self {
        case .crc32:
            return .integer(data.computeCRC32())
        case .crc32c:
            return .integer(data.computeCRC32C())
        case .sha1:
            do {
                let hashed = try data.computeSHA1()
                return .data(hashed)
            } catch {
                throw HashError.hashingFailed(reason: "Error computing SHA1: \(error)")
            }
        case .sha256:
            do {
                let hashed = try data.computeSHA256()
                return .data(hashed)
            } catch {
                throw HashError.hashingFailed(reason: "Error computing SHA256: \(error)")
            }
        case .md5:
            do {
                let hashed = try data.computeMD5()
                return .data(hashed)
            } catch {
                throw HashError.hashingFailed(reason: "Error computing MD5: \(error)")
            }
        }
    }
}

extension HashResult {

    // Convert a HashResult to a hexadecimal String
    func toHexString() -> String {
        switch self {
        case .data(let data):
            return data.map { String(format: "%02x", $0) }.joined()
        case .integer(let integer):
            return String(format: "%08x", integer)
        }
    }
}
