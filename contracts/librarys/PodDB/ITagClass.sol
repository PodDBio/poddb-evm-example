// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./IPodCore.sol";

interface ITagClass {
    event NewTagClass(
        bytes18 indexed classId,
        string name,
        address indexed owner,
        bytes fieldNames,
        bytes fieldTypes,
        string desc,
        uint8 flags,
        IPodCore.TagAgent agent,
        address logicContract
    );

    event TransferTagClassOwner(
        bytes18 indexed classId,
        address indexed newOwner
    );

    event UpdateTagClass(
        bytes18 indexed classId,
        uint8 flags,
        IPodCore.TagAgent agent,
        address logicContract
    );

    event UpdateTagClassInfo(bytes18 indexed classId, string name, string desc);

    function newValueTagClass(
        string calldata tagName,
        bytes calldata fieldNames,
        bytes calldata fieldTypes,
        string calldata desc,
        uint8 flags,
        IPodCore.TagAgent calldata agent
    ) external returns (bytes18);

    function newLogicTagClass(
        string calldata tagName,
        bytes calldata fieldNames,
        bytes calldata fieldTypes,
        string calldata desc,
        uint8 flags,
        address logicContract
    ) external returns (bytes18 classId);

    function updateValueTagClass(
        bytes18 classId,
        uint8 newFlags,
        IPodCore.TagAgent calldata newAgent
    ) external;

    function updateLogicTagClass(
        bytes18 classId,
        uint8 newFlags,
        address newLogicContract
    ) external;

    function updateTagClassInfo(
        bytes18 classId,
        string calldata tagName,
        string calldata desc
    ) external;

    function transferTagClassOwner(bytes18 classId, address newOwner) external;

    function getTagClass(bytes18 tagClassId)
        external
        view
        returns (IPodCore.TagClass memory tagClass);

    function getTagClassInfo(bytes18 tagClassId)
        external
        view
        returns (IPodCore.TagClassInfo memory classInfo);
}
