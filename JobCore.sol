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
    // owner => uint256[]
    mapping(address => uint256[]) public ownerJobs;
    
    // address => Resume[]
    mapping(address => Resume[]) resumes;
    // resumeId => owner
    mapping(uint256 => address) public resumeOwner;
    // resumeId => resumeIndex
    mapping(uint256 => uint256) public resumeIndexs;
    // address => Resume
    mapping(address => Resume) public currentResume;
    
    // jobId => resumeIds[]
    mapping(uint256 => uint256[]) public appliedResumes;
    // address => jobIds[]
    mapping(address => uint256[]) public appliedJobs;

    /* 
    / === CONSTRUCTOR
    */
    constructor() {
        address[8] memory recruiterAddresses = [
                0x4Acf773BD581BdF5De5F9E6fc06589C3F6C791F9,
                0x4Acf773BD581BdF5De5F9E6fc06589C3F6C791F9,
                0x4Acf773BD581BdF5De5F9E6fc06589C3F6C791F9,
                0x4Acf773BD581BdF5De5F9E6fc06589C3F6C791F9,
                 0x4Acf773BD581BdF5De5F9E6fc06589C3F6C791F9,
                    0x4Acf773BD581BdF5De5F9E6fc06589C3F6C791F9,
                    0x4Acf773BD581BdF5De5F9E6fc06589C3F6C791F9,
                    0x4Acf773BD581BdF5De5F9E6fc06589C3F6C791F9
            ];
        string[8] memory names = ["Company 1", "Company 2", "Company 3", "Company 4", "Company 5", "Company 6", "Company 7", "Company 8"];
        string[8] memory headquarters = ["Headquarter 1", "Headquarter 2", "Headquarter 3", "Headquarter 4", "Headquarter 5", "Headquarter 6", "Headquarter 7", "Headquarter 8"];
        string[8] memory companySizes = ["1-10", "10-50", "1-10", "1-10", "10-50", "50-100", "1-10", "1-10"];
        string[8] memory websites = ["https://web1.com", "https://web2.com", "https://web3.com", "https://web4.com", "https://web5.com", "https://web6.com", "https://web7.com", "https://web8.com"];
        string[8] memory contacts = ["Contact 1", "Contact 2", "Contact 3", "Contact 4", "Contact 5", "Contact 6", "Contact 7", "Contact 8"];
        string[8] memory addresses = ["Address 1", "Address 2", "Address 3", "Address 4", "Address 5", "Address 6", "Address 7", "Address 8"];
        string[8] memory logos = [
                "https://res.cloudinary.com/munumber2/image/upload/v1634401209/NHATUYENDUNG1_vtcgeq.png",
                "https://res.cloudinary.com/munumber2/image/upload/v1634401208/NHATUYENDUNG2_j4mhca.png", 
                "https://res.cloudinary.com/munumber2/image/upload/v1634401209/NHATUYENDUNG3_utjokp.png", 
                "https://res.cloudinary.com/munumber2/image/upload/v1634401209/NHATUYENDUNG4_h1djot.png", 
                "https://res.cloudinary.com/munumber2/image/upload/v1634401209/NHATUYENDUNG5_w7xwkp.png", 
                "https://res.cloudinary.com/munumber2/image/upload/v1634401209/NHATUYENDUNG6_xvzgd8.png", 
                "https://res.cloudinary.com/munumber2/image/upload/v1634401209/NHATUYENDUNG7_ifgvt0.png", 
                "https://res.cloudinary.com/munumber2/image/upload/v1634401209/NHATUYENDUNG6_xvzgd8.png"
            ];
        
        
        for(uint8 i = 0; i < names.length; i++) {
            addRecruiter(recruiterAddresses[i], names[i], headquarters[i], companySizes[i], websites[i], contacts[i], addresses[i], logos[i]);
        }
    }
    
    /* 
    / MODIFIERS
    */
    modifier onlyRecuiter {
        require(recruiterToId[msg.sender] != 0, "RECRUITER: INVALID_RECRUITER_ADDRESS");
        _;
    }
    
    modifier isValidRecruiterId(uint256 _recruiter) {
         uint256 _latestRecruiterId = latestRecruiterId.current();
        require(_recruiter == 0 || _recruiter >= _latestRecruiterId, "RECRUITER: INVALID_ID");
        _;
    }
    
    modifier isValidJobId(uint256 _jobId) {
         uint256 _latestJobId = latestJobId.current();
        require(_jobId == 0 || _jobId >= _latestJobId, "JOB: INVALID_ID");
        _;
    }
    
    modifier isValidResumeId(uint256 _resume) {
         uint256 _latestResumeId = latestResumeId.current();
        require(_resume == 0 || _resume >= _latestResumeId, "RESUME: INVALID_ID");
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
        ownerJobs[msg.sender].push(_latestJobId);
        
        return _latestJobId;
    }
    
    function getLatestJobId() view public returns(uint256) {
        uint256 _latestJobId = latestJobId.current();
        return _latestJobId;
    }
    
    function getOwnerJobs() view public returns(uint256[] memory) {
        return ownerJobs[msg.sender];
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
    
    function updateCurrentResume(string memory _url) public {
        currentResume[msg.sender] = Resume({
            id: 0,
            url: _url
        });
    }
    
    function isAppliedJob(uint256 _jobId) view public returns(bool) {
        uint256[] memory _appliedJobs = appliedJobs[msg.sender];
        for(uint256 i = 0; i < _appliedJobs.length; i++) {
            if(_jobId == _appliedJobs[i]) {
                return true;
            }
        }
        return false;
    }
    
    function isResumeApplied(uint256 _jobId, uint256 _resumeId) view public returns(bool) {
        uint256[] memory _appliedResumes = appliedResumes[_jobId];
        for(uint256 i = 0; i < _appliedResumes.length; i++) {
            if(_resumeId == _appliedResumes[i]) {
                return true;
            }
        }
        return false;
    }
    
    
    function applyJob(uint256 _jobId, uint256 _resumeId) public isValidJobId(_jobId) isValidResumeId(_resumeId) {
        require(!isAppliedJob(_jobId), "JOB: APPLIED_JOB");
        require(!isResumeApplied(_jobId, _resumeId), "JOB: APPLIED_JOB");
        
        appliedResumes[_jobId].push(_resumeId);
        appliedJobs[msg.sender].push(_jobId);
    }
    
    function getOwnerResumes() view public returns(Resume[] memory) {
        return resumes[msg.sender];
    }
    
    function getAppliedResumeIds(uint256 _jobId) view public returns(uint256[] memory) {
         return appliedResumes[_jobId];
    }
    
    function getResumeById(uint256 _resumeId) view public isValidResumeId(_resumeId) returns(Resume memory) {
        address owner = resumeOwner[_resumeId];
        uint256 idx = resumeIndexs[_resumeId];
        return resumes[owner][idx];
    }
    
}
