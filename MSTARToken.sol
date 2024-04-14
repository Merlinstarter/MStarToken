// SPDX-License-Identifier: MIT

pragma solidity >=0.8.10 <0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
        return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
  }
}

contract MSTARToken is IERC20, Ownable {
    using SafeMath for uint256;

    string private _name = "MSTAR";
    string private _symbol = "MSTAR";
    uint8 private _decimals = 18;
    uint256 private constant _totalSupply = 1000000000 * 10**18;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    bool public bStart=false;
    uint256 public startTime=0;
    mapping (address => bool) public bWhiteArr;

    constructor () {
        address fundaddress = 0xE5F5264c6a75512fcc81Fbd519aF9Ff32206160B;
        _balances[fundaddress] = _totalSupply;
        emit Transfer(address(0), fundaddress, _totalSupply);
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
    function totalDestroy() public view returns (uint256) {
      return _balances[address(0)];
    }
    function balanceOf(address account) public view  override  returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public  override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view  override  returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public  override  returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public  override  returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function burn(uint256 _value) public returns (bool) {
        require(_value > 0, "Transfer amount must be greater than zero");
        _transfer(msg.sender, address(0), _value);
        return true;
    }
    function _transfer(address _from, address _to, uint256 _amount) internal {
        if(!bStart || block.timestamp<startTime){
            require(bWhiteArr[_from], "the market has not opened yet");
        }

        require(_from != address(0), "transfer from 0");
         _balances[_from] = _balances[_from].sub(_amount);
         _balances[_to] = _balances[_to].add(_amount);
         emit Transfer(_from, _to, _amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function addWhiteAddr(address account) external onlyOwner{
        bWhiteArr[account] = true;
    }
    function addWhiteAccount(address[] calldata  accountArr) external onlyOwner{
        for(uint256 i=0; i<accountArr.length; ++i) {
            bWhiteArr[accountArr[i]] = true;
        }
    }
    function removeWhiteAccount(address account) external onlyOwner{
        bWhiteArr[account] = false;
    }

    function setStart(bool bstart,uint256 tTimetamp) external onlyOwner{
        bStart = bstart;
        startTime = tTimetamp;
    }

}