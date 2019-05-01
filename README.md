This program grabs data from dynamo DB table which has ticketmaster data, and replies to web server requests, with selected pieces of information. By default, this program listens on http://localhost:8080

endpoint /chansen/all
replies with a json representation of all entries in the table

endpoint /chansen/status
replies with a json representation of the number of items in the table, and the table name
