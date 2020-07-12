pragma solidity >=0.4.2;

import "./Pairing.sol";
import "./ECops.sol";
import "./ECopsG2.sol";


library LibDTBE {

    //generate a random number of modulo _module which is a prime number
    function rand(uint256 _module) internal view returns(uint256) {
      uint256 _seed = _module + 1;
      uint256 random = uint(keccak256(abi.encodePacked(block.difficulty, _seed)));
      return random%_module;
    }

    // Add two elliptic curve points (affine coordinates)
    function G1add(Pairing.G1Point p1, Pairing.G1Point p2)
    internal view returns (Pairing.G1Point){
        uint256 x;
        uint256 y;
        (x, y) = ECops.add(p1.X, p1.Y, p2.X, p2.Y);
        Pairing.G1Point memory r;
        r.X = x;
        r.Y = y;
        return r;
    }

    // the scalar multiply in G1; use library ECops
    function G1mul(Pairing.G1Point p, uint s) internal view returns (Pairing.G1Point){
      uint256 x;
      uint256 y;
      Pairing.G1Point memory r;
      (x, y) = ECops.multiplyScalar(p.X, p.Y, s);
      r.X = x;
      r.Y = y;
      return r;
    }


    function G2add(Pairing.G2Point p1, Pairing.G2Point p2)
    internal view returns (Pairing.G2Point){
      uint256 x0;
      uint256 x1;
      uint256 y0;
      uint256 y1;
      (x0, x1, y0, y1) = ECopsG2.ECTwistAdd(
        p1.X[0], p1.X[1], p1.Y[0], p1.Y[1],
        p2.X[0], p2.X[1], p2.Y[0], p2.Y[1]
      );
      Pairing.G2Point memory r;
      r.X[0] = x0;
      r.X[1] = x1;
      r.Y[0] = y0;
      r.Y[1] = y1;
      return r;
    }

    //the scalar multiply in G2; use library ECops2
    function G2mul(Pairing.G2Point p, uint s) internal view returns (Pairing.G2Point){
      uint256 x0;
      uint256 x1;
      uint256 y0;
      uint256 y1;
      (x0, x1, y0, y1) = ECopsG2.ECTwistMul(p.X[0], p.X[1], p.Y[0], p.Y[1], s);
      Pairing.G2Point memory r;
      r.X[0] = x0;
      r.X[1] = x1;
      r.Y[0] = y0;
      r.Y[1] = y1;
      return r;
    }


    uint256 constant p = 21888242871839275222246405745257275088696311157297823662689037894645226208583; //

    struct PGroup{
      uint256 _p; //prime order
      Pairing.G1Point G; //G1 generator
      Pairing.G2Point _G; //G2 generator
      string _ECG1; //EC1 operation's library
      string _ECG2; //EC2 operation's library
      string _pairing; // pairing check's library
    }

    struct SK{
      uint256 ui;
      uint256 vi;
    }

    struct SVK{
      Pairing.G2Point Ui;
      Pairing.G2Point Vi;
    }

    struct PK{
      PGroup P;// P group

      Pairing.G1Point H;
      Pairing.G2Point _H;

      Pairing.G1Point U;
      Pairing.G2Point _U;

      Pairing.G1Point V;
      Pairing.G2Point _V;

      Pairing.G1Point W;
      Pairing.G2Point _W;

      Pairing.G1Point Z;
      Pairing.G2Point _Z;
    }

    struct CLUE{
      Pairing.G1Point Ci1;
      Pairing.G1Point Ci2;
    }

    function KeyGen(/*uint k, */uint n) internal view returns(PK memory, SK[] memory, SVK[] memory){
      PK memory epk;
      SK[] memory esk = new SK[](n);
      SVK[] memory esvk = new SVK[](n);

      /*Here should be some codes for generate the prime number p
       according to the input parameter k which is security parameter*/
      
       epk.P._p = p;
       epk.P._ECG1 = "ECops.sol";
       epk.P._ECG2 = "ECopsG2.sol";
       epk.P._pairing = "Pairing.sol";
       epk.P.G = Pairing.P1();
       epk.P._G = Pairing.P2();




      //get the generator of G1 AND G2

      Pairing.G1Point memory g1 = Pairing.P1();
      Pairing.G2Point memory g2 = Pairing.P2();

      /*here we need to generate the random variables in the P group
      (a prime-order biliner group)*/
      uint256 h = rand(p);
      uint256 w = rand(p);
      uint256 z = rand(p);
      uint256[] memory ui = new uint256[](n);
      uint256[] memory vi = new uint256[](n);

      uint256 u = 0; //sum of ui
      uint256 v = 0; //sum of vi
      //calculate secret key
      uint i = 0;
      while(i < n){
        ui[i] = rand(p);
        vi[i] = rand(p);
        u = u + ui[i];
        v = v + vi[i];
        //initialize the sk
        esk[i].ui = ui[i];
        esk[i].vi = vi[i];

        i++;
      }

      //calculate the  H and _H
      Pairing.G1Point memory H = G1mul(g1, h);
      Pairing.G2Point memory _H = G2mul(g2, h);

      Pairing.G1Point memory U = G1mul(H, u);
      Pairing.G2Point memory _U = G2mul(_H, u);

      Pairing.G1Point memory V = G1mul(U, ECops.inverse(v));
      Pairing.G2Point memory _V = G2mul(_U, ECops.inverse(v));

      Pairing.G1Point memory W = G1mul(H, w);
      Pairing.G2Point memory _W = G2mul(_H, w);

      Pairing.G1Point memory Z = G1mul(V, z);
      Pairing.G2Point memory _Z = G2mul(_V, z);


      //initialize the SVK
      i = 0;
      while(i < n){
        esvk[i].Ui = G2mul(_H, ui[i]);
        esvk[i].Vi = G2mul(_V, vi[i]);
        i++;
      }

      epk.H = H;
      epk._H = _H;
      epk.U = U;
      epk._U = _U;
      epk.V = V;
      epk._V = _V;
      epk.W = W;
      epk._W = _W;
      epk.Z = Z;
      epk._Z = _Z;

      return (epk, esk, esvk);
    }

    // t is in group of modulo p; M is G^m , where m is in the group of modulo p
    function encrypt(PK epk, uint256 t, Pairing.G1Point M)
    internal view returns(Pairing.G1Point[] memory ){
      //random number in F_p ,where p is a prime number
      uint256 r1 = rand(p);
      uint256 r2 = rand(p);

      //calculate the Ci
      Pairing.G1Point memory C1 = G1mul(epk.H, r1);
      Pairing.G1Point memory C2 = G1mul(epk.V, r2);
      Pairing.G1Point memory C3 = G1add(M, G1mul(epk.U, r1 + r2));
      Pairing.G1Point memory tmp = G1mul(epk.U, t); // a temp point which is using for generating C4 C5
      Pairing.G1Point memory C4 = G1mul(G1add(tmp, epk.W), r1);
      Pairing.G1Point memory C5 = G1mul(G1add(tmp, epk.Z), r2);

      Pairing.G1Point[] memory Cdtbe = new Pairing.G1Point[](5);
      Cdtbe[0] = C1;
      Cdtbe[1] = C2;
      Cdtbe[2] = C3;
      Cdtbe[3] = C4;
      Cdtbe[4] = C5;
      return Cdtbe;
      //return '';
    }

    function pairingCheck(
      Pairing.G1Point[] p1,
      Pairing.G2Point[] p2)
    internal view returns (bool){
      return Pairing.pairing(p1, p2);   //e(a,b) == e(c,d) -> e(a,b)*e(-c,d) == 1
    }
   
    function isVaild(
      PK epk, uint256 t,
      Pairing.G1Point[] memory Cdtbe)
    internal view returns(bool) {
      Pairing.G1Point[] memory p11 = new Pairing.G1Point[](2);//
      Pairing.G2Point[] memory p12 = new Pairing.G2Point[](2);

      Pairing.G1Point[] memory p21 = new Pairing.G1Point[](2); //
      Pairing.G2Point[] memory p22 = new Pairing.G2Point[](2);

        p11[0] = Cdtbe[0]; //C1
        p11[1] = Pairing.negate(Cdtbe[3]); //-C4

        p12[0] = G2add(G2mul(epk._U, t), epk._W);
        p12[1] = epk._H;

        p21[0] = Cdtbe[1]; //C2
        p21[1] = Pairing.negate(Cdtbe[4]); //-C5

        p22[0] = G2add(G2mul(epk._U, t), epk._Z);
        p22[1] = epk._V;

        if((!pairingCheck(p11, p12)) || (!pairingCheck(p21, p22))){
          return false;
        }else{
          return true;
        }
    }

    function shareDec(
      PK epk,SK eski, uint256 t,
      Pairing.G1Point[] memory Cdtbe)
    internal view returns(CLUE){
      require(
        (!isVaild(epk, t, Cdtbe)),
        "ERROR!Forced to stop."
      );
      CLUE memory vi;// = new CLUE[](len);
      vi.Ci1 = G1mul(Cdtbe[0], eski.ui);
      vi.Ci2 = G1mul(Cdtbe[1], eski.vi);
      return vi;
    }

    function shareVerify(
      PK epk, SVK esvki, uint256 t,
      Pairing.G1Point[] memory Cdtbe,
      CLUE vi)
    internal view returns(bool){
      require(
        (!isVaild(epk, t, Cdtbe)),
        "ERROR!Forced to stop."
      );

      Pairing.G1Point[] memory p11 = new Pairing.G1Point[](2);//
      Pairing.G2Point[] memory p12 = new Pairing.G2Point[](2);

      Pairing.G1Point[] memory p21 = new Pairing.G1Point[](2); //
      Pairing.G2Point[] memory p22 = new Pairing.G2Point[](2);

      p11[0] = vi.Ci1; //Ci1
      p11[1] = Pairing.negate(Cdtbe[0]); //-C1

      p12[0] = epk._H;
      p12[1] = esvki.Ui;

      p21[0] = vi.Ci2; //Ci2
      p21[1] = Pairing.negate(Cdtbe[1]); //-C2

      p22[0] = epk._V;
      p22[1] = esvki.Vi;

      if((!pairingCheck(p11, p12)) || (!pairingCheck(p21, p22))){
        return false;
      }else{
        return true;
      }
    }

    function combine(
      PK epk, SVK[] memory esvk,
      CLUE[] memory v,
      Pairing.G1Point[] memory Cdtbe,
      uint256 t)
    internal view returns(Pairing.G1Point memory){
      require(
        (!isVaild(epk, t, Cdtbe)),
        "ERROR!Forced to stop."
      );
      uint len = esvk.length;
      uint i = 0;
      while(i < len){
        require(
          (!shareVerify(epk, esvk[i], t, Cdtbe, v[i])),
          "ERROR!Forced to stop."
        );
      }

      Pairing.G1Point memory tmp = G1add(v[0].Ci1, v[0].Ci2);
      i = 1;
      while(i < len){
        tmp = G1add(tmp, G1add(v[i].Ci1, v[i].Ci2));
        i++;
      }
      tmp = Pairing.negate(tmp);
      Pairing.G1Point memory M = G1add(tmp, Cdtbe[2]);
      return M;
    }

}
