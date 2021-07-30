pragma solidity ^0.5.17;

contract trabalho {
    struct Candidate {
        uint candidateNusp;
        string name;
        uint votes;
    }
    
    struct Vote {
        uint voter;
        uint candidate;
        uint timestamp;
    }
    
    bool started = false;
    bool finished = false;
    
    Vote[] votes;
    Candidate[] candidates;
    Candidate[] public result;
    uint[] voters;

    string private invalidNuspMessage = "Esse número usp nâo é valido.";
    string private noCandidateMessage = "Nusp de candidato não existe.";
    string private voteDuplicateMessage = "Não é possível votar duas vezes com o mesmo nusp.";
    string private votingAlreadyStartedMessage = "Essa ação só pode ser feita antes do início da votação.";
    string private votingNotStartedMessage = "Essa ação só pode ser feita depois do início da votação.";
    string private votingAlreadyFinishedMessage = "Essa ação só pode ser feita antes do fim da votação.";
    string private votingNotFinishedMessage = "Essa ação só pode ser feita depois do fim da votação.";
    
    function addCandidate(uint nusp, string memory name) public votingNotStarted() isNuspValid(nusp) {
        Candidate memory c = Candidate(nusp, name, 0);
        candidates.push(c);
    }
    
    function startVoting() public votingNotStarted() {
        Candidate memory c = Candidate(0, "Brancos/Nulos", 0);
        candidates.push(c);
        started = true;
    }

    function vote(uint candidateNusp, uint voterNusp) public votingStarted() hasVoted(voterNusp) {
        bool foundCandidate = false;
        for (uint i=0; i < candidates.length; i++) {
            if (candidateNusp == candidates[i].candidateNusp) {
                candidates[i].votes += 1;
                Vote memory v = Vote(voterNusp, candidateNusp, now);
                votes.push(v);
                foundCandidate = true;
            }
        }
        
        require(foundCandidate, noCandidateMessage);
    }
    
    function finishVoting() public votingStarted() {
        finished = true;
        sortCandidates();
        result = candidates;
    }
    
    function sortCandidates() private {
        for (uint i=0; i<candidates.length; i++) {
            for (uint j=i; j<candidates.length; j++) {
                if (candidates[i].votes < candidates[j].votes) {
                    Candidate memory temp = candidates[i];
                    candidates[i] = candidates[j];
                    candidates[j] = temp;
                }
            }
        }
    }
    
    modifier votingFinished() {
        require(started, votingNotStartedMessage);
        require(finished, votingNotFinishedMessage);
        _;
    }
    
    modifier votingStarted() {
        require(started, votingNotStartedMessage);
        require(!finished, votingAlreadyFinishedMessage);
        _;
    }
    
    modifier votingNotStarted() {
        require(!started, votingAlreadyStartedMessage);
        require(!finished, votingAlreadyFinishedMessage);
        _;
    }
    
    modifier isNuspValid(uint nusp) {
        require(nusp > 0, invalidNuspMessage);
        _;
    }
    
    modifier hasVoted(uint voterNusp) {
        bool voted = false;
        for (uint i=0; i < voters.length; i++) { 
            if (voterNusp == voters[i]){
                voted = true;
            }
        }
        
        if (!voted) {
           voters.push(voterNusp); 
        }
        
        require(!voted, voteDuplicateMessage);
        _;
    }
}
