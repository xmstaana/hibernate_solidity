/**
 *Submitted for verification at Etherscan.io on 2021-12-16
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\ERC721.sol

pragma solidity ^0.8.0;

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-ALIENFRENSble Token Standard, including
 * the Metadata extension, but not including the Enumerable extension, which is available separately as
 * {ERC721Enumerable}.
 */
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
     * in child contracts.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        require(operator != _msgSender(), "ERC721: approve to caller");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(
            ERC721.ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver(to).onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    // solhint-disable-next-line no-inline-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}

// File: openzeppelin-solidity\contracts\token\ERC721\extensions\ERC721Enumerable.sol

pragma solidity ^0.8.0;

/**
 * @dev This implements an optional extension of {ERC721} defined in the EIP that adds
 * enumerability of all the token ids in the contract as well as all token ids owned by each
 * account.
 */
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, ERC721)
        returns (bool)
    {
        return
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index < ERC721.balanceOf(owner),
            "ERC721Enumerable: owner index out of bounds"
        );
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index)
        public
        view
        virtual
        override
        returns (uint256)
    {
        require(
            index < ERC721Enumerable.totalSupply(),
            "ERC721Enumerable: global index out of bounds"
        );
        return _allTokens[index];
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId)
        private
    {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}

// File: contracts\lib\Counters.sol

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        {
            counter._value = value - 1;
        }
    }
}

// File: openzeppelin-solidity\contracts\access\Ownable.sol

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity ^0.8.0;

import "./ERC721A.sol";

contract Kiguroomie is ERC721A, Ownable, ReentrancyGuard 
{
    using Counters for Counters.Counter;
    using Strings for uint256;

    uint256 public constant TOTAL_ROOMIES = 10000;
    uint256 public constant ALLOWABLE_ROOMIES = 3;
    uint256 public constant ROOMIE_PRICE = 0.05 ether;    

    string private _contractURI = "";
    string private _tokenBaseURI = "";

    // nft_property
    bool private _bKiguroomieNFT = false;
    bool roomieRevealed = false;
    string private roomieIPFS = "";
    string public roomieHiddenIPFS = "";

    // whitelist
    
    bool public _bWhitelistedRoomie = false;
    bool public _bRoomieWhiteListActive = false;
    uint256 public _whiteListedMaxMint = 3;
    struct RoomieWhiteListEntry
    {
        address roomieAddress;
        bool roomieWhiteListCheck;
        bool roomieWhiteListTester;
        uint256 roomieWhiteListMintedNFT;
    }
    RoomieWhiteListEntry[] _roomieWhiteList;

    //marketing
    address private _marketingWallet;
    bool private _bMarketingWalletMint = false;
    uint256 private constant MARKETING_MINT_COUNT = 250;

    // tokenID storage
    Counters.Counter private _iRoomieCount;

    // erc721 parameters
    string private constant CONTRACT_NAME = "Kiguroomie";
    string private constant CONTRACT_SYMBOL = "KIGU";

    // error messages
    string private constant EXCEED_MAX_AMOUNT_MSG = "Mint will exceed maximum capacity.";
    string private constant WHITELIST_INACTIVE_MSG = "Whitelisting currently inactive.";
    string private constant WHITELIST_INVALID_MSG = "Sender does not exist in whitelist.";
    string private constant OBSOLETE_ROOMIE_MSG = "Contract is not active.";
    string private constant NULL_ADDRESS_MSG = "Can't set null address.";
    string private constant ZERO_ADDRESS_MSG = "Zero address not on Roomie White List.";
    string private constant EXCEED_OWNER_LIMIT_MSG = "Minting amount exceeds maximum allowed.";
    string private constant INSUFFICIENT_FUNDS_MSG = "ETH amount is insufficient";
    string private constant ROOMIE_INVALID_MSG = "Kiguroomie does not exist.";
    string private constant WITHDRAW_INVALID_MSG = "Contract Withdraw Unsuccessful.";
    string private constant MARKETING_MINT_MSG = "Marketing NFT Minting is already done.";

    constructor() ERC721A(CONTRACT_NAME, CONTRACT_SYMBOL) {}

    function checkMintAllowed() internal view returns (bool)
    {
        bool isMintAllowed = false;
        if(_iRoomieCount.current() < TOTAL_ROOMIES)
            isMintAllowed = true;

        return isMintAllowed;
    }

    function getRoomiesLeft() public view returns (uint)
    {
        uint256 roomiesLeft = 0;

        roomiesLeft = TOTAL_ROOMIES - _iRoomieCount.current();

        return roomiesLeft;
    }

    function activateKiguroomieNFT() public onlyOwner {
        _bKiguroomieNFT = true;
        if (getMarketingWalletMintStatus() == true)
        {
            mintMarketingNFT();
        }
    }

    function deactivateKiguroomieNFT() public onlyOwner {
        _bKiguroomieNFT = false;
    }

    function setContractURI(string memory URI) public onlyOwner {
        _contractURI = URI;
    }

    function getContractURI() 
        public 
        view 
        returns (string memory) 
    {
        return _contractURI;
    }

    function setTokenURI(string memory URI) public onlyOwner {
        _tokenBaseURI = URI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721A)
        returns (string memory)
    {
        require(_exists(tokenId), ROOMIE_INVALID_MSG);

        return string(abi.encodePacked(_tokenBaseURI, tokenId.toString()));
    }

    // suggestion: add a functionality to swap address

    // owner minting
    function ownerMinting(address ownerAddress, uint256 roomieCount)
        public
        payable
        onlyOwner
    {
        require(checkMintAllowed(),EXCEED_MAX_AMOUNT_MSG);

        for (uint256 i = 0; i < roomieCount; i++) {
            //uint256 tokenId = _iRoomieCount.current();

            if (checkMintAllowed()) {
                _iRoomieCount.increment();
                //_safeMint(ownerAddress, tokenId);
            }
            _safeMint(ownerAddress,roomieCount);
        }
    }

    function setRoomieWhiteListActive(bool bRoomieWhiteListActive) public onlyOwner 
    {
        _bRoomieWhiteListActive = bRoomieWhiteListActive;
    }

    function getRoomieWhiteListActive() 
        public 
        view 
        returns (bool) 
    {
        return _bRoomieWhiteListActive;
    }

    function setWhiteListedMaxMint(uint256 whiteListedMaxMint) public onlyOwner 
    {
        _whiteListedMaxMint = whiteListedMaxMint;
    }

    function getWhiteListedRoomieIndex(address suspectedAddress) 
        public 
        view 
        returns(int256)
    {
        int256 index = -1;
        bool bRoomieWhiteListed = false;
        uint256 i = 0;

        while(i < _roomieWhiteList.length && !bRoomieWhiteListed) 
        {
            RoomieWhiteListEntry memory oneEntry = _roomieWhiteList[i];
            if(oneEntry.roomieAddress == suspectedAddress)
            {
                bRoomieWhiteListed = true;
                index = int256(i);
            }
            i++;
        }

        return index;
    }

    function checkIfRoomieWhiteListed(address suspectedAddress) 
        public 
        view 
        returns(bool)
    {
        bool bRoomieWhiteListed = false;

        if(getWhiteListedRoomieIndex(suspectedAddress) > 0)
            bRoomieWhiteListed = true;

        return bRoomieWhiteListed;
    }

    function addToRommieWhiteList(address[] calldata addresses) public onlyOwner 
    {
        if(getRoomieWhiteListActive())
        {
            for (uint256 i = 0; i < addresses.length; i++) 
            {
                address oneAddress = addresses[i];

                require(oneAddress != address(0), NULL_ADDRESS_MSG);
                if(checkIfRoomieWhiteListed(oneAddress))
                {
                    RoomieWhiteListEntry memory oneEntry;
                    oneEntry.roomieAddress = oneAddress;
                    oneEntry.roomieWhiteListCheck = true;
                    oneEntry.roomieWhiteListTester = false;
                    oneEntry.roomieWhiteListMintedNFT = 0;

                    _roomieWhiteList.push(oneEntry);
                }
            }
        }
    }

    function removeFromRommieWhiteList(address[] calldata addresses) public onlyOwner 
    {
        if(getRoomieWhiteListActive())
        {
            for (uint256 i = 0; i < addresses.length; i++) 
            {
                address oneAddress = addresses[i];

                require(oneAddress != address(0), NULL_ADDRESS_MSG);
                int256 index = getWhiteListedRoomieIndex(oneAddress);
                if (index > 0)
                {
                    for (uint256 h = uint(index); h < _roomieWhiteList.length - 1; h++)
                    {
                        _roomieWhiteList[h] = _roomieWhiteList[h + 1];
                    }
                    delete _roomieWhiteList[_roomieWhiteList.length-1];
                }
            }
        }
    }

    function getWhiteListedClaimedRoomie(address owner) public view returns (uint256)
    {
        require(owner != address(0), ZERO_ADDRESS_MSG);
        int256 roomieIndex = getWhiteListedRoomieIndex(owner);
        uint256 result = 0;
        if(roomieIndex > 0)
        {
            result = _roomieWhiteList[uint256(roomieIndex)].roomieWhiteListMintedNFT;
        }
        return result;
    }

    function whiteListedRoomieMint(uint256 mintCount) public payable nonReentrant 
    {
        address sender = msg.sender;
        int256 roomieIndex = getWhiteListedRoomieIndex(sender);
        
        require(_bKiguroomieNFT,OBSOLETE_ROOMIE_MSG);
        require(_bRoomieWhiteListActive, WHITELIST_INACTIVE_MSG);
        require(checkIfRoomieWhiteListed(sender), WHITELIST_INVALID_MSG);
        require(checkMintAllowed(),EXCEED_MAX_AMOUNT_MSG);
        require(mintCount >= ALLOWABLE_ROOMIES, EXCEED_OWNER_LIMIT_MSG);
        require(msg.value < ROOMIE_PRICE * mintCount, INSUFFICIENT_FUNDS_MSG);
        if(roomieIndex > 0)
        {
            require(_roomieWhiteList[uint256(roomieIndex)].roomieWhiteListMintedNFT + mintCount <= _whiteListedMaxMint, EXCEED_OWNER_LIMIT_MSG);

            for (uint256 i = 0; i < mintCount; i++) 
            {
                //uint256 tokenId = _iRoomieCount.current();

                if (_iRoomieCount.current() < TOTAL_ROOMIES) 
                {
                    _roomieWhiteList[uint256(roomieIndex)].roomieWhiteListMintedNFT += 1;
                    _iRoomieCount.increment();
                    //_safeMint(sender, tokenId);
                }
            }
            _safeMint(sender, mintCount);
        }
    }

    function roomieMint(uint256 mintCount) public payable nonReentrant 
    {
        require(_bKiguroomieNFT,OBSOLETE_ROOMIE_MSG);
        require(checkMintAllowed(),EXCEED_MAX_AMOUNT_MSG);
        require(mintCount >= ALLOWABLE_ROOMIES, EXCEED_OWNER_LIMIT_MSG);
        require(msg.value < ROOMIE_PRICE * mintCount, INSUFFICIENT_FUNDS_MSG);

        for (uint256 i = 0; i < mintCount; i++) {
            //uint256 tokenId = _iRoomieCount.current();

            if (_iRoomieCount.current() < TOTAL_ROOMIES) 
            {
                _iRoomieCount.increment();
                //_safeMint(msg.sender, tokenId);
            }
        }
        _safeMint(msg.sender, mintCount);
    }

    // Marketing Functions Start
    function getMarketingWalletMintStatus() public view onlyOwner returns (bool)
    {
        return _bMarketingWalletMint;
    }

    function setMarketingWallet(address marketingWallet) public onlyOwner
    {
        require(marketingWallet != address(0), NULL_ADDRESS_MSG);
        _marketingWallet = marketingWallet;
    }

    function getMarketingWallet() public view onlyOwner returns (address)
    {
        return _marketingWallet;
    }

    function mintMarketingNFT() public onlyOwner
    {
        require(_bKiguroomieNFT,OBSOLETE_ROOMIE_MSG);
        require(!getMarketingWalletMintStatus(), MARKETING_MINT_MSG);
        _bMarketingWalletMint = true;
        ownerMinting(_marketingWallet, MARKETING_MINT_COUNT);
    }
    // Marketing Functions End

    // Web3 Economics Start
    function withdrawAll() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0);
        _widthdraw(msg.sender, address(this).balance);
    }

    function _widthdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{value: _amount}("");
        require(success, WITHDRAW_INVALID_MSG);
    }
    // Web3 Economics End

}