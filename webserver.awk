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
  Response["Body"] = output
}

function BuildJSONSingle(uuid,  output, line) {
  FS=","
  while ((getline line < "db.csv" ) > 0) {
    if (!l++ || line !~ uuid) continue
    $0=line
    output = sprintf("%s {\"uuid\": \"%s\", \"survived\": %s, \"passengerClass\": %d, \"name\": \"%s\", \"sex\": \"%s\", \"age\": %d, \"siblingsOrSpousesAboard\": %d, \"parentsOrChildrenAboard\": %d, \"fare\": %s}", output, $1, $2?"false":"true", $3, $4, $5, $6, $7, $8, $9)
    break
  }
  Response["Body"] = output
}

function UpdateDB(  command, record, uuid) {
  command = "jq -r '\(.survived|tostring) + \",\" + \(.passengerClass|tostring) + \",\" + \(.name|tostring) + \",\" + \(.sex|tostring) + \",\" + \(.age|tostring) + \",\" + \(.siblingsOrSpousesAboard|tostring) + \",\" + \(.parentsOrChildrenAboard|tostring) + \",\" + \(.fare|tostring)'"
  print Request["Body"] |& command
  close(command, "to")

  command |& getline record
  close(command)

  ("uuidgen" | getline uuid)
  close("uuidgen")

  print uuid "," record >> db.csv

  BuildJSONSingle(uuid)
  Response["Status"] = "201 CREATED"
}

function HandlePeople(ep) {
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
    Response["Status"] = "200 OK"
    Response["Body"] = ""

    # Loop until we have input
    while ((HttpService |& getline) == -1 || !$0) continue
    # do some logging
    print systime(), strftime(), $0

    # start defining request
    delete Request
    Request["Method"]=$1
    split($2, urlPieces, "?")
    Request["Endpoint"] = substr(urlPieces[1],2)
    Request["Length"] = 0
    Request["Body"] = ""

    # none of the endpoints support params
    if (!Request["Endpoint"] || Request["Endpoint"] ~ /\?/) {
      print "invalid endpoint: " Request["Endpoint"]
      while (!(HttpService |& getline) != -1) {}
      close(HttpService)
      continue
    }

    # parse request headers
    FS=": *"
    while ($0) {
      HttpService |& getline
      if ($1) Request["Headers"][tolower($1)] = $2
    }
    FS=" "

    # parse request body
    contentLength = Request["Headers"]["content-length"]
    if (contentLength) {
      RS="}"
      HttpService |& getline
      Request["Body"] = $0 "}"
      RS = "\r\n"
    }

    split(Request["Endpoint"], ep, "/")
    # print ep[1]

    if (ep[1] == "people") {
      HandlePeople(ep)
    } else {
      Response["Body"] = sprintf("bad endpoint: %s", Request["Endpoint"])
      Response["Status"] = "404 NOT FOUND"
    }
    print "HTTP/1.0", Response["Status"]                  |& HttpService
    print "Connection: Close"                             |& HttpService
    print "Pragma: no-cache"                              |& HttpService
    len = length(Response["Body"]) + length(ORS)
    print "Content-length:", len                          |& HttpService
    print "X-Powered-By: awk"                             |& HttpService
    print ORS Response["Body"]                            |& HttpService

    # skip anything else in the request
    while ((HttpService |& getline) > 0) continue
    # stop talking to this client
    close(HttpService)
  }
}
