datatype Card = Shelf | Patron(name: string)
datatype Book = Book(title: string)
type Library = map<Book, Card>

predicate Init(s: Library) {
  forall book | book in s :: s[book] == Shelf
}

predicate CheckOut(s:Library, s':Library, book:Book, patron:string) {
  && book in s
  && s[book] == Shelf
  && (forall book | book in s :: s[book] != Patron(patron))
  && s' == s[book := Patron(patron)]
}

predicate CheckIn(s:Library, s':Library, book:Book, patron:string) {
  && book in s
  && s[book] == Patron(patron)
  && s' == s[book := Shelf]
}

predicate Next(s:Library, s':Library) {
  || (exists book, patron :: CheckOut(s, s', book, patron))
  || (exists book, patron :: CheckIn(s, s', book, patron))
}



// name has at most book checked out.
//
// If you're coming from TLA+ background, you might have written
// this using set cardinality:
//   |BooksOutstanding(s, name)| <= 1
// For a solution like that, see demo00_alternate.dfy.
predicate CheckedOutTo(s:Library, book:Book, name: string) {
  && book in s
  && s[book] == Patron(name)
}

predicate HasAtMostOneBook(s: Library, name: string) {
  forall book1, book2 ::
    ( CheckedOutTo(s, book1, name) && CheckedOutTo(s, book2, name)
      ==> book1 == book2 )
}

predicate Safety(s:Library) {
  forall name :: HasAtMostOneBook(s, name)
}

predicate Inv(s: Library) {
  Safety(s)
}

lemma SafetyProof()
  ensures forall s :: Init(s) ==> Inv(s)
  ensures forall s, s' :: Inv(s) && Next(s, s') ==> Inv(s')
  ensures forall s :: Inv(s) ==> Safety(s)
{
  forall s, s' | Inv(s) && Next(s, s') ensures Inv(s') {
    InductiveStep(s, s');
  }
}


lemma InductiveStep(s: Library, s': Library)
  requires Inv(s)
  requires Next(s, s')
  ensures Inv(s')
{
  forall name ensures HasAtMostOneBook(s', name) {
    assert HasAtMostOneBook(s, name);
    if book, patron :| CheckOut(s, s', book, patron) {
//      if patron == name {
//        assert HasAtMostOneBook(s', name);
//      } else {
        assert forall book, name | name != patron
          :: CheckedOutTo(s, book, name) == CheckedOutTo(s', book, name);
//        assert HasAtMostOneBook(s', name);
//      }
    } else {
      var book, patron :| CheckIn(s, s', book, patron);
//      if patron == name {
        forall book1, book2 |
          CheckedOutTo(s', book1, name) && CheckedOutTo(s', book2, name)
          ensures book1 == book2 {
          assert CheckedOutTo(s, book1, name);
          assert CheckedOutTo(s, book2, name);
        }
//        assert HasAtMostOneBook(s', name);
//      } else {
//        assert forall book, name | name != patron
//          :: CheckedOutTo(s, book, name) == CheckedOutTo(s', book, name);
//        assert HasAtMostOneBook(s', name);
//      }
    }
  }
}
