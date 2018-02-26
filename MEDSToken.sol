pragma solidity ^0.4.18;

contract owned {
        address public owner;
        function owned() public {
                owner = msg.sender;
        }
        modifier onlyOwner() {
                require(msg.sender == owner);
                _;
        }    
        function transferOwnership(address newOwner) onlyOwner public {
            owner = newOwner;
        }
}

contract standartToken is owned {
        uint256 public totalSupply;
	string public name;
	string public symbol;
	uint public decimals;

        mapping (address => uint256) public balances;
        mapping (address => mapping (address => uint256)) public allowed;

        event Transfer(address indexed _from, address indexed _to, uint256 _value);
        event Approval(address indexed _owner, address indexed _spender, uint256 _value);

        function _transfer(address _from, address _to, uint _value) internal {
                require (_to != 0x0);
                require (balances[_from] >= _value);
                require (balances[_to] + _value > balances[_to]);
                uint previousBalances = balances[_from] + balances[_to];
                balances[_from] -= _value;
                balances[_to] += _value;
                Transfer(_from, _to, _value);
                assert(balances[_from] + balances[_to] == previousBalances);
        }

        function transfer(address _to, uint256 _value) public {
                _transfer(msg.sender, _to, _value);
        }
        function balanceOf(address _owner) public view returns (uint256 balance) {
                return balances[_owner];
        }
        function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
                require(_value <= allowed[_from][msg.sender]);
                allowed[_from][msg.sender] -= _value;
                _transfer(_from, _to, _value);
                return true;
        }
        function approve(address _spender, uint256 _value) public returns (bool success) {
                allowed[msg.sender][_spender] = _value;
                Approval(msg.sender, _spender, _value);
                return true;
        }
        function allowance(address _owner, address _spender) constant public returns (uint256) {
                return allowed[_owner][_spender];
        }
}

contract MEDSToken is owned, standartToken {	
        
        uint constant START = 1519862400;
        uint constant PERIOD = 61;
        uint constant END = START + PERIOD * 1 days;
        uint constant FROZEN_RESERVE_PERIOD = 180;
        uint constant FROZEN_TEAM_PERIOD = 360;

        uint256 public reserve;
        uint256 public team;
        
        modifier reservePeriodHasEnd() {
                require(now > END + FROZEN_RESERVE_PERIOD * 1 days);
                _;
        }
        modifier teamPeriodHasEnd() {
                require(now > END + FROZEN_TEAM_PERIOD * 1 days);
                _;
        }

        function MEDSToken() public {
        	decimals = 18;
                totalSupply = 1000000000 * 10 ** uint256(decimals);
        	name = "MEDSToken";
	        symbol = "MEDS";
                
                reserve = totalSupply * 15 / 100;
                team = totalSupply * 9 / 100;
                balances[msg.sender] = totalSupply - reserve - team;
        }
	
	function getTeamsTokens() onlyOwner teamPeriodHasEnd public returns (bool) {
		balances[msg.sender] += team;
		team = 0;
		return true;
	}

	function getReservedTokens() onlyOwner reservePeriodHasEnd public returns (bool) {
		balances[msg.sender] += reserve;
		reserve = 0;
		return true;
	}
}
