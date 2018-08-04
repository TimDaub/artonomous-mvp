pragma solidity ^0.4.24; //solhint-disable-line compiler-fixed

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Metadata.sol";


contract ArtonomousArtPieceToken is ERC721Token, Ownable {
    address public metadata;
    mapping(uint => string) public generators;
    address public artonomous;

    constructor(string name, string symbol) public ERC721Token(name, symbol) {
        artonomous = msg.sender;
    }

    /**
    * @dev For returning the URL of the JSON object describing the token.
    * @return A string of the URL.
    */
    function tokenURI(uint _tokenId) public view returns (string _infoUrl) {
        address _impl = implementation();
        bytes memory data = msg.data;
        assembly {
            let result := delegatecall(gas, _impl, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    /**
    * @dev Used to avoid restriction to local variables in tokenURI
    * @return An address of the upgradeable metadata contract.
    */
    function implementation() public view returns (address) {
        return metadata;
    }

    /**
    * @dev Used to update the address of the metadata contract in case it needs to be upgraded
    */
    function updateMetadataAddress(address _metadata) public onlyOwner {
        require(_metadata != 0);
        metadata = _metadata;
    }

    /**
    * @dev Used to mint new artworks and log the generator used.
    */
    function mint(uint _blocknumber, string _generator) public {
        require(msg.sender == artonomous);
        // blockNumber is the tokenId
        _mint(artonomous, _blocknumber); // minted towards artonomous. It originally owns artwork until sold.
        generators[_blocknumber] = _generator;
    }
}
