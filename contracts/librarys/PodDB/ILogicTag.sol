// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./IPodCore.sol";

// LogicTagClass must implement this interface.
interface ILogicTag {
    //@dev get data of logic tag.
    //@param specific tagClassId and TagObject.
    //@returns the data of tag, and whether the tag exist.
    function getLogicTagData(
        bytes18 tagClassId,
        IPodCore.TagObject calldata object
    ) external view returns (bytes memory data, bool exist);
}
