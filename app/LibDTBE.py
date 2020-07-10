from bplib.bp import BpGroup
from petlib.bn import Bn
import random


class PGroup:
    def __init__(self, _G, _p):
        self.G = _G #_G includes all the ecc ops, like G1/G2 add, pairing and stuff like that
        self.p = _p # order of Group


class PK:
    def __init__(self, _P, H1, H2, U1, U2, V1, V2, W1, W2, Z1, Z2):
        self.P = _P # P gorup
        self.H = H1
        self._H = H2
        self.U = U1
        self._U = U2
        self.V = V1
        self._V = V2
        self.W = W1
        self._W = W2
        self.Z = Z1
        self._Z = Z2


class SK:
    def __init__(self, _ui, _vi):
        self.ui = _ui
        self.vi = _vi


class SVK:
    def __init__(self, _Ui, _Vi):
        self.Ui = _Ui
        self.Vi = _Vi


class CLUE:
    def __init__(self, _Ci1, _Ci2):
        self.Ci1 = _Ci1
        self.Ci2 = _Ci2


def ModReverse(a,p): # a, p is <class 'petlib.bn.Bn'>
    return a.mod_inverse(m = p)


def ModAdd(a,b,p): # a, b, p is <class 'petlib.bn.Bn'>
    return a.mod_add(b, p)


def random_Zp(p): # the generated random number is <class 'petlib.bn.Bn'>
    if(type(p) is int):
        print("error")
        return
    r = random.randint(0,int(p))%0xffffffff
    return p - Bn(r)


def pairingCheck(epk, p1, p2): # return pair(p1[0],p2[0]) == pair(p1[1],p2[1])
    G = epk.P.G
    if(G.pair(p1[0], p2[0]) == G.pair(p1[1], p2[1])):
        return True
    else:
        return False


def KeyGen(n): # security parameter k equals to n in our case 
    #epk = PK(BpGroup()) # generate epk
    #main params
    G = BpGroup()
    P = PGroup(G, G.order())  # G.order() is <class 'petlib.bn.Bn'>

    esk = []
    esvk = []
    g1 = G.gen1()
    g2 = G.gen2()

    h = random_Zp(P.p)
    w = random_Zp(P.p)
    z = random_Zp(P.p)

    ui = []
    vi = []

    u = Bn(0)
    v = Bn(0)

    i = 0
    while(i < n):
        ui.append(random_Zp(P.p))
        vi.append(random_Zp(P.p))
        u = u + ui[i]
        v = v + vi[i]

        esk.append(SK(ui[i], vi[i]))
        i = i + 1

    H = g1.mul(h)
    _H = g2.mul(h)

    U = H.mul(u)
    _U = _H.mul(u)

    _v = ModReverse(v,P.p)
    V = U.mul(_v)
    _V = _U.mul(_v)

    W = H.mul(w)
    _W = _H.mul(w)

    Z = V.mul(z)
    _Z = _V.mul(z)


    i = 0
    while(i<n):
        esvk.append(SVK(_H.mul(ui[i]), _V.mul(vi[i])))
        i = i + 1

    epk = PK(P, H, _H, U, _U, V, _V, W, _W, Z, _Z)

    return epk, esk, esvk


#epk is a public key, t is a integer, M is a point on G1 curve
def Encrypt(epk, t, M):
    t = Bn(t)
    r1 = random_Zp(epk.P.p)
    r2 = random_Zp(epk.P.p)

    # calulate Ci
    C1 = (epk.H).mul(r1)
    C2 = (epk.V).mul(r2)
    C3 = M.add((epk.U).mul(r1+r2)) # 
    tmp = (epk.U).mul(t) #a temp point which is using for generating C4 C5
    C4 = (tmp.add(epk.W)).mul(r1)
    C5 = (tmp.add(epk.Z)).mul(r2)

    Cdtbe = []
    Cdtbe.append(C1)
    Cdtbe.append(C2)
    Cdtbe.append(C3)
    Cdtbe.append(C4)
    Cdtbe.append(C5)

    return Cdtbe


def isValid(epk, t, Cdtbe):
    t = Bn(t)
    p11 = []
    p12 = []
    p21 = []
    p22 = []

    p11.append(Cdtbe[0]) # C1
    p11.append(Cdtbe[3]) # C4

    p12.append(((epk._U).mul(t)).add(epk._W))
    p12.append(epk._H)

    p21.append(Cdtbe[1]) # C2
    p21.append(Cdtbe[4]) # C5

    p22.append(((epk._U).mul(t)).add(epk._Z))
    p22.append(epk._V)

    if(pairingCheck(epk, p11, p12) and pairingCheck(epk, p21, p22)):
        return True
    else:
        return False


def shareDec(epk, eski, t, Cdtbe):
    if(not isValid(epk, t, Cdtbe)):
        raise Exception("Error! Forced to stop")  # Should be refined according to the practical situation

    Ci1 = Cdtbe[0].mul(eski.ui)
    Ci2 = Cdtbe[1].mul(eski.vi)
    vi = CLUE(Ci1, Ci2)
    return vi


def shareVerify(epk, esvki, t, vi, Cdtbe):
    if(not isValid(epk, t, Cdtbe)):
        return "Error! Forced to stop"  # Should be refined according to the practical situation

    p11 = []
    p12 = []
    p21 = []
    p22 = []

    p11.append(vi.Ci1) # Ci1
    p11.append(Cdtbe[0]) # C1

    p12.append(epk._H)
    p12.append(esvki.Ui)

    p21.append(vi.Ci2) # Ci2
    p21.append(Cdtbe[1]) # C2

    p22.append(epk._V)
    p22.append(esvki.Vi)

    if(pairingCheck(epk, p11,p12) and pairingCheck(epk, p21, p22)):
        return True
    else:
        return False


def Combine(epk, esvk, t, v, Cdtbe):
    if(not isValid(epk, t, Cdtbe)):
        return "Error! Forced to stop"  # Should be refined according to the practical situation

    len_e = len(v)
    i = 0
    while(i<len_e):
        if(not shareVerify(epk, esvk[i], t, v[i], Cdtbe)):
            return "Error! Forced to stop"  # Should be refined according to the practical situation
        i=i+1

    tmp = (v[0].Ci1).add(v[0].Ci2)
    i = 1
    while(i<len_e):
        temp = (v[i].Ci1).add(v[i].Ci2)
        tmp = tmp.add(temp)
        i = i + 1
    tmp2 = tmp.neg()
    M = Cdtbe[2].add(tmp2)
    return M
