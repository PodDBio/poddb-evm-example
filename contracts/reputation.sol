// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./librarys/OpenZeppelin/Ownable.sol";
import "./librarys/PodDB/IPodCore.sol";
import "./librarys/PodDB/ITag.sol";
import "./librarys/PodDB/ITagClass.sol";
import "./librarys/PodDB/Helper.sol";
import "./librarys/PodDB/WriteBuffer.sol";

contract Reputation is Ownable {
    using Helper for *;
    using WriteBuffer for *;
    using ReadBuffer for *;

    ITag private _Tag;
    ITagClass private _TagClass;
    bytes18 public ReputationTagClassId;

    constructor(address tagAddress, address tagClassAddress) Ownable() {
        _Tag = ITag(tagAddress);
        _TagClass = ITagClass(tagClassAddress);

        //create reputation tagClass;
        Helper.TagClassFieldBuilder memory builder;
        builder.init().put("Score", IPodCore.TagFieldType.Uint16, false);
        string memory tagClassName = "reputation";
        string memory tagClassDesc = "Reputation for user";
        uint8 tagClassFlags = 0;
        IPodCore.TagAgent memory agent;
        ReputationTagClassId = _TagClass.newValueTagClass(
            tagClassName,
            builder.getFieldNames(),
            builder.getFieldTypes(),
            tagClassDesc,
            tagClassFlags,
            agent
        );
    }

    // PodDB may upgrade in future, so it is very important to provide the ability to modify the
    // Tag contract address and TagClass contract address.
    function setPodDB(address tagAddress, address tagClassAddress)
        public
        onlyOwner
    {
        _Tag = ITag(tagAddress);
        _TagClass = ITagClass(tagClassAddress);
    }

    function setReputation(uint16 reputation, address user) public onlyOwner {
        IPodCore.TagObject memory object = IPodCore.TagObject(
            IPodCore.ObjectType.Address,
            bytes20(user),
            0
        );
        WriteBuffer.buffer memory wBuf;
        bytes memory data = wBuf.init(2).writeUint16(reputation).getBytes();
        uint32 expiredTime = 0; //never expired;
        _Tag.setTag(ReputationTagClassId, object, data, expiredTime);
    }

    function getReputation(address user) public view returns (uint16 score) {
        IPodCore.TagObject memory object = IPodCore.TagObject(
            IPodCore.ObjectType.Address,
            bytes20(user),
            0
        );
        bytes memory data = _Tag.getTagData(ReputationTagClassId, object);
        if (data.length == 0) {
            return 0;
        }
        ReadBuffer.buffer memory rBuf = ReadBuffer.fromBytes(data);
        score = rBuf.readUint16();
        return score;
    }

    function deleteReputation(address user) public onlyOwner {
        IPodCore.TagObject memory object = IPodCore.TagObject(
            IPodCore.ObjectType.Address,
            bytes20(user),
            0
        );
        _Tag.deleteTag(ReputationTagClassId, object);
    }

    function deprecatedReputationTagClass() public onlyOwner {
        IPodCore.TagClass memory reputationTagClass = _TagClass.getTagClass(
            ReputationTagClassId
        );
        reputationTagClass.Flags |= 128;
        _TagClass.updateValueTagClass(
            reputationTagClass.ClassId,
            reputationTagClass.Flags,
            reputationTagClass.Agent
        );
    }
}
