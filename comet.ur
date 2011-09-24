table chans : { Channel : channel int 
	      }
		  PRIMARY KEY Channel

sequence seq

fun incSeq () = nextval seq

fun action () =
    ch <- channel;
    dml (INSERT INTO chans (Channel) VALUES ({[ch]}));
    s <- source 0;

    let 
	fun writeBack n =
	    queryI1 (SELECT * FROM chans) (fn r => send r.Channel n)
	fun recieve () =
	    v <- recv ch;
	    set s v;
	    recieve ()
	fun incButton () =
	    n <- incSeq ();
	    writeBack n
    in
	return <xml><body onload={recieve ()}>
	  <dyn signal={n <- signal s; return <xml>{[n]}</xml>}/>
	  <button value="Upvote" onclick={rpc (incButton ())}/>
	</body></xml>
    end


fun main () =
    return <xml><body>
      <form><submit value="Go" action={action}/></form>
    </body></xml>
