// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 < 0.9.0;
pragma experimental ABIEncoderV2;
import '../SafeMath/safeMath.sol';

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);

}

//Implementación de las funciones del token ERC20
contract CarnegieTSC is IERC20 {

    string public constant name = "Carnegie Token";
    string public constant symbol = "CRG";
    uint8 public constant decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens);


    using SafeMath for uint256;

    mapping (address => uint) balances;
    uint256 totalSupply_;

    constructor (uint256 initialSupply) {
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
    }


    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    function increaseTotalSupply(uint newTokensAmount) public {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    function transfer(address recipient, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender], "No cuentas con esa cantidad de tokens.");
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit Transfer(msg.sender, recipient, numTokens);
        return true;
    }

    function transferToCarnegie(address _sender, address receiver, uint256 numTokens) public returns (bool) {
        require(numTokens <= balances[_sender]);
        balances[_sender] = balances[_sender].sub(numTokens);
        balances[receiver] = balances[receiver].add(numTokens);
        emit Transfer(_sender, receiver, numTokens);
        return true;
    }
}