// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract ChatApp{

    //USER STRUCT
    struct user{
        string name;
        friend[] friendList;
    }

    struct friend{
        address pubkey;
        string name;
    }

    struct message{
        address sender;
        uint256 timestamp;
        string msg;
    }

    //To register all users in our app
    mapping(address => user) userList;
    //Thos mapping will provide all the communication between the user and its friends
    //remember the message array will contain messages b/w two users
    mapping(bytes32 => message[]) allMessages;

    //CHECK USER EXIST
    function checkUserExists(address pubkey) public view returns(bool){
        return bytes(userList[pubkey].name).length > 0;
    }

    //CREATE ACCOUNT
    //For creating this function we will set some conditions which include:
    //1. First we have to check whether the user already exists. so checkUserExists Function will be called and senders address is passed
    //2. make sure users provide a name for the registration process
    function createAccount(string calldata name) external {
        require(checkUserExists(msg.sender) == false, "User already Exists");
        require(bytes(name).length>0, "Username cannot be empty");

        userList[msg.sender].name = name;
    }

    //GET USERNAME
    //Now we will create a function that will allow us to retrieve a user by providing address
    //The function will receive the address and is an external function so that anyone can call it
    //The function will return a string memory
    //Conditions:
    //Check whether the persons address exist in our smart contract or not
    //If the user address exists the function will return the user name from the userList
    function getUsername(address pubkey) external view returns(string memory) {
        require(checkUserExists(pubkey), "User is not registered");
        return userList[pubkey].name;
    }

    //ADD FRIENDS
    //We will pass freind_key and name as parameters
    //Conditions:
    //Check if that person is a user or not
    //Check whether the person who wants to add a friend has already created an account or not
    //Someone can not add thmeselves as a friend
    function addFriend(address friend_key, string calldata name) external {
        require(checkUserExists(msg.sender), "Create an account first");
        require(checkUserExists(friend_key), "User is not registered");
        require(msg.sender != friend_key, "User can not add themselves as friend ");
        require(checkAlreadyFriends(msg.sender, friend_key)==false, "These users are already friends");

        //Once all conditions are fulfilled we will call the addFriend Func

        _addFriend(msg.sender, friend_key, name);
        _addFriend(friend_key, msg.sender, userList[msg.sender].name);
    }

    //CHECKALREADYFRIENDS
    //didnt understand the logic here ---U
    function checkAlreadyFriends(address pubkey1, address pubkey2) internal view returns(bool) {
        if(userList[pubkey1].friendList.length > userList[pubkey2].friendList.length){
            address tmp= pubkey1;
            pubkey1 = pubkey2;
            pubkey2= pubkey1;
        }

        for(uint256 i=0; i < userList[pubkey1].friendList.length; i++){
            if(userList[pubkey1].friendList[i].pubkey == pubkey2) return true;
        }
        return false;
    }

    function _addFriend(address me, address friend_key, string memory name) internal{
        friend memory newFriend =friend(friend_key, name);
        userList[me].friendList.push(newFriend);
    }


}