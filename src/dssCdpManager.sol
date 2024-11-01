// SPDX-License-Identifier: AGPL-3.0-or-later

/// DssCdpManager.sol

// Copyright (C) 2018-2020 Maker Ecosystem Growth Holdings, INC.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity >=0.5.12;

interface VatLike {
    function urns(bytes32, address) external view returns (uint256, uint256);
    function hope(address) external;
    function flux(bytes32, address, address, uint256) external;
    function move(address, address, uint256) external;
    function frob(bytes32, address, address, address, int256, int256) external;
    function fork(bytes32, address, address, int256, int256) external;
}

contract UrnHandler {
    constructor(address vat) public {
        VatLike(vat).hope(msg.sender);
    }
}

contract DssCdpManager {
    address public vat;
    uint256 public cdpi; // Auto incremental
    mapping(uint256 => address) public urns; // CDPId => UrnHandler
    mapping(uint256 => List) public list; // CDPId => Prev & Next CDPIds (double linked list)
    mapping(uint256 => address) public owns; // CDPId => Owner
    mapping(uint256 => bytes32) public ilks; // CDPId => Ilk

    mapping(address => uint256) public first; // Owner => First CDPId
    mapping(address => uint256) public last; // Owner => Last CDPId
    mapping(address => uint256) public count; // Owner => Amount of CDPs

    mapping(address => mapping(uint256 => mapping(address => uint256))) public cdpCan; // Owner => CDPId => Allowed Addr => True/False

    mapping(address => mapping(address => uint256)) public urnCan; // Urn => Allowed Addr => True/False

    struct List {
        uint256 prev;
        uint256 next;
    }

    event NewCdp(address indexed usr, address indexed own, uint256 indexed cdp);

    modifier cdpAllowed(uint256 cdp) {
        require(msg.sender == owns[cdp] || cdpCan[owns[cdp]][cdp][msg.sender] == 1, "cdp-not-allowed");
        _;
    }

    modifier urnAllowed(address urn) {
        require(msg.sender == urn || urnCan[urn][msg.sender] == 1, "urn-not-allowed");
        _;
    }

    constructor(address vat_) public {
        vat = vat_;
    }

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    function toInt(uint256 x) internal pure returns (int256 y) {
        y = int256(x);
        require(y >= 0);
    }

    // Allow/disallow a usr address to manage the cdp.
    function cdpAllow(uint256 cdp, address usr, uint256 ok) public cdpAllowed(cdp) {
        cdpCan[owns[cdp]][cdp][usr] = ok;
    }

    // Allow/disallow a usr address to quit to the the sender urn.
    function urnAllow(address usr, uint256 ok) public {
        urnCan[msg.sender][usr] = ok;
    }

    // Open a new cdp for a given usr address.
    function open(bytes32 ilk, address usr) public returns (uint256) {
        require(usr != address(0), "usr-address-0");

        cdpi = add(cdpi, 1);
        urns[cdpi] = address(new UrnHandler(vat));
        owns[cdpi] = usr;
        ilks[cdpi] = ilk;

        // Add new CDP to double linked list and pointers
        if (first[usr] == 0) {
            first[usr] = cdpi;
        }
        if (last[usr] != 0) {
            list[cdpi].prev = last[usr];
            list[last[usr]].next = cdpi;
        }
        last[usr] = cdpi;
        count[usr] = add(count[usr], 1);

        emit NewCdp(msg.sender, usr, cdpi);
        return cdpi;
    }

    // Give the cdp ownership to a dst address.
    function give(uint256 cdp, address dst) public cdpAllowed(cdp) {
        require(dst != address(0), "dst-address-0");
        require(dst != owns[cdp], "dst-already-owner");

        // Remove transferred CDP from double linked list of origin user and pointers
        if (list[cdp].prev != 0) {
            list[list[cdp].prev].next = list[cdp].next; // Set the next pointer of the prev cdp (if exists) to the next of the transferred one
        }
        if (list[cdp].next != 0) {
            // If wasn't the last one
            list[list[cdp].next].prev = list[cdp].prev; // Set the prev pointer of the next cdp to the prev of the transferred one
        } else {
            // If was the last one
            last[owns[cdp]] = list[cdp].prev; // Update last pointer of the owner
        }
        if (first[owns[cdp]] == cdp) {
            // If was the first one
            first[owns[cdp]] = list[cdp].next; // Update first pointer of the owner
        }
        count[owns[cdp]] = sub(count[owns[cdp]], 1);

        // Transfer ownership
        owns[cdp] = dst;

        // Add transferred CDP to double linked list of destiny user and pointers
        list[cdp].prev = last[dst];
        list[cdp].next = 0;
        if (last[dst] != 0) {
            list[last[dst]].next = cdp;
        }
        if (first[dst] == 0) {
            first[dst] = cdp;
        }
        last[dst] = cdp;
        count[dst] = add(count[dst], 1);
    }

    // Frob the cdp keeping the generated DAI or collateral freed in the cdp urn address.
    function frob(uint256 cdp, int256 dink, int256 dart) public cdpAllowed(cdp) {
        address urn = urns[cdp];
        VatLike(vat).frob(ilks[cdp], urn, urn, urn, dink, dart);
    }

    // Transfer wad amount of cdp collateral from the cdp address to a dst address.
    function flux(uint256 cdp, address dst, uint256 wad) public cdpAllowed(cdp) {
        VatLike(vat).flux(ilks[cdp], urns[cdp], dst, wad);
    }

    // Transfer wad amount of any type of collateral (ilk) from the cdp address to a dst address.
    // This function has the purpose to take away collateral from the system that doesn't correspond to the cdp but was sent there wrongly.
    function flux(bytes32 ilk, uint256 cdp, address dst, uint256 wad) public cdpAllowed(cdp) {
        VatLike(vat).flux(ilk, urns[cdp], dst, wad);
    }

    // Transfer wad amount of DAI from the cdp address to a dst address.
    function move(uint256 cdp, address dst, uint256 rad) public cdpAllowed(cdp) {
        VatLike(vat).move(urns[cdp], dst, rad);
    }

    // Quit the system, migrating the cdp (ink, art) to a different dst urn
    function quit(uint256 cdp, address dst) public cdpAllowed(cdp) urnAllowed(dst) {
        (uint256 ink, uint256 art) = VatLike(vat).urns(ilks[cdp], urns[cdp]);
        VatLike(vat).fork(ilks[cdp], urns[cdp], dst, toInt(ink), toInt(art));
    }

    // Import a position from src urn to the urn owned by cdp
    function enter(address src, uint256 cdp) public urnAllowed(src) cdpAllowed(cdp) {
        (uint256 ink, uint256 art) = VatLike(vat).urns(ilks[cdp], src);
        VatLike(vat).fork(ilks[cdp], src, urns[cdp], toInt(ink), toInt(art));
    }

    // Move a position from cdpSrc urn to the cdpDst urn
    function shift(uint256 cdpSrc, uint256 cdpDst) public cdpAllowed(cdpSrc) cdpAllowed(cdpDst) {
        require(ilks[cdpSrc] == ilks[cdpDst], "non-matching-cdps");
        (uint256 ink, uint256 art) = VatLike(vat).urns(ilks[cdpSrc], urns[cdpSrc]);
        VatLike(vat).fork(ilks[cdpSrc], urns[cdpSrc], urns[cdpDst], toInt(ink), toInt(art));
    }
}
