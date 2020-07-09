import random
from ZeroKnowledge import bbs

class CommitmentScheme(object):
    def __init__(self, oneWayPermutation, hardcorePredicate, securityParameter):
        '''
            oneWayPermutation: int -> int
            hardcorePredicate: int -> {0, 1}
        '''
        self.oneWayPermutation = oneWayPermutation
        self.hardcorePredicate = hardcorePredicate
        self.securityParameter = securityParameter

        # a random string of length `self.securityParameter` used only once per commitment
        self.secret = self.generateSecret()

    def generateSecret(self):
        raise NotImplemented

    def commit(self, x):
        raise NotImplemented

    def reveal(self):
        return self.secret

class BBSBitCommitmentScheme(CommitmentScheme):
    def generateSecret(self):
        # the secret is a random quadratic residue
        self.secret = self.oneWayPermutation(random.getrandbits(self.securityParameter))
        return self.secret

    def commit(self, bit):
        unguessableBit = self.hardcorePredicate(self.secret)
        return (
            self.oneWayPermutation(self.secret),
            unguessableBit ^ bit,  # python xor
        )

class BBSBitCommitmentVerifier(object):
    def __init__(self, oneWayPermutation, hardcorePredicate):
        self.oneWayPermutation = oneWayPermutation
        self.hardcorePredicate = hardcorePredicate

    def verify(self, securityString, claimedCommitment):
        trueBit = self.decode(securityString, claimedCommitment)
        unguessableBit = self.hardcorePredicate(securityString)  # wasteful, whatever
        return claimedCommitment == (
            self.oneWayPermutation(securityString),
            unguessableBit ^ trueBit,  # python xor
        )

    def decode(self, securityString, claimedCommitment):
        unguessableBit = self.hardcorePredicate(securityString)
        return claimedCommitment[1] ^ unguessableBit

class BBSStringCommitmentScheme(CommitmentScheme):
    def __init__(self, numBits, oneWayPermutation, hardcorePredicate, securityParameter=512):
        '''
            A commitment scheme for integers of a prespecified length `numBits`. Applies the
            bit commitment scheme to each bit independently.
        '''
        self.schemes = [BBSBitCommitmentScheme(oneWayPermutation, hardcorePredicate, securityParameter)
                        for _ in range(numBits)]
        super().__init__(oneWayPermutation, hardcorePredicate, securityParameter)

    def generateSecret(self):
        self.secret = [x.secret for x in self.schemes]
        return self.secret

    def setSecret(self, sec):
        self.secret = sec
        return sec

    def commit(self, integer):
        binaryString = ''.join((format(ord(x), 'b').zfill(8)) for x in str(integer))
        bits = [int(char) for char in binaryString]
        return [scheme.commit(bit) for scheme, bit in zip(self.schemes, bits)]

class BBSStringCommitmentVerifier(object):
    def __init__(self, numBits, oneWayPermutation, hardcorePredicate):
        self.verifiers = [BBSBitCommitmentVerifier(oneWayPermutation, hardcorePredicate)
                          for _ in range(numBits)]

    def decodeBits(self, secrets, bitCommitments):
        return [v.decode(secret, commitment) for (v, secret, commitment) in
                zip(self.verifiers, secrets, bitCommitments)]

    def verify(self, secrets, bitCommitments):
        return all(
            bitVerifier.verify(secret, commitment)
            for (bitVerifier, secret, commitment) in
            zip(self.verifiers, secrets, bitCommitments)
        )

    def decode(self, secrets, bitCommitments):
        decodedBits = self.decodeBits(secrets, bitCommitments)
        binary = ''.join(str(bit) for bit in decodedBits)
        n = 8;
        binarySets = [binary[i:i+n] for i in range(0, len(binary), n)]
        chars  = [chr(int(charBin, 2)) for charBin in binarySets]
        return ''.join(chars)

class Zk():

    def __init__(self):
        securityParameter = 10
        oneWayPerm = bbs.bbs(securityParameter)
        hardcorePred = bbs.parity
        self.scheme = BBSStringCommitmentScheme(512, oneWayPerm, hardcorePred)
        self.verifier = BBSStringCommitmentVerifier(512, oneWayPerm, hardcorePred)

    def changeSecret(self, sec = []):
        if len(sec) == 0:
            self.scheme.generateSecret()
        else:
            self.scheme.setSecret(sec)
        return self.scheme.reveal()

    def getSecret(self):
        return self.scheme.reveal()

    def solve(self, sec = [], comm = []):
        decoded = self.verifier.decode(sec, comm)
        return decoded

    def create(self, data = ""):
        data = str(data)
        commitments = self.scheme.commit(data)
        return commitments
