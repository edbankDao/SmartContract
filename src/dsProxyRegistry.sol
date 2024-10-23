// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

abstract contract DSAuthority {
    function canCall(
        address src,
        address dst,
        bytes4 sig
    ) external view virtual returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority public authority;
    address public owner;

    constructor() {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) public auth {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_) public auth {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth() {
        require(isAuthorized(msg.sender, msg.sig), "DSAuth: Not authorized");
        _;
    }

    function isAuthorized(
        address src,
        bytes4 sig
    ) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(address(0))) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

contract DSNote {
    event LogNote(
        bytes4 indexed sig,
        address indexed guy,
        bytes32 indexed foo,
        bytes32 indexed bar,
        uint256 wad,
        bytes fax
    ) anonymous;

    modifier note() {
        bytes32 foo;
        bytes32 bar;
        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }
        emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);
        _;
    }
}

contract DSProxy is DSAuth, DSNote {
    DSProxyCache public cache; // global cache for contracts

    constructor(address _cacheAddr) {
        setCache(_cacheAddr);
    }

    receive() external payable {}

    // Execute actions atomically through the proxy's identity
    function execute(
        bytes memory _code,
        bytes memory _data
    ) public payable returns (address target, bytes32 response) {
        target = cache.read(_code);
        if (target == address(0)) {
            target = cache.write(_code);
        }
        response = execute(target, _data);
    }

    function execute(
        address _target,
        bytes memory _data
    ) public payable auth note returns (bytes32 response) {
        require(_target != address(0), "DSProxy: Target address is null");

        // Call the contract in the current context
        assembly {
            let succeeded := delegatecall(
                gas(),
                _target,
                add(_data, 0x20),
                mload(_data),
                0,
                32
            )
            response := mload(0)
            switch iszero(succeeded)
            case 1 {
                revert(0, 0)
            }
        }
    }

    function setCache(
        address _cacheAddr
    ) public payable auth note returns (bool) {
        require(_cacheAddr != address(0), "DSProxy: Invalid cache address");
        cache = DSProxyCache(_cacheAddr);
        return true;
    }
}

contract DSProxyFactory {
    event Created(
        address indexed sender,
        address indexed owner,
        address proxy,
        address cache
    );
    mapping(address => bool) public isProxy;
    DSProxyCache public cache = new DSProxyCache();

    function build() external returns (DSProxy proxy) {
        proxy = build(msg.sender);
    }

    function build(address owner) public returns (DSProxy proxy) {
        proxy = new DSProxy(address(cache));
        emit Created(msg.sender, owner, address(proxy), address(cache));
        proxy.setOwner(owner);
        isProxy[address(proxy)] = true;
    }
}

contract DSProxyCache {
    mapping(bytes32 => address) public cache;

    function read(bytes memory _code) public view returns (address) {
        bytes32 hash = keccak256(_code);
        return cache[hash];
    }

    function write(bytes memory _code) public returns (address target) {
        assembly {
            target := create(0, add(_code, 0x20), mload(_code))
            switch iszero(extcodesize(target))
            case 1 {
                revert(0, 0)
            }
        }
        bytes32 hash = keccak256(_code);
        cache[hash] = target;
    }
}

contract ProxyRegistry {
    mapping(address => DSProxy) public proxies;
    DSProxyFactory public factory;

    constructor(DSProxyFactory factory_) {
        factory = factory_;
    }

    function build() public returns (DSProxy proxy) {
        proxy = build(msg.sender);
    }

    function build(address owner) public returns (DSProxy proxy) {
        require(
            address(proxies[owner]) == address(0) ||
                proxies[owner].owner() != owner,
            "ProxyRegistry: Existing proxy detected"
        );
        proxy = factory.build(owner);
        proxies[owner] = proxy;
    }
}
