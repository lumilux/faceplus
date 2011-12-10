# Issues

## Strange things about the Facebook API

* if you call `/search?q=name&type=user`, the results actually vary drastically from the results from a search on facebook itself.
    * this is because this performs a public search, i believe... solution could be to get /me/friends from the start, then add results here to search results
    * however, this means we are also getting much less data because it is a public search and plenty of people keep their information hidden. 
