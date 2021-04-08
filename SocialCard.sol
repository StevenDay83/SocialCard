pragma solidity ^0.8.0;

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/utils/math/SafeMath.sol";
import "https://raw.githubusercontent.com/StevenDay83/SolidityHelper/main/solhelper.sol";
import "./Strings.sol";

contract SocialCard {
    using SafeMath for uint256;
    using Strings for string;
    
    address constant nullAddress = 0x0000000000000000000000000000000000000000;
    bytes32 constant emptyString = 0x569e75fc77c1a856f6daaf9e69d8a9566ca34aa47f9133711ce065a571af0cfd;
    
    mapping (address => bool) internal ownerMapping;
    mapping (address => string) internal addressUserMapping;
    mapping (string => bool) internal userNameMapping;
    mapping (string => socialInfo) internal socialInfoMapping;
    mapping (uint256 => string) internal socialInfoSchema;
    
    uint256 internal socialInfoSchemaID = 0;
    
    struct socialInfo {
        address userAddress;
        uint256 createdTime;
        uint256 modifiedTime;
        mapping (uint256 => string) socialField;
    }
    
    socialInfo[] internal socialInfoConstructor;
    
    event successBool (bool, string);
    event printString (string);
    event printInt (uint256);
    event socialCardMetaData (uint256, uint256);
    
    constructor() {
        ownerMapping[msg.sender] = true;
        
        addSocialInfoSchema("Full Name");
    }
    
    modifier onlyOwner {
        require(ownerMapping[msg.sender], "Error: Not contract owner");
        _;
    }
    
    function getSocialInfoSchemaSize () public view returns (uint256) {
        return socialInfoSchemaID;
    }
    
    function addSocialInfoSchema(string memory _fieldName) public onlyOwner {
        if (!isEmptyString(_fieldName)) {
            uint256 _schemaIndex = getNextSocialSchemaID();
            socialInfoSchema[_schemaIndex] = _fieldName;
            emit successBool(true, "Status: Field Created");
        } else {
            emit successBool(false, "Error: Field Name cannot be empty");
        }
    }
    
    function changeSocialInfoSchemaFieldName(uint256 _schemaIndex, string memory _fieldName) public onlyOwner {
        if (!isEmptyString(_fieldName)){
            if (_schemaIndex > 0 && _schemaIndex <= socialInfoSchemaID ) {
                socialInfoSchema[_schemaIndex] = _fieldName;
            } else {
                emit successBool(false, "Error: Invalid Schema Index");
            }
        } else {
            emit successBool(false, "Error: Field Name cannot be empty");
        }
    }
    
    function removeSocialInfoSchema() public onlyOwner {
        if (socialInfoSchemaID > 0){
            delete socialInfoSchema[socialInfoSchemaID];
            socialInfoSchemaID--;
            
            emit successBool(true, "Status: Schema removed");    
        } else {
            emit successBool(false, "Error: Schema Empty");
        }
    }
    
    function getSocialInfoSchemaAt(uint256 _schemaIndex) public view returns (string memory) {
        string memory _schemaField;
        
        if (!isEmptyString(socialInfoSchema[_schemaIndex])){
            _schemaField = socialInfoSchema[_schemaIndex];
        }
        
        return _schemaField;
    }
    
    function getNextSocialSchemaID() internal returns (uint256) {
        return ++socialInfoSchemaID;
    }
    
    function createNewUser (string memory _userName) public {
        _userName = _userName.lower();
        
        if (userNameExists(_userName)) {
            emit successBool(false, "Error: Username exists.");
        } else {
            addressUserMapping[msg.sender] = _userName;
            userNameMapping[_userName] = true;
            socialInfoMapping[_userName].userAddress = msg.sender;
            
            emit successBool(true, "Status: Username created");
        }
    }
    
    function getUserName () public view returns (string memory) {
        return addressUserMapping[msg.sender];
    }
    
    function deleteUser(string memory _userName) public {
        _userName = _userName.lower();
        
        if (userNameExists(_userName)){
            if (isOwnerOfUsername(_userName) || ownerMapping[msg.sender]){
                delete addressUserMapping[socialInfoMapping[_userName].userAddress];
                delete userNameMapping[_userName];
                delete socialInfoMapping[_userName];
                
                emit successBool(true, "Status: Username removed.");
            } else {
                emit successBool(false, "Error: You are not username owner.");
            }
        } else {
            emit successBool(false, "Error: Username does not exist.");
        }
    }
    
    function deleteUser() public {
        deleteUser(addressUserMapping[msg.sender]);
    }
    
    function createSocialCard (string memory _userName, string memory _fullName) public {
        _userName = _userName.lower();
        
        if (userNameExists(_userName) && isOwnerOfUsername(_userName)){
            // socialInfoMapping[_userName].userAddress = msg.sender;
            socialInfoMapping[_userName].modifiedTime = block.timestamp;
            socialInfoMapping[_userName].createdTime = block.timestamp;
            socialInfoMapping[_userName].socialField[1] = _fullName;
            
            emit successBool(true, "Status: Social card created.");
        } else {
            emit successBool(false, "Error: Username does not exist or you are not the owner.");
        }
    }
    
    function editSocialCardField(string memory _userName, uint256 _fieldIndex, string memory _fieldValue) public {
        _userName = _userName.lower();
        
        if (userNameExists(_userName) && isOwnerOfUsername(_userName)){
            if (_fieldIndex > 0 && _fieldIndex <= socialInfoSchemaID){
                socialInfo storage newSocialCard = socialInfoMapping[_userName];
                
                newSocialCard.socialField[_fieldIndex] = _fieldValue;
                newSocialCard.modifiedTime = block.timestamp;
                
                emit successBool(true, "Status: Field added or updated.");
            } else {
                 emit successBool(false, "Error: Field index invalid.");
            }
        } else {
            emit successBool(false, "Error: Username does not exist or you are not the owner.");
        }
    }
    
    function getSocialCardMetaData(string memory _userName) public view returns (uint256[2] memory){
        uint256[2] memory metaData;
        _userName = _userName.lower();
        
        if (userNameExists(_userName)){
            socialInfo storage newSocialCard = socialInfoMapping[_userName];
            metaData = [newSocialCard.createdTime, newSocialCard.modifiedTime];
        }
        
        return metaData;
    }
    
    function getSocialCardField(string memory _userName, uint256 _fieldIndex) public view returns (string memory) {
        _userName = _userName.lower();
        string memory fieldValue;
        
        if (userNameExists(_userName)){
            if (_fieldIndex > 0 && _fieldIndex <= socialInfoSchemaID){
                fieldValue = socialInfoMapping[_userName].socialField[_fieldIndex];
            }
        }
        
        return fieldValue;
    }
    
    function isOwnerOfUsername(string memory _userName) internal view returns (bool) {
        string memory assignedUserName = addressUserMapping[msg.sender];
        
        return stringEquals(assignedUserName, _userName);
    }
    
    function userNameExists(string memory _userName) internal view returns (bool) {
        return (userNameMapping[_userName]);
    }

    
    function isEmptyString(string memory _string) internal pure returns (bool) {
    bytes32 _bytesStrings = keccak256(abi.encode(_string));

    return (_bytesStrings == emptyString);
    }
    
    function stringEquals(string memory _s1, string memory _s2) internal pure returns (bool) {
        return (keccak256(abi.encode(_s1)) == keccak256(abi.encode(_s2)));
    }
    
}