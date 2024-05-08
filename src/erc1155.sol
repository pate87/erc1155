// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Compatible with OpenZeppelin Contracts ^5.0.0
// import OpenZeppelin contracts
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC1155Supply} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import {ERC1155Pausable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";

// Import other contracts
import { Whitelist } from "./Whitelist.sol";
import { PriceConverter } from "./PriceConverter.sol";

contract MyToken is
    ERC1155,
    AccessControl,
    ERC1155Pausable,
    ERC1155Burnable,
    ERC1155Supply
{
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Helper variable
    // Todo: Set up oracle to get $ price
    uint256 public constant PRICE = 0.01 ether;

    // Whitelist contract instance
    Whitelist whitelist;

    // Custum error messages
    error CallerNotMinter(address caller);
    error CallerNotAdmin(address caller);

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    constructor(address whitelistContract)
        ERC1155(
            "ttps://ipfs.io/ipns/QmU5kCop96Ldt7hBHhEF9k431DcxBdKnN262Btnvo51XdZ/"
        )
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        whitelist = Whitelist(whitelistContract);
    }

    mapping(address => bool) public checkToMintNFT;
    mapping (uint256 => bool) public isNFT;
    // mapping (address => bool) public Whitelist;

    function setURI(
        string memory newuri,
        uint256 id
    ) public onlyRole(URI_SETTER_ROLE) returns (string memory) {
        require(exists(id), "Id not set, no image availble");
        require(
            isNFT[id],
            "ID is incorrectly marked as fungible (ERC-20)"
        );
        newuri = string(
            abi.encodePacked(newuri)
        );
        _setURI(newuri);
        return newuri;
    }

    /**
    * Todo: Test multiple URIs whether / is implemented before calling id
    * If necessary add "/" before calling id to ensure that each URI call has a / in front of id.
    **/

    function uri(
        uint256 id
    ) public view virtual override returns (string memory) {
        require(exists(id), "Id not set, no image availble");
        require(isNFT[id], "ID is incorrectly marked as fungible (ERC-20)");
        return
            string(
                abi.encodePacked(super.uri(id), Strings.toString(id), ".json")
            );
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
    * Todo: instead using _grantRole(MINTER_ROLE, msg.sender) it might be better to use a mapping (address => bool) minter
    * this way it should be possible to set a certain time for the role and force the player to pay monthly to hold the minter role.
    **/
    function setMinterRole() public payable returns (bool) {
        require(msg.value >= PRICE, "Your amount is to small");
        (bool success, ) = payable(msg.sender).call{value: msg.value}("");
        require(success, "Failed to send Ether");

        return _grantRole(MINTER_ROLE, msg.sender);
    }

    // Helper function
    /**
    * Todo: Test function if id > than current id = id--
    */
    function testID(uint256 id) internal view returns (uint256) {
        uint256 newTokenID = id;
        if (exists(id)) {
            newTokenID = id + 1;
            return newTokenID;
        } else {
            return newTokenID;
        }
    }

    function mint(uint256 id, uint256 amount, bool isERC721) public payable {
        // Check that the calling account has the minter role
        // if (!hasRole(MINTER_ROLE, msg.sender)) {
        //     revert CallerNotMinter(msg.sender);
        // }

        // Ensure only one NFT can be minted for ERC721
        if (isERC721) {
            // Check if the ID exists and get a new ID if necessary
            if (exists(id)) {
                // Increment id
                id = testID(id);

                require(amount == 1, "NFTs are rare");

                // Check for ERC-20 tokens that are bought through paying the contract
                // Currently the requier test whether only token ID of 0 is >= 10000000000
                // Todo: requrie(msg.sender, id) >= necessaryERC20amount
                require(
                    balanceOf(msg.sender, 0) >= 10000000000,
                    "You don't have enough Gold tokens to mint a NFT"
                );

                checkToMintNFT[msg.sender] = true;

                // New require condition
                // require(checkToMintNFT[msg.sender] == true, "You're not allowed to mint NFT");

                isNFT[id] = true;
            
                // Mint the ERC721 token
                _mint(msg.sender, id, 1, "");

                // Might be an issue in thought mind
                // Perhaps only use msg.sender to burn tokens from the account that also mint the ECR-721 token
                if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
                    // Burn the ERC-20 token to ensure that the account that minted the NFT isn't able to create a new NFT only if the account has enough ERC-20 token
                    // Todo: _burn(msg.sender, id, necessaryERC20amount)
                    _burn(msg.sender, 0, 10000000000);
                }
            }
        } else if (whitelist.whitelistedAddresses(msg.sender) || hasRole(MINTER_ROLE, msg.sender)) {

            // Mint the ERC1155 token
            _mint(msg.sender, id, amount, "");
        } else {
            require(msg.value >= PRICE, "Your amount is to small");
            
            uint256 balanceOfContract = address(this).balance;
            balanceOfContract += msg.value;
            
            // Mint the ERC-20 token
            _mint(msg.sender, id, amount, "");
        }
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        _mintBatch(to, ids, amounts, data);
    }

    // function getContractBalance() public view returns (uint256) {
    //     return address(this).balance;
    // }

    // function testpay() public payable returns (uint256) {
    //     // (bool success, ) = payable(msg.sender).call{value: msg.value}("");
    //     // balanceOfContract = address(this).balance;
    //     uint256 balanceOfContract = address(this).balance;
    //     balanceOfContract += msg.value;
    //     // require(success, "Failed to send Ether");
    //     return address(this).balance;
    // }

    // Withdraw function to pay the admin if the contract has ETH in it
    function withdraw () public  payable {
         // Check that the calling account has the minter role
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert CallerNotAdmin(msg.sender);
        }

        // Send the ETH
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Failed to send Ether");
    }

    // Burn function so everybody can tokens burn only exeption is ADMIN - should prevent rug pull
    function burn(uint256 _id, uint256 amount) public {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            // Burn the ERC-20 token to ensure that the account that minted the NFT isn't able to create a new NFT only if the account has enough ERC-20 token
            _burn(msg.sender, _id, amount);
        }
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal override(ERC1155, ERC1155Pausable, ERC1155Supply) {
        super._update(from, to, ids, values);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

