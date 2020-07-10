// You will build a Sharded Hash Table (SHT).
//
// The SHT should consist of a number of nodes storing key-value pairs.
// There are no external clients; the nodes perform Get()'s and Put()'s on the keys directly.
// A node can only perform a Get or Put on a key it owns.
// Each key is owned by exactly one node.
// A node can transfer ownership of a set of keys (a.k.a. shard) to another node by sending it a TransferMessage that is delivered asynchronously (i.e. as part of a different state transition)
// 
// The entire application should behave like a logically centralized hash table.

module Base {
  function ZeroMap() : imap<int,int>
  {
    imap i | true :: 0
  }

  function EmptyMap() : imap<int,int>
  {
    imap i | false :: 0
  }

  function MapUnionPreferLeft<K(!new),V>(a:map<K,V>, b:map<K,V>) : map<K,V>
  {
    map key | key in a.Keys + b.Keys :: if key in a then a[key] else b[key]
  }

  function IMapUnionPreferLeft(a:imap<int,int>, b:imap<int,int>) : imap<int,int>
  {
    imap key | key in a || key in b :: if key in a then a[key] else b[key]
  }

  function {:opaque} MapRemoveOne<K,V>(m:map<K,V>, key:K) : (m':map<K,V>)
    ensures forall k :: k in m && k != key ==> k in m'
    ensures forall k :: k in m' ==> k in m && k != key
    ensures forall j :: j in m' ==> m'[j] == m[j]
    ensures |m'.Keys| <= |m.Keys|
    ensures |m'| <= |m|
  {
    var m':= map j | j in m && j != key :: m[j];
    assert m'.Keys == m.Keys - {key};
    m'
  }

  function MapRemove(table:imap<int,int>, removeKeys:iset<int>) : imap<int,int>
    requires removeKeys <= table.Keys
  {
    imap key | key in table && key !in removeKeys :: table[key]
  }

}
