// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

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
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

contract JobCore is Ownable {
    /** 
    * === CONFIG
    */
    using Counters for Counters.Counter;
    
    /** 
    * === STRUCT & CONSTANT
    */
    enum OBEJCTS {
        RECRUITER,
        CANDIDATE,
        JOB
    }
    
    uint256 DEFAULT_EXPIRED_TIME = 15 days;
    
    struct Recruiter {
        uint256 id;
        string name;
        string headquarter;
        string companySize;
        string website;
        string contact;
        string addr;
        string logo;
    }
    
    struct Job {
        uint256 id;
        string title;
        uint256 salaryMin;
        uint256 salaryMax;
        string desc;
        uint256 expiredIn; 
    }
    
    struct Resume {
        uint256 id;
        string url;
    }
 
    /** 
    * === VARIABLES
    */
    Counters.Counter latestRecruiterId;
    Counters.Counter latestJobId;
    Counters.Counter latestResumeId;
    
    // owner => recruiterId
    mapping(address => uint256) public recruiterToId;
    // recruiterId => Recruiter
    mapping(uint256 => Recruiter) public recruiters;
    
    // owner => jobId
    Job[] public jobs;
    // jobId => owner
    mapping(uint256 => address) public jobOwner;
    
    // address => Resume[]
    mapping(address => Resume[]) resumes;
    // resumeId => owner
    mapping(uint256 => address) public resumeOwner;
    // resumeId => resumeIndex
    mapping(uint256 => uint256) public resumeIndexs;
    
    // jobId => resumeIds[]
    mapping(uint256 => uint256[]) appliedResumes;
    // address => jobIds[]
    mapping(address => uint256[]) appliedJobs;

    /* 
    / === CONSTRUCTOR
    */
    constructor() {
        
    }
    
    /* 
    / MODIFIERS
    */
    modifier onlyRecuiter {
        require(recruiterToId[msg.sender] != 0, "INVALID_RECRUITER");
        _;
    }
    
    /* 
    / === FUNCTIONS
    */
    function addRecruiter(
        address _recruiter,
        string memory _name, 
        string memory _headquarter, 
        string memory _companySize, 
        string memory _website, 
        string memory _contact, 
        string memory _addr, 
        string memory _logo
    ) public onlyOwner returns(uint256) {
        latestRecruiterId.increment();
        uint256 _latestRecruiterId = latestRecruiterId.current();
        
        recruiterToId[_recruiter] = _latestRecruiterId;
    
        recruiters[_latestRecruiterId] = Recruiter({
            id: _latestRecruiterId,
            name: _name,
            headquarter: _headquarter,
            companySize: _companySize,
            website: _website,
            contact: _contact,
            addr: _addr,
            logo: _logo
        });
        
        return _latestRecruiterId;
    }
    
    function getLatestRecruiterId() view public returns(uint256) {
        uint256 _latestRecruiterId = latestRecruiterId.current();
        return _latestRecruiterId;
    }
    
    function addJob(string memory _title, uint256 _salaryMin, uint256 _salaryMax, string memory _desc) public onlyRecuiter returns(uint256) {
        latestJobId.increment();
        uint256 _latestJobId = latestJobId.current();
        
        jobs.push(Job({
           id: _latestJobId,
           title: _title,
           salaryMin: _salaryMin,
           salaryMax: _salaryMax,
           desc: _desc,
           expiredIn: block.timestamp + DEFAULT_EXPIRED_TIME
        }));
        
        jobOwner[_latestJobId] = msg.sender;
        
        return _latestJobId;
    }
    
    function getLatestJobId() view public returns(uint256) {
        uint256 _latestJobId = latestJobId.current();
        return _latestJobId;
    }
    
    // function getJobs() public returns(Job[] memory) {
    //     Job[] memory _job;
    //     uint256 _latestRecruiterId = latestRecruiterId.current();
    //     uint256 _latestJobId = latestJobId.current();
    //     for(uint i = 1; i <= _latestRecruiterId; i++) {
    //         for(uint j = 0; i < jobs[])
    //     }
    // }
    
    function addResume(string memory _url) public returns(uint256) {
        latestResumeId.increment();
        uint256 _latestResumeId = latestResumeId.current();
        
        resumeIndexs[_latestResumeId] = resumes[msg.sender].length;
        
        resumes[msg.sender].push(Resume({
            id: _latestResumeId,
            url: _url
        }));
        
        resumeOwner[_latestResumeId] = msg.sender;
        
        return _latestResumeId;
    } 
    
    function getOwnerResumes() view public returns(Resume[] memory) {
        return resumes[msg.sender];
    }
    
    function getAppliedResumes() view public returns(Resume[] memory) {
        
    }
}
