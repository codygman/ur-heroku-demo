table users : { ID : int, Username : string, Password : string }
  PRIMARY KEY ID

task initialize = fn () => 
  b <- nonempty users;
  if b then
      return ()
  else
      dml (INSERT INTO users (ID,Username,Password) VALUES (0, {["admin"]}, {["admin"]}))

fun login name pass =
  oneOrNoRowsE1 (SELECT (users.Username) FROM users 
                 WHERE users.Username = {[name]} AND users.Password = {[pass]})

fun main () =
  s <- source "Not logged in."; u <- source ""; p <- source "";
  return <xml><body>
    <form>
      Username: <ctextbox source={u}/><br/>
      Password: <ctextbox  source={p}/><br/>
      <button value="Submit" onclick={loginButton s u p}/>
    </form><br/>
    Status: <dyn signal={v <- signal s; return <xml>{[v]}</xml>} />
  </body></xml>

and loginButton s u p = 
  uu <- get u; pp <- get p; n <- rpc (login uu pp);
  case n of
    None => return ()
  | Some r => set s ("Logged in as " ^ r)
