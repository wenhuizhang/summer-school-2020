datatype MapState = MapState(m:map<int, string>)

predicate MapInsert(s:MapState, s':MapState, k:int, v:string) {
  s'.m == s.m[k := v]
}

predicate MapNext(s:MapState, s':MapState) {
  exists k, v :: MapInsert(s, s', k, v)
}


datatype Slot = Empty | Used(k:int, v:string)
datatype HashTblState = HashTblState(tbl:seq<Slot>)

datatype OptionIndex = None | Some(idx:nat)
function Probe(tbl:seq<Slot>, k: int) : (oi:OptionIndex)
  ensures oi.Some? ==> 0 <= oi.idx < |tbl| && tbl[oi.idx].Empty?
{
  // Should provide a recursive defn of linear probing starting at
  // a hashed target index, but ... I'm tired and these slides are
  // late ... so you get the lousiest hash function ever.
  if |tbl|>0 && tbl[0].Empty? then Some(0) else None
}

predicate HTInsert(s:HashTblState, s':HashTblState, k:int, v:string) {
  var oi := Probe(s.tbl, k);
  && oi.Some?
  && s'.tbl == s.tbl[oi.idx := Used(k, v)]
}

predicate HTNext(s:HashTblState, s':HashTblState) {
  exists k, v :: HTInsert(s, s', k, v)
}

function InterpRecurse(tbl:seq<Slot>) : (m:map<int, string>)
  ensures m.Keys == set i | 0<=i<|tbl| && tbl[i].Used? :: tbl[i].k
  ensures forall k | k in m ::
    (exists i :: 0<=i<|tbl| && tbl[i].Used? && m[tbl[i].k]==tbl[i].v)
{
  if |tbl| == 0
  then map[]
  else
    var prefix := InterpRecurse(tbl[..|tbl|-1]);
    var last := tbl[|tbl|-1];
    match last
      case Empty => prefix
      case Used(k, v) => prefix[k := v]
}

function Interp(ls:HashTblState) : (hs:MapState)
  ensures hs.m.Keys == set i | 0<=i<|ls.tbl| && ls.tbl[i].Used? :: ls.tbl[i].k
  ensures forall k | k in hs.m ::
    (exists i ::
      && 0<=i<|ls.tbl|
      && ls.tbl[i].Used?
      && hs.m[ls.tbl[i].k]==ls.tbl[i].v)
{
  MapState(InterpRecurse(ls.tbl))
}

// Here's a lemma I should prove after I define Inits; without Inits
// we don't have state-machine-defined behaviors!
//lemma RefinementInit(ls:HashTblState, hs:MapState)
//  requires HTInit(ls)
//  requires MapInit(hs)
//  ensures Interp(ls) == hs
//{
//}

lemma RefinementInductive(ls:HashTblState, ls':HashTblState, hs:MapState, hs':MapState)
  requires HTNext(ls, ls')
  requires MapNext(hs, hs')
  // NB you might also require HTInv(ls)
  // (from which you could derive HTInv(ls') using your InvInduction lemma)
  // so that interpretation only has to work for the Inv states, not every
  // state. Next might be nonsensical for non-Inv states.
  requires Interp(ls) == hs
  ensures Interp(ls') == hs'
{
  // Sorry, haven't got time to stitch this proof together right now.
  // Email Jon if you're curious and I'll fill it in. :v)
  assume false;
}
