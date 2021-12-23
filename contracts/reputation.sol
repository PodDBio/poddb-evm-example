// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./librarys/OpenZeppelin/Ownable.sol";
import "./librarys/PodDB/IPodDB.sol";
import "./librarys/PodDB/Helper.sol";
import "./librarys/PodDB/WriteBuffer.sol";

contract Reputation is Ownable {
    using Helper for *;
    using WriteBuffer for *;
    using ReadBuffer for *;

    IPodDB private _PodDB;
    bytes20 public ReputationTagClassId;

    constructor(address podBDAddress) Ownable() {
        _PodDB = IPodDB(podBDAddress);

        //create reputation tagClass;
        Helper.TagClassFieldBuilder memory builder;
        builder.init().put("Score", IPodDB.TagFieldType.Uint16, false);
        string memory tagClassName = "reputation";
        string memory tagClassDesc = "Reputation for user";
        uint8 tagClassFlags = 0;
        IPodDB.TagAgent memory agent;
        ReputationTagClassId = _PodDB.newTagClass(
            tagClassName,
            builder.getFieldNames(),
            builder.getFieldTypes(),
            tagClassDesc,
            tagClassFlags,
            agent
        );
    }

    // PodDB may upgrade in future, so it is very important to provide the ability to modify the PodDB contract address
    function setPodDB(address podDBAddress) public onlyOwner {
        _PodDB = IPodDB(podDBAddress);
    }

    function setReputation(uint16 reputation) public returns (bytes20) {
        IPodDB.TagObject memory object = IPodDB.TagObject(
            IPodDB.ObjectType.Address,
            msg.sender,
            0
        );
        WriteBuffer.buffer memory wBuf;
        bytes memory data = wBuf.init(2).writeUint16(reputation).getBytes();
        uint32 expiredTime = 0; //never expired;
        uint8 tagFlag = 0;
        bytes20 tagId = _PodDB.setTag(
            ReputationTagClassId,
            object,
            data,
            expiredTime,
            tagFlag
        );
        return tagId;
    }

    function getReputation(address user) public view returns (uint16 score) {
        IPodDB.TagObject memory object = IPodDB.TagObject(
            IPodDB.ObjectType.Address,
            user,
            0
        );
        bytes memory data = _PodDB.getTagData(ReputationTagClassId, object);
        if (data.length == 0) {
            return 0;
        }
        ReadBuffer.buffer memory rBuf = ReadBuffer.fromBytes(data);
        score = rBuf.readUint16();
        return score;
    }

    function deleteReputation(bytes20 tagId) public returns (bool) {
        IPodDB.TagObject memory object = IPodDB.TagObject(
            IPodDB.ObjectType.Address,
            msg.sender,
            0
        );
        return _PodDB.deleteTag(tagId, ReputationTagClassId, object);
    }

    function deprecatedReputationTagClass() public onlyOwner {
        IPodDB.TagClass memory reputationTagClass = _PodDB.getTagClass(
            ReputationTagClassId
        );
        reputationTagClass.Flags |= 128;
        _PodDB.updateTagClass(
            reputationTagClass.ClassId,
            reputationTagClass.Owner,
            reputationTagClass.Agent,
            reputationTagClass.Flags
        );
    }
}
