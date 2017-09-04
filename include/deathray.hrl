-record( timestamp, {id, modtime} ).

-record( unique_ids, {type, id} ).

-record( entry, {
	  id,
	  title,
	  text,
	  image,
      pubdate 
}).
