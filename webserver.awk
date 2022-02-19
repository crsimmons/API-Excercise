function BuildDB(  line, l, uuid) {
  print "" > "db.csv"
  FS=","
  while ((getline line < "titanic.csv" ) > 0) {
    if (!l++) print "Uuid," line >> "db.csv"
    ("uuidgen" | getline uuid)
    close("uuidgen")
    print uuid "," line >> "db.csv"
  }
}

function BuildJSON(  output, line, l) {
  output = "["
  FS=","
  while ((getline line < "db.csv" ) > 0) {
    if (!l++) continue
    if (length(output)>1) output = output ","
    $0=line
    output = sprintf("%s {\"uuid\": \"%s\", \"survived\": %s, \"passengerClass\": %d, \"name\": \"%s\", \"sex\": \"%s\", \"age\": %d, \"siblingsOrSpousesAboard\": %d, \"parentsOrChildrenAboard\": %d, \"fare\": %s}", output, $1, $2?"false":"true", $3, $4, $5, $6, $7, $8, $9)
  }
  output = output "]"
  Response = output
}

function Process_request(method, uri, version) {
  delete Request
  Request["Method"] = $1
  Request["Endpoint"] = substr($2,2)
  Request["Version"] = $3
 }

function HandlePeople(ep) {
  print "handling people"
  if (Request["Method"] == "GET") {
    if (length(ep) == 1) {
      BuildJson()
      return
    }
    else if (length(ep) == 2) {
      BuildJSONSingle(ep[2])
      return
    }
  }
  else if (Request["Method"] == "POST" && length(ep) == 1) {
    UpdateDB()
    return
  }
}

BEGIN {
  # BuildDB()

  if (listenDomain == "") {
     listenDomain = "0.0.0.0"
  }
  if (ListenPort == 0) ListenPort = 8080
  HttpService = "/inet/tcp/" ListenPort "/0/0"
  Host = "http://" listenDomain ":" ListenPort

  print "Listening on " Host

  while (1) {
    RS = ORS = "\r\n"
    ResponseStatus = 200
    ResponseReason = "OK"
    Response = ""

    # wait for new client request
    HttpService |& getline
    # do some logging
    print systime(), strftime(), $0
    # read request parameters
    Process_request($1, $2, $3)

    while ((HttpService |& getline) > 0) {
      if ($0 == "") break
    }

    split(Request["Endpoint"], ep, "/")
    print ep[1]

    if (ep[1] == "people") {
      HandlePeople(ep)
    } else {
      Response = sprintf("bad endpoint: %s", Request["Endpoint"])
      ResponseStatus = 404
      ResponseReason = "NOT FOUND"
    }
    print "HTTP/1.0", ResponseStatus, ResponseReason      |& HttpService
    print "Connection: Close"                             |& HttpService
    print "Pragma: no-cache"                              |& HttpService
    len = length(Response) + length(ORS)
    print "Content-length:", len                          |& HttpService
    print ORS Response                                    |& HttpService

    while ((HttpService |& getline) > 0) {
      continue
    }
    # stop talking to this client
    close(HttpService)
  }
}
