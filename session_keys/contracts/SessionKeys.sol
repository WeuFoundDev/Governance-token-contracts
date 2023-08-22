// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract FoundationCommitteeV1 is Ownable, Pausable {
    enum CommitteeType { Technical, Research }

    struct CommitteeMember {
        uint256 rotationEnd; // End of the current rotation period
    }

    uint256 public sessionDuration = 7 days;
    uint256 public sessionCount = 5;
    uint256 public technicalRotationPeriod = 25; // Updated rotation period for technical committee
    uint256 public researchRotationPeriod = 25; // Updated rotation period for research committee

    mapping(CommitteeType => CommitteeMember[]) public committees;
    mapping(address => bool) public sessionKeys;
    mapping(address => uint256) public sessionExpiry;
    mapping(address => CommitteeType) public memberCommitteeType;
    mapping(address => mapping(uint256 => bool)) public multiSignAggreApprovals;

    event SessionKeyAdded(address indexed sessionKey);
    event CommitteeMemberRotated(CommitteeType committeeType, address indexed oldMember, address indexed newMember);
    event ChangeProposed(address indexed proposer, string proposalDetails);
    event SessionEnded(address indexed sessionKey);

    constructor() {
        sessionKeys[msg.sender] = true;
        memberCommitteeType[msg.sender] = CommitteeType.Technical;
    }

    modifier onlySessionKey() {
        require(sessionKeys[msg.sender], "You are not a valid session key");
        require(sessionExpiry[msg.sender] >= block.timestamp, "Session key has expired");
        _;
    }

    modifier onlyOwnerOrAdmin() {
        require(owner() == msg.sender || sessionKeys[msg.sender], "Not authorized");
        _;
    }

    function addSessionKey(address _sessionKey, CommitteeType _committeeType) external onlyOwnerOrAdmin {
        require(_sessionKey != address(0), "Invalid session key address");
        sessionKeys[_sessionKey] = true;
        sessionExpiry[_sessionKey] = block.timestamp + sessionDuration;
        memberCommitteeType[_sessionKey] = _committeeType;
        emit SessionKeyAdded(_sessionKey);
    }

    function rotateCommittee(CommitteeType _committeeType, address _newMember) external onlySessionKey {
        require(_newMember != address(0), "Invalid new member address");
        uint256 rotationEnd = block.timestamp + (sessionCount * sessionDuration);

        committees[_committeeType].push(CommitteeMember({
            rotationEnd: rotationEnd
        }));
        emit CommitteeMemberRotated(_committeeType, msg.sender, _newMember);
    }

    function addTechnicalCommitteeMember(address _memberAddress) external onlySessionKey {
        require(_memberAddress != address(0), "Invalid member address");
        require(getTechnicalCommitteeMembersCount() < 3, "Maximum technical members reached");

        committees[CommitteeType.Technical].push(CommitteeMember({
            rotationEnd: block.timestamp + (technicalRotationPeriod * sessionDuration)
        }));
        memberCommitteeType[_memberAddress] = CommitteeType.Technical;
        emit CommitteeMemberRotated(CommitteeType.Technical, address(0), _memberAddress);
    }

    function addResearchCommitteeMember(address _memberAddress) external onlySessionKey {
        require(_memberAddress != address(0), "Invalid member address");
        require(getResearchCommitteeMembersCount() < 1, "Maximum research members reached");

        committees[CommitteeType.Research].push(CommitteeMember({
            rotationEnd: block.timestamp + (researchRotationPeriod * sessionDuration)
        }));
        memberCommitteeType[_memberAddress] = CommitteeType.Research;
        emit CommitteeMemberRotated(CommitteeType.Research, address(0), _memberAddress);
    }

    function getTechnicalCommitteeMembersCount() public view returns (uint256) {
        return committees[CommitteeType.Technical].length;
    }

    function getResearchCommitteeMembersCount() public view returns (uint256) {
        return committees[CommitteeType.Research].length;
    }

    function proposeChange(string memory _proposalDetails) external onlySessionKey {
        require(memberCommitteeType[msg.sender] == CommitteeType.Technical, "Only technical committee members can propose changes");
        require(getTechnicalCommitteeMembersCount() > 1, "At least 2 technical committee members required");
        emit ChangeProposed(msg.sender, _proposalDetails);
    }

    function setDuration(uint256 _duration) external onlyOwnerOrAdmin {
        sessionDuration = _duration;
    }

    function setCount(uint256 _count) external onlyOwnerOrAdmin {
        sessionCount = _count;
    }

    function setTechnicalRotationPeriod(uint256 _rotationPeriod) external onlyOwnerOrAdmin {
        technicalRotationPeriod = _rotationPeriod;
    }

    function setResearchRotationPeriod(uint256 _rotationPeriod) external onlyOwnerOrAdmin {
        researchRotationPeriod = _rotationPeriod;
    }

    function approveMultiSignAggre(uint256 _approvalIndex) external onlySessionKey {
        multiSignAggreApprovals[msg.sender][_approvalIndex] = true;
    }

    function endSession(address _sessionKey) external onlyOwnerOrAdmin {
        require(sessionKeys[_sessionKey], "Invalid session key address");
        sessionExpiry[_sessionKey] = 0;
        emit SessionEnded(_sessionKey);
    }

   
}
