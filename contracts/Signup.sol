pragma experimental ABIEncoderV2;
pragma solidity >0.4.99 <0.6.0;


contract Signup {
    struct account {
        uint256 id;
        address owner;
        string userName;
        string email;
        string phoneNumber;
        string phAddress;
        string password;
        string logoLink;
        bool labo;
    }

    struct signupRequest {
        address owner;
        uint256 id;
        string date;
        string name;
        string phAddress;
        string email;
        string phoneNumber;
        string password;
        string logoLink;
        bool pending;
        bool approved;
    }

    mapping(uint256 => account) public accounts;
    mapping(address => bool) public adminAccounts;
    mapping(uint256 => signupRequest) public signupRequestsId;
    mapping(address => signupRequest) public signupRequestsAddress;

    // State variables
    uint256 accountsCounter;
    uint256 signupRequestCounter;

    function initContract() public {
        adminAccounts[msg.sender] = true;
    }

    function signupAsClient(
        address _address,
        string memory _userName,
        string memory _email,
        string memory phoneNumber,
        string memory _password
    ) public {
        // store account
        accountsCounter++;
        accounts[accountsCounter] = account(
            accountsCounter,
            _address,
            _userName,
            _email,
            phoneNumber,
            "",
            _password,
            "",
            false
        );
    }

    function signupAsLabo(
        address _address,
        string memory requestDate,
        string memory laboName,
        string memory phAddress,
        string memory _email,
        string memory _password,
        string memory logoLink
    ) public {
        signupRequestCounter++;
        signupRequestsId[signupRequestCounter] = signupRequest(
            _address,
            signupRequestCounter,
            requestDate,
            laboName,
            phAddress,
            _email,
            "",
            _password,
            logoLink,
            true,
            false
        );
        signupRequestsAddress[_address] = signupRequest(
            _address,
            signupRequestCounter,
            requestDate,
            laboName,
            phAddress,
            _email,
            "",
            _password,
            logoLink,
            true,
            false
        );
    }

    function approveRequest(uint256 id) public {
        require(adminAccounts[msg.sender], "You are not admin");
        signupRequest memory request = signupRequestsId[id];
        signupRequestsId[id] = signupRequest(
            request.owner,
            request.id,
            request.date,
            request.name,
            request.phAddress,
            request.email,
            request.phoneNumber,
            request.password,
            request.logoLink,
            false,
            true
        );
        signupRequestsAddress[request.owner] = signupRequest(
            request.owner,
            request.id,
            request.date,
            request.name,
            request.phAddress,
            request.email,
            request.phoneNumber,
            request.password,
            request.logoLink,
            false,
            true
        );
        accountsCounter++;
        accounts[accountsCounter] = account(
            accountsCounter,
            request.owner,
            request.name,
            request.email,
            request.phoneNumber,
            request.phAddress,
            request.password,
            request.logoLink,
            true
        );
    }

    function refuseRequest(uint256 id) public {
        require(adminAccounts[msg.sender], "You are not admin");
        signupRequest memory request = signupRequestsId[id];
        signupRequestsId[id] = signupRequest(
            request.owner,
            request.id,
            request.date,
            request.name,
            request.phAddress,
            request.email,
            request.phoneNumber,
            request.password,
            request.logoLink,
            false,
            false
        );
        signupRequestsAddress[request.owner] = signupRequest(
            request.owner,
            request.id,
            request.date,
            request.name,
            request.phAddress,
            request.email,
            request.phoneNumber,
            request.password,
            request.logoLink,
            false,
            false
        );
    }

    function checkRequest(address _address)
        public
        view
        returns (string memory)
    {
        signupRequest memory request = signupRequestsAddress[_address];
        if (request.owner == address(0)) {
            return "null";
        }
        if (request.pending) {
            return "pending";
        } else {
            if (request.approved) {
                return "approved";
            } else {
                return "refused";
            }
        }
    }

    function getSignupRequestCounter() public view returns (uint256) {
        return signupRequestCounter;
    }

    function getSignupRequestPending() public view returns (uint256[] memory) {
        if (signupRequestCounter == 0) {
            return new uint256[](0);
        }
        uint256[] memory pendingRequests = new uint256[](signupRequestCounter);
        uint256 numberOfPendingRequests = 0;
        for (uint256 i = 1; i <= signupRequestCounter; i++) {
            if (signupRequestsId[i].approved == false) {
                pendingRequests[numberOfPendingRequests] = signupRequestsId[i]
                    .id;
                numberOfPendingRequests++;
            }
        }
        uint256[] memory finalPendingRequests = new uint256[](
            numberOfPendingRequests
        );
        for (uint256 i = 0; i < numberOfPendingRequests; i++) {
            finalPendingRequests[i] = pendingRequests[i];
        }
        return finalPendingRequests;
    }

    function editUserInfo(
        uint256 _id,
        string memory _userName,
        string memory _email,
        string memory phoneNumber,
        string memory _password,
        string memory _phAddress,
        string memory logoLink
    ) public {
        account memory userAccount = accounts[_id];
        // require(userAccount.owner == msg.sender, "This is not your acccount");

        accounts[_id] = account(
            _id,
            userAccount.owner,
            _userName,
            _email,
            phoneNumber,
            _phAddress,
            _password,
            logoLink,
            userAccount.labo
        );
    }

    function getAccountById(uint256 _id) public view returns (account memory) {
        return (accounts[_id]);
    }

    function getAccountByAddress(address _address)
        public
        view
        returns (account memory)
    {
        for (uint256 i = 1; i <= accountsCounter; i++) {
            if (accounts[i].owner == _address) {
                return (accounts[i]);
            }
        }
        return accounts[0];
    }

    function getAccountsIds() public view returns (uint256[] memory) {
        if (accountsCounter == 0) {
            return new uint256[](0);
        }
        uint256[] memory accountIds = new uint256[](accountsCounter);
        uint256 numberOfAccounts = 0;
        // iterate over accounts
        for (uint256 i = 1; i <= accountsCounter; i++) {
            accountIds[numberOfAccounts] = accounts[i].id;
            numberOfAccounts++;
        }
        return accountIds;
    }
}