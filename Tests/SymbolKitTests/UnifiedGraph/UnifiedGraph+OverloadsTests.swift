/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2024 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import XCTest
import Foundation
@testable import SymbolKit

class UnifiedGraphOverloadsTests: XCTestCase {
    func testUnifiedOverloadGroups() throws {
        let unifiedGraph = try unifySymbolGraphs(
            ("DemoKit-macos.symbols.json", makeOverloadsSymbolGraph(platform: "macosx", withOverloads: [1, 2]))
        )

        let overloadSymbols = [1, 2].map(\.asOverloadIdentifier)
        let expectedOverloadGroupIdentifier = 1.asOverloadIdentifier + SymbolGraph.Symbol.overloadGroupIdentifierSuffix

        let allRelations = unifiedGraph.unifiedRelationships

        // Make sure that overloadOf relationships were added
        let overloadRelations = allRelations.filter({ $0.kind == .overloadOf })
        XCTAssertEqual(overloadRelations.count, 2)
        XCTAssertEqual(Set(overloadRelations.map(\.target)).count, 1)
        XCTAssertEqual(Set(overloadRelations.map(\.source)), Set(overloadSymbols))

        // Pull out the overload group's identifier and make sure that it exists
        let overloadGroupIdentifier = try XCTUnwrap(overloadRelations.first?.target)
        XCTAssertEqual(overloadGroupIdentifier, expectedOverloadGroupIdentifier)
        XCTAssert(unifiedGraph.symbols.keys.contains(overloadGroupIdentifier))

        // Make sure that the individual overloads reference the overload group and their index properly
        for overloadIndex in overloadSymbols.indices {
            let overloadIdentifier = overloadSymbols[overloadIndex]
            let overloadSymbol = try XCTUnwrap(unifiedGraph.symbols[overloadIdentifier])
            let overloadData = try XCTUnwrap(overloadSymbol.unifiedOverloadData)
            XCTAssertEqual(overloadData.overloadGroupIdentifier, expectedOverloadGroupIdentifier)
            XCTAssertEqual(overloadData.overloadGroupIndex, overloadIndex)
        }
    }

    func testUnifiedOverloadGroupsAcrossPlatforms() throws {
        let unifiedGraph = try unifySymbolGraphs(
            ("DemoKit-macos.symbols.json", makeOverloadsSymbolGraph(platform: "macosx", withOverloads: [1, 2])),
            ("DemoKit-ios.symbols.json", makeOverloadsSymbolGraph(platform: "ios", withOverloads: [1, 2]))
        )

        let overloadSymbols = [1, 2].map(\.asOverloadIdentifier)
        let expectedOverloadGroupIdentifier = 1.asOverloadIdentifier + SymbolGraph.Symbol.overloadGroupIdentifierSuffix

        let allRelations = unifiedGraph.unifiedRelationships

        // Make sure that overloadOf relationships were added
        let overloadRelations = allRelations.filter({ $0.kind == .overloadOf })
        XCTAssertEqual(overloadRelations.count, 2)
        XCTAssertEqual(Set(overloadRelations.map(\.target)).count, 1)
        XCTAssertEqual(Set(overloadRelations.map(\.source)), Set(overloadSymbols))

        // Pull out the overload group's identifier and make sure that it exists
        let overloadGroupIdentifier = try XCTUnwrap(overloadRelations.first?.target)
        XCTAssertEqual(overloadGroupIdentifier, expectedOverloadGroupIdentifier)
        XCTAssert(unifiedGraph.symbols.keys.contains(overloadGroupIdentifier))

        // Make sure that the individual overloads reference the overload group and their index properly
        for overloadIndex in overloadSymbols.indices {
            let overloadIdentifier = overloadSymbols[overloadIndex]
            let overloadSymbol = try XCTUnwrap(unifiedGraph.symbols[overloadIdentifier])
            let overloadData = try XCTUnwrap(overloadSymbol.unifiedOverloadData)
            XCTAssertEqual(overloadData.overloadGroupIdentifier, expectedOverloadGroupIdentifier)
            XCTAssertEqual(overloadData.overloadGroupIndex, overloadIndex)
        }
    }

    func testOnePlatformDoesntOverload() throws {
        let unifiedGraph = try unifySymbolGraphs(
            ("DemoKit-macos.symbols.json", makeOverloadsSymbolGraph(platform: "macosx", withOverloads: [1])),
            ("DemoKit-ios.symbols.json", makeOverloadsSymbolGraph(platform: "ios", withOverloads: [1, 2]))
        )

        let overloadSymbols = [1, 2].map(\.asOverloadIdentifier)
        let expectedOverloadGroupIdentifier = 1.asOverloadIdentifier + SymbolGraph.Symbol.overloadGroupIdentifierSuffix

        let allRelations = unifiedGraph.unifiedRelationships

        // Make sure that overloadOf relationships were added
        let overloadRelations = allRelations.filter({ $0.kind == .overloadOf })
        XCTAssertEqual(overloadRelations.count, 2)
        XCTAssertEqual(Set(overloadRelations.map(\.target)).count, 1)
        XCTAssertEqual(Set(overloadRelations.map(\.source)), Set(overloadSymbols))

        // Pull out the overload group's identifier and make sure that it exists
        let overloadGroupIdentifier = try XCTUnwrap(overloadRelations.first?.target)
        XCTAssertEqual(overloadGroupIdentifier, expectedOverloadGroupIdentifier)
        XCTAssert(unifiedGraph.symbols.keys.contains(overloadGroupIdentifier))

        // Make sure that the individual overloads reference the overload group and their index properly
        for overloadIndex in overloadSymbols.indices {
            let overloadIdentifier = overloadSymbols[overloadIndex]
            let overloadSymbol = try XCTUnwrap(unifiedGraph.symbols[overloadIdentifier])
            let overloadData = try XCTUnwrap(overloadSymbol.unifiedOverloadData)
            XCTAssertEqual(overloadData.overloadGroupIdentifier, expectedOverloadGroupIdentifier)
            XCTAssertEqual(overloadData.overloadGroupIndex, overloadIndex)
        }
    }

    func testDisjointOverloadGroups() throws {
        let unifiedGraph = try unifySymbolGraphs(
            ("DemoKit-macos.symbols.json", makeOverloadsSymbolGraph(platform: "macosx", withOverloads: [1, 2])),
            ("DemoKit-ios.symbols.json", makeOverloadsSymbolGraph(platform: "ios", withOverloads: [1, 3]))
        )

        let overloadSymbols = [1, 2, 3].map(\.asOverloadIdentifier)
        let expectedOverloadGroupIdentifier = 1.asOverloadIdentifier + SymbolGraph.Symbol.overloadGroupIdentifierSuffix

        let allRelations = unifiedGraph.unifiedRelationships

        // Make sure that overloadOf relationships were added
        let overloadRelations = allRelations.filter({ $0.kind == .overloadOf })
        XCTAssertEqual(overloadRelations.count, 3)
        XCTAssertEqual(Set(overloadRelations.map(\.target)).count, 1)
        XCTAssertEqual(Set(overloadRelations.map(\.source)), Set(overloadSymbols))

        // Pull out the overload group's identifier and make sure that it exists
        let overloadGroupIdentifier = try XCTUnwrap(overloadRelations.first?.target)
        XCTAssertEqual(overloadGroupIdentifier, expectedOverloadGroupIdentifier)
        XCTAssert(unifiedGraph.symbols.keys.contains(overloadGroupIdentifier))

        // Make sure that the individual overloads reference the overload group and their index properly
        for overloadIndex in overloadSymbols.indices {
            let overloadIdentifier = overloadSymbols[overloadIndex]
            let overloadSymbol = try XCTUnwrap(unifiedGraph.symbols[overloadIdentifier])
            let overloadData = try XCTUnwrap(overloadSymbol.unifiedOverloadData)
            XCTAssertEqual(overloadData.overloadGroupIdentifier, expectedOverloadGroupIdentifier)
            XCTAssertEqual(overloadData.overloadGroupIndex, overloadIndex)
        }
    }

    func testRemoveExtraOverloadGroups() throws {
        let unifiedGraph = try unifySymbolGraphs(
            ("DemoKit-macos.symbols.json", makeOverloadsSymbolGraph(platform: "macosx", withOverloads: [1, 2])),
            ("DemoKit-ios.symbols.json", makeOverloadsSymbolGraph(platform: "ios", withOverloads: [2, 3]))
        )

        let overloadSymbols = [1, 2, 3].map(\.asOverloadIdentifier)
        let expectedOverloadGroupIdentifier = 1.asOverloadIdentifier + SymbolGraph.Symbol.overloadGroupIdentifierSuffix

        let allRelations = unifiedGraph.unifiedRelationships

        // Make sure that overloadOf relationships were added
        let overloadRelations = allRelations.filter({ $0.kind == .overloadOf })
        XCTAssertEqual(overloadRelations.count, 3)
        XCTAssertEqual(Set(overloadRelations.map(\.target)).count, 1)
        XCTAssertEqual(Set(overloadRelations.map(\.source)), Set(overloadSymbols))

        // Pull out the overload group's identifier and make sure that it exists
        let overloadGroupIdentifier = try XCTUnwrap(overloadRelations.first?.target)
        XCTAssertEqual(overloadGroupIdentifier, expectedOverloadGroupIdentifier)
        XCTAssert(unifiedGraph.symbols.keys.contains(overloadGroupIdentifier))

        // Make sure that the individual overloads reference the overload group and their index properly
        for overloadIndex in overloadSymbols.indices {
            let overloadIdentifier = overloadSymbols[overloadIndex]
            let overloadSymbol = try XCTUnwrap(unifiedGraph.symbols[overloadIdentifier])
            let overloadData = try XCTUnwrap(overloadSymbol.unifiedOverloadData)
            XCTAssertEqual(overloadData.overloadGroupIdentifier, expectedOverloadGroupIdentifier)
            XCTAssertEqual(overloadData.overloadGroupIndex, overloadIndex)
        }

        // Also make sure that the iOS overload group was dropped from the unified graph
        let iOSOverloadGroupIdentifier = 2.asOverloadIdentifier + SymbolGraph.Symbol.overloadGroupIdentifierSuffix
        XCTAssertFalse(unifiedGraph.symbols.keys.contains(iOSOverloadGroupIdentifier))
        XCTAssertFalse(allRelations.contains(where: {
            $0.target == iOSOverloadGroupIdentifier || $0.source == iOSOverloadGroupIdentifier
        }))
    }

    func testOverloadsWithSameDeclaration() throws {
        // func myFunc()
        // func myFunc()
        // (In a real-world scenario, these might differ by the swiftGenerics mixin, but here we can
        // write a contrived situation like this)
        let unifiedGraph = try unifySymbolGraphs(
            ("DemoKit.symbols.json", makeSymbolGraph(
                platform: "macosx",
                symbols: [
                    .init(
                        identifier: .init(precise: "s:myFunc-2", interfaceLanguage: "swift"),
                        names: .init(title: "myFunc()", navigator: nil, subHeading: nil, prose: nil),
                        pathComponents: ["myFunc()"],
                        docComment: nil,
                        accessLevel: .init(rawValue: "public"),
                        kind: .init(parsedIdentifier: .func, displayName: "Function"),
                        mixins: [
                            SymbolGraph.Symbol.DeclarationFragments.mixinKey:
                                SymbolGraph.Symbol.DeclarationFragments(declarationFragments: [
                                    .init(kind: .text, spelling: "myFunc()", preciseIdentifier: nil)
                                ])
                        ]),
                    .init(
                        identifier: .init(precise: "s:myFunc-1", interfaceLanguage: "swift"),
                        names: .init(title: "myFunc()", navigator: nil, subHeading: nil, prose: nil),
                        pathComponents: ["myFunc()"],
                        docComment: nil,
                        accessLevel: .init(rawValue: "public"),
                        kind: .init(parsedIdentifier: .func, displayName: "Function"),
                        mixins: [
                            SymbolGraph.Symbol.DeclarationFragments.mixinKey:
                                SymbolGraph.Symbol.DeclarationFragments(declarationFragments: [
                                    .init(kind: .text, spelling: "myFunc()", preciseIdentifier: nil)
                                ])
                        ]),
                ],
                relations: []))
        )

        let overloadSymbols = [
            "s:myFunc-1",
            "s:myFunc-2",
        ]
        let expectedOverloadGroupIdentifier = "s:myFunc-1::OverloadGroup"

        let allRelations = unifiedGraph.unifiedRelationships

        // Make sure that overloadOf relationships were added
        let overloadRelations = allRelations.filter({ $0.kind == .overloadOf })
        XCTAssertEqual(overloadRelations.count, 2)
        XCTAssertEqual(Set(overloadRelations.map(\.target)).count, 1)
        XCTAssertEqual(Set(overloadRelations.map(\.source)), Set(overloadSymbols))

        // Pull out the overload group's identifier and make sure that it exists
        let overloadGroupIdentifier = try XCTUnwrap(overloadRelations.first?.target)
        XCTAssertEqual(overloadGroupIdentifier, expectedOverloadGroupIdentifier)
        XCTAssert(unifiedGraph.symbols.keys.contains(overloadGroupIdentifier))

        // Make sure that the individual overloads reference the overload group and their index properly
        for overloadIndex in overloadSymbols.indices {
            let overloadIdentifier = overloadSymbols[overloadIndex]
            let overloadSymbol = try XCTUnwrap(unifiedGraph.symbols[overloadIdentifier])
            let overloadData = try XCTUnwrap(overloadSymbol.unifiedOverloadData)
            XCTAssertEqual(overloadData.overloadGroupIdentifier, expectedOverloadGroupIdentifier)
            XCTAssertEqual(overloadData.overloadGroupIndex, overloadIndex)
        }
    }

    func testOverloadWithPlatformSpecificDeclarations() throws {
        // The symbol graphs here are the same as the last one, but on macOS the `myFunc()-2` version
        // has an attribute in its declaration that causes it to sort above the other one. Make sure
        // that we correctly sort it to the top in the unified graph even when the iOS version sorts
        // `myFunc()-1` on top.
        let unifiedGraph = try unifySymbolGraphs(
            ("DemoKit-macos.symbols.json", makeSymbolGraph(
                platform: "macosx",
                symbols: [
                    .init(
                        identifier: .init(precise: "s:myFunc-2", interfaceLanguage: "swift"),
                        names: .init(title: "myFunc()", navigator: nil, subHeading: nil, prose: nil),
                        pathComponents: ["myFunc()"],
                        docComment: nil,
                        accessLevel: .init(rawValue: "public"),
                        kind: .init(parsedIdentifier: .func, displayName: "Function"),
                        mixins: [
                            SymbolGraph.Symbol.DeclarationFragments.mixinKey:
                                SymbolGraph.Symbol.DeclarationFragments(declarationFragments: [
                                    .init(kind: .text, spelling: "@Attribute myFunc()", preciseIdentifier: nil)
                                ])
                        ]),
                    .init(
                        identifier: .init(precise: "s:myFunc-1", interfaceLanguage: "swift"),
                        names: .init(title: "myFunc()", navigator: nil, subHeading: nil, prose: nil),
                        pathComponents: ["myFunc()"],
                        docComment: nil,
                        accessLevel: .init(rawValue: "public"),
                        kind: .init(parsedIdentifier: .func, displayName: "Function"),
                        mixins: [
                            SymbolGraph.Symbol.DeclarationFragments.mixinKey:
                                SymbolGraph.Symbol.DeclarationFragments(declarationFragments: [
                                    .init(kind: .text, spelling: "myFunc()", preciseIdentifier: nil)
                                ])
                        ]),
                ],
                relations: [])),
            ("DemoKit-ios.symbols.json", makeSymbolGraph(
                platform: "ios",
                symbols: [
                    .init(
                        identifier: .init(precise: "s:myFunc-2", interfaceLanguage: "swift"),
                        names: .init(title: "myFunc()", navigator: nil, subHeading: nil, prose: nil),
                        pathComponents: ["myFunc()"],
                        docComment: nil,
                        accessLevel: .init(rawValue: "public"),
                        kind: .init(parsedIdentifier: .func, displayName: "Function"),
                        mixins: [
                            SymbolGraph.Symbol.DeclarationFragments.mixinKey:
                                SymbolGraph.Symbol.DeclarationFragments(declarationFragments: [
                                    .init(kind: .text, spelling: "myFunc()", preciseIdentifier: nil)
                                ])
                        ]),
                    .init(
                        identifier: .init(precise: "s:myFunc-1", interfaceLanguage: "swift"),
                        names: .init(title: "myFunc()", navigator: nil, subHeading: nil, prose: nil),
                        pathComponents: ["myFunc()"],
                        docComment: nil,
                        accessLevel: .init(rawValue: "public"),
                        kind: .init(parsedIdentifier: .func, displayName: "Function"),
                        mixins: [
                            SymbolGraph.Symbol.DeclarationFragments.mixinKey:
                                SymbolGraph.Symbol.DeclarationFragments(declarationFragments: [
                                    .init(kind: .text, spelling: "myFunc()", preciseIdentifier: nil)
                                ])
                        ]),
                ],
                relations: []))
        )

        let overloadSymbols = [
            "s:myFunc-2",
            "s:myFunc-1",
        ]
        let expectedOverloadGroupIdentifier = "s:myFunc-2::OverloadGroup"

        let allRelations = unifiedGraph.unifiedRelationships

        // Make sure that overloadOf relationships were added
        let overloadRelations = allRelations.filter({ $0.kind == .overloadOf })
        XCTAssertEqual(overloadRelations.count, 2)
        XCTAssertEqual(Set(overloadRelations.map(\.target)).count, 1)
        XCTAssertEqual(Set(overloadRelations.map(\.source)), Set(overloadSymbols))

        // Pull out the overload group's identifier and make sure that it exists
        let overloadGroupIdentifier = try XCTUnwrap(overloadRelations.first?.target)
        XCTAssertEqual(overloadGroupIdentifier, expectedOverloadGroupIdentifier)
        XCTAssert(unifiedGraph.symbols.keys.contains(overloadGroupIdentifier))

        // Make sure that the individual overloads reference the overload group and their index properly
        for overloadIndex in overloadSymbols.indices {
            let overloadIdentifier = overloadSymbols[overloadIndex]
            let overloadSymbol = try XCTUnwrap(unifiedGraph.symbols[overloadIdentifier])
            let overloadData = try XCTUnwrap(overloadSymbol.unifiedOverloadData)
            XCTAssertEqual(overloadData.overloadGroupIdentifier, expectedOverloadGroupIdentifier)
            XCTAssertEqual(overloadData.overloadGroupIndex, overloadIndex)
        }

        // Also make sure that the iOS overload group was dropped from the unified graph
        let iOSOverloadGroupIdentifier = "s:myFunc-1::OverloadGroup"
        XCTAssertFalse(unifiedGraph.symbols.keys.contains(iOSOverloadGroupIdentifier))
        XCTAssertFalse(allRelations.contains(where: {
            $0.target == iOSOverloadGroupIdentifier || $0.source == iOSOverloadGroupIdentifier
        }))
    }

    /// Ensure that overload groups continue to sort overloads by identifier when both overloads are deprecated.
    func testDeprecatedOverloads() throws {
        let unifiedGraph = try unifySymbolGraphs(
            ("DemoKit.symbols.json", makeSymbolGraph(
                platform: "macosx",
                symbols: [
                    .init(
                        identifier: .init(precise: "s:myFunc-1", interfaceLanguage: "swift"),
                        names: .init(title: "myFunc()", navigator: nil, subHeading: nil, prose: nil),
                        pathComponents: ["myFunc()"],
                        docComment: nil,
                        accessLevel: .init(rawValue: "public"),
                        kind: .init(parsedIdentifier: .func, displayName: "Function"),
                        mixins: [
                            SymbolGraph.Symbol.Availability.mixinKey:
                                SymbolGraph.Symbol.Availability(availability: [
                                    .init(
                                        domain: .init(rawValue: "macOS"),
                                        introducedVersion: nil,
                                        deprecatedVersion: .init(major: 10, minor: 0, patch: 0),
                                        obsoletedVersion: nil,
                                        message: "Use myOtherFunc, it's better",
                                        renamed: nil,
                                        isUnconditionallyDeprecated: false,
                                        isUnconditionallyUnavailable: false,
                                        willEventuallyBeDeprecated: false)
                                ])
                        ]),
                    .init(
                        identifier: .init(precise: "s:myFunc-2", interfaceLanguage: "swift"),
                        names: .init(title: "myFunc()", navigator: nil, subHeading: nil, prose: nil),
                        pathComponents: ["myFunc()"],
                        docComment: nil,
                        accessLevel: .init(rawValue: "public"),
                        kind: .init(parsedIdentifier: .func, displayName: "Function"),
                        mixins: [
                            SymbolGraph.Symbol.Availability.mixinKey:
                                SymbolGraph.Symbol.Availability(availability: [
                                    .init(
                                        domain: .init(rawValue: "macOS"),
                                        introducedVersion: nil,
                                        deprecatedVersion: .init(major: 10, minor: 0, patch: 0),
                                        obsoletedVersion: nil,
                                        message: "Use myOtherFunc, it's better",
                                        renamed: nil,
                                        isUnconditionallyDeprecated: false,
                                        isUnconditionallyUnavailable: false,
                                        willEventuallyBeDeprecated: false)
                                ])
                        ]),
                ],
                relations: []))
        )

        let overloadSymbols = [
            "s:myFunc-1",
            "s:myFunc-2",
        ]
        let expectedOverloadGroupIdentifier = "s:myFunc-1::OverloadGroup"

        let allRelations = unifiedGraph.unifiedRelationships

        // Make sure that overloadOf relationships were added
        let overloadRelations = allRelations.filter({ $0.kind == .overloadOf })
        XCTAssertEqual(overloadRelations.count, 2)
        XCTAssertEqual(Set(overloadRelations.map(\.target)).count, 1)
        XCTAssertEqual(Set(overloadRelations.map(\.source)), Set(overloadSymbols))

        // Pull out the overload group's identifier and make sure that it exists
        let overloadGroupIdentifier = try XCTUnwrap(overloadRelations.first?.target)
        XCTAssertEqual(overloadGroupIdentifier, expectedOverloadGroupIdentifier)
        XCTAssert(unifiedGraph.symbols.keys.contains(overloadGroupIdentifier))

        // Make sure that the individual overloads reference the overload group and their index properly
        for overloadIndex in overloadSymbols.indices {
            let overloadIdentifier = overloadSymbols[overloadIndex]
            let overloadSymbol = try XCTUnwrap(unifiedGraph.symbols[overloadIdentifier])
            let overloadData = try XCTUnwrap(overloadSymbol.unifiedOverloadData)
            XCTAssertEqual(overloadData.overloadGroupIdentifier, expectedOverloadGroupIdentifier)
            XCTAssertEqual(overloadData.overloadGroupIndex, overloadIndex)
        }
    }

    /// Ensure that an overload group does not select a deprecated overload as the overload group
    /// when a non-deprecated overload is available.
    func testPartiallyDeprecatedOverloads() throws {
        let unifiedGraph = try unifySymbolGraphs(
            ("DemoKit.symbols.json", makeSymbolGraph(
                platform: "macosx",
                symbols: [
                    .init(
                        identifier: .init(precise: "s:myFunc-1", interfaceLanguage: "swift"),
                        names: .init(title: "myFunc()", navigator: nil, subHeading: nil, prose: nil),
                        pathComponents: ["myFunc()"],
                        docComment: nil,
                        accessLevel: .init(rawValue: "public"),
                        kind: .init(parsedIdentifier: .func, displayName: "Function"),
                        mixins: [
                            SymbolGraph.Symbol.Availability.mixinKey:
                                SymbolGraph.Symbol.Availability(availability: [
                                    .init(
                                        domain: .init(rawValue: "macOS"),
                                        introducedVersion: nil,
                                        deprecatedVersion: .init(major: 10, minor: 0, patch: 0),
                                        obsoletedVersion: nil,
                                        message: "Use the other myFunc, it's better",
                                        renamed: nil,
                                        isUnconditionallyDeprecated: false,
                                        isUnconditionallyUnavailable: false,
                                        willEventuallyBeDeprecated: false)
                                ])
                        ]),
                    .init(
                        identifier: .init(precise: "s:myFunc-2", interfaceLanguage: "swift"),
                        names: .init(title: "myFunc()", navigator: nil, subHeading: nil, prose: nil),
                        pathComponents: ["myFunc()"],
                        docComment: nil,
                        accessLevel: .init(rawValue: "public"),
                        kind: .init(parsedIdentifier: .func, displayName: "Function"),
                        mixins: [:]),
                ],
                relations: []))
        )

        let overloadSymbols = [
            "s:myFunc-2",
            "s:myFunc-1",
        ]
        let expectedOverloadGroupIdentifier = "s:myFunc-2::OverloadGroup"

        let allRelations = unifiedGraph.unifiedRelationships

        // Make sure that overloadOf relationships were added
        let overloadRelations = allRelations.filter({ $0.kind == .overloadOf })
        XCTAssertEqual(overloadRelations.count, 2)
        XCTAssertEqual(Set(overloadRelations.map(\.target)).count, 1)
        XCTAssertEqual(Set(overloadRelations.map(\.source)), Set(overloadSymbols))

        // Pull out the overload group's identifier and make sure that it exists
        let overloadGroupIdentifier = try XCTUnwrap(overloadRelations.first?.target)
        XCTAssertEqual(overloadGroupIdentifier, expectedOverloadGroupIdentifier)
        XCTAssert(unifiedGraph.symbols.keys.contains(overloadGroupIdentifier))

        // Make sure that the individual overloads reference the overload group and their index properly
        for overloadIndex in overloadSymbols.indices {
            let overloadIdentifier = overloadSymbols[overloadIndex]
            let overloadSymbol = try XCTUnwrap(unifiedGraph.symbols[overloadIdentifier])
            let overloadData = try XCTUnwrap(overloadSymbol.unifiedOverloadData)
            XCTAssertEqual(overloadData.overloadGroupIdentifier, expectedOverloadGroupIdentifier)
            XCTAssertEqual(overloadData.overloadGroupIndex, overloadIndex)
        }
    }

    /// Like the above, but ensure that the same behavior holds for "unconditionally deprecated" symbols.
    func testPartiallyUnconditionallyDeprecatedOverloads() throws {
        let unifiedGraph = try unifySymbolGraphs(
            ("DemoKit.symbols.json", makeSymbolGraph(
                platform: "macosx",
                symbols: [
                    .init(
                        identifier: .init(precise: "s:myFunc-1", interfaceLanguage: "swift"),
                        names: .init(title: "myFunc()", navigator: nil, subHeading: nil, prose: nil),
                        pathComponents: ["myFunc()"],
                        docComment: nil,
                        accessLevel: .init(rawValue: "public"),
                        kind: .init(parsedIdentifier: .func, displayName: "Function"),
                        mixins: [
                            SymbolGraph.Symbol.Availability.mixinKey:
                                SymbolGraph.Symbol.Availability(availability: [
                                    .init(
                                        domain: .init(rawValue: "macOS"),
                                        introducedVersion: nil,
                                        deprecatedVersion: nil,
                                        obsoletedVersion: nil,
                                        message: "Use the other myFunc, it's better",
                                        renamed: nil,
                                        isUnconditionallyDeprecated: true,
                                        isUnconditionallyUnavailable: false,
                                        willEventuallyBeDeprecated: false)
                                ])
                        ]),
                    .init(
                        identifier: .init(precise: "s:myFunc-2", interfaceLanguage: "swift"),
                        names: .init(title: "myFunc()", navigator: nil, subHeading: nil, prose: nil),
                        pathComponents: ["myFunc()"],
                        docComment: nil,
                        accessLevel: .init(rawValue: "public"),
                        kind: .init(parsedIdentifier: .func, displayName: "Function"),
                        mixins: [:]),
                ],
                relations: []))
        )

        let overloadSymbols = [
            "s:myFunc-2",
            "s:myFunc-1",
        ]
        let expectedOverloadGroupIdentifier = "s:myFunc-2::OverloadGroup"

        let allRelations = unifiedGraph.unifiedRelationships

        // Make sure that overloadOf relationships were added
        let overloadRelations = allRelations.filter({ $0.kind == .overloadOf })
        XCTAssertEqual(overloadRelations.count, 2)
        XCTAssertEqual(Set(overloadRelations.map(\.target)).count, 1)
        XCTAssertEqual(Set(overloadRelations.map(\.source)), Set(overloadSymbols))

        // Pull out the overload group's identifier and make sure that it exists
        let overloadGroupIdentifier = try XCTUnwrap(overloadRelations.first?.target)
        XCTAssertEqual(overloadGroupIdentifier, expectedOverloadGroupIdentifier)
        XCTAssert(unifiedGraph.symbols.keys.contains(overloadGroupIdentifier))

        // Make sure that the individual overloads reference the overload group and their index properly
        for overloadIndex in overloadSymbols.indices {
            let overloadIdentifier = overloadSymbols[overloadIndex]
            let overloadSymbol = try XCTUnwrap(unifiedGraph.symbols[overloadIdentifier])
            let overloadData = try XCTUnwrap(overloadSymbol.unifiedOverloadData)
            XCTAssertEqual(overloadData.overloadGroupIdentifier, expectedOverloadGroupIdentifier)
            XCTAssertEqual(overloadData.overloadGroupIndex, overloadIndex)
        }
    }

    /// Ensure that a cross-platform overload group from an extension symbol graph properly cleans
    /// up overload groups and relationships in the unified graph.
    func testOverloadsFromExtensionGraphs() throws {
        let unifiedGraph = try unifySymbolGraphs(
            ("DemoKit-macos.symbols.json", makeOverloadsSymbolGraph(platform: "macosx", withOverloads: [])),
            ("DemoKit-ios.symbols.json", makeOverloadsSymbolGraph(platform: "ios", withOverloads: [])),
            ("OtherKit-macos@DemoKit.symbols.json", makeSymbolGraph(
                platform: "macosx",
                symbols: [1, 2].map(\.asOverloadSymbol),
                relations: [1, 2].map(\.asOverloadRelationship)
            )),
            ("OtherKit-ios@DemoKit.symbols.json", makeSymbolGraph(
                platform: "ios",
                symbols: [2, 3].map(\.asOverloadSymbol),
                relations: [2, 3].map(\.asOverloadRelationship)
            ))
        )

        let overloadSymbols = [1, 2, 3].map(\.asOverloadIdentifier)
        let expectedOverloadGroupIdentifier = 1.asOverloadIdentifier + SymbolGraph.Symbol.overloadGroupIdentifierSuffix

        let allRelations = unifiedGraph.unifiedRelationships

        // Make sure that overloadOf relationships were added
        let overloadRelations = allRelations.filter({ $0.kind == .overloadOf })
        XCTAssertEqual(overloadRelations.count, 3)
        XCTAssertEqual(Set(overloadRelations.map(\.target)).count, 1)
        XCTAssertEqual(Set(overloadRelations.map(\.source)), Set(overloadSymbols))

        // Pull out the overload group's identifier and make sure that it exists
        let overloadGroupIdentifier = try XCTUnwrap(overloadRelations.first?.target)
        XCTAssertEqual(overloadGroupIdentifier, expectedOverloadGroupIdentifier)
        XCTAssert(unifiedGraph.symbols.keys.contains(overloadGroupIdentifier))

        // Make sure that the individual overloads reference the overload group and their index properly
        for overloadIndex in overloadSymbols.indices {
            let overloadIdentifier = overloadSymbols[overloadIndex]
            let overloadSymbol = try XCTUnwrap(unifiedGraph.symbols[overloadIdentifier])
            let overloadData = try XCTUnwrap(overloadSymbol.unifiedOverloadData)
            XCTAssertEqual(overloadData.overloadGroupIdentifier, expectedOverloadGroupIdentifier)
            XCTAssertEqual(overloadData.overloadGroupIndex, overloadIndex)
        }

        // Also make sure that the iOS overload group was dropped from the unified graph
        let iOSOverloadGroupIdentifier = 2.asOverloadIdentifier + SymbolGraph.Symbol.overloadGroupIdentifierSuffix
        XCTAssertFalse(unifiedGraph.symbols.keys.contains(iOSOverloadGroupIdentifier))
        XCTAssertFalse(allRelations.contains(where: {
            $0.target == iOSOverloadGroupIdentifier || $0.source == iOSOverloadGroupIdentifier
        }))
    }
}

private extension Int {
    var asOverloadIdentifier: String {
        "s:SomeClass:someMethod-\(self)"
    }

    var asOverloadSymbol: SymbolGraph.Symbol {
        .init(
            identifier: .init(precise: self.asOverloadIdentifier, interfaceLanguage: "swift"),
            names: .init(title: "someMethod()", navigator: nil, subHeading: nil, prose: nil),
            pathComponents: ["SomeClass", "someMethod"],
            docComment: nil,
            accessLevel: .init(rawValue: "public"),
            kind: .init(parsedIdentifier: .method, displayName: "Instance Method"),
            mixins: [:])
    }

    var asOverloadRelationship: SymbolGraph.Relationship {
        .init(source: self.asOverloadIdentifier,
              target: "s:SomeClass",
              kind: .memberOf,
              targetFallback: nil)
    }
}

private extension UnifiedSymbolGraph {
    var unifiedRelationships: [SymbolGraph.Relationship] {
        struct RelationKey: Hashable {
            let source: String
            let target: String
            let kind: SymbolGraph.Relationship.Kind

            init(fromRelation relationship: SymbolGraph.Relationship) {
                self.source = relationship.source
                self.target = relationship.target
                self.kind = relationship.kind
            }

            static func makePair(fromRelation relationship: SymbolGraph.Relationship) -> (RelationKey, SymbolGraph.Relationship) {
                return (RelationKey(fromRelation: relationship), relationship)
            }
        }

        let allRelations = Dictionary(relationshipsByLanguage.values.joined().map({ RelationKey.makePair(fromRelation: $0) }), uniquingKeysWith: { r1, r2 in r1 })

        return Array(allRelations.values)
    }
}

private func makeOverloadsSymbolGraph(platform: String, withOverloads methodIndices: [Int]) -> SymbolGraph {
    let symbols: [SymbolGraph.Symbol] = [
        .init(
            identifier: .init(precise: "s:SomeClass", interfaceLanguage: "swift"),
            names: .init(title: "SomeClass", navigator: nil, subHeading: nil, prose: nil),
            pathComponents: ["SomeClass"],
            docComment: nil,
            accessLevel: .init(rawValue: "public"),
            kind: .init(parsedIdentifier: .class, displayName: "Class"),
            mixins: [:]),
    ] + methodIndices.map(\.asOverloadSymbol)
    let relations = methodIndices.map(\.asOverloadRelationship)

    return makeSymbolGraph(platform: platform, symbols: symbols, relations: relations)
}

private func makeSymbolGraph(platform: String, symbols: [SymbolGraph.Symbol], relations: [SymbolGraph.Relationship]) -> SymbolGraph {
    let metadata = SymbolGraph.Metadata(
        formatVersion: .init(major: 1, minor: 0, patch: 0),
        generator: "unit-test"
    )
    let module = SymbolGraph.Module(
        name: "DemoKit",
        platform: .init(
            architecture: "x86_64",
            vendor: "apple",
            operatingSystem: .init(name: platform),
            environment: nil
        )
    )
    var graph = SymbolGraph(
        metadata: metadata,
        module: module,
        symbols: symbols,
        relationships: relations
    )
    graph.createOverloadGroupSymbols()
    return graph
}

private func unifySymbolGraphs(
    moduleName: String = "DemoKit",
    _ graphs: (fileName: String, symbolGraph: SymbolGraph)...,
    file: StaticString = #file,
    line: UInt = #line
) throws -> UnifiedSymbolGraph {
    let collector = GraphCollector()
    for (fileName, symbolGraph) in graphs {
        collector.mergeSymbolGraph(symbolGraph, at: .init(fileURLWithPath: fileName))
    }
    return try XCTUnwrap(collector.finishLoading().unifiedGraphs[moduleName], file: file, line: line)
}
