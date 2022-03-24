// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestContract 
{
    uint public count;

    event Increment(uint value);
    event Decrement(uint value);

    constructor()
    {
        count = 0;
    }

    function getCount() view public returns(uint)
    {
        return count;
    }

    function increment() public
    {
        count = count + 1;
        emit Increment(count);
    }

    function decrement() public
    {
        count = count - 1;
        emit Decrement(count);
    }
}